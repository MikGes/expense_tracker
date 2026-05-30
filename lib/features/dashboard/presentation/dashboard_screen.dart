import 'package:expense_tracker/core/widgets/glass_card.dart';
import 'package:expense_tracker/core/formatters/money_format.dart';
import 'package:expense_tracker/features/expenses/domain/expense.dart';
import 'package:expense_tracker/features/expenses/domain/expense_category.dart';
import 'package:expense_tracker/features/expenses/presentation/expenses_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final expensesAsync = ref.watch(expensesStreamProvider);
    return Stack(
      children: [
        const _AnimatedBackground(),
        SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good afternoon',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Your finances at a glance',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_rounded),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: expensesAsync.when(
                    data: (expenses) {
                      final now = DateTime.now();
                      final monthStart = DateTime(now.year, now.month, 1);
                      final thisMonth = expenses
                          .where((e) => !e.dateTime.isBefore(monthStart))
                          .toList();
                      final monthTotal = thisMonth.fold<double>(
                        0,
                        (sum, e) => sum + e.amount,
                      );

                      final todayStart = DateTime(now.year, now.month, now.day);
                      final todayTotal = expenses
                          .where((e) => !e.dateTime.isBefore(todayStart))
                          .fold<double>(0, (sum, e) => sum + e.amount);

                      return GlassCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Total spent',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        scheme.primary.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'This month',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(color: scheme.primary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              formatBirr(monthTotal),
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _MiniMetric(
                                    label: 'Today',
                                    value: formatBirr(todayTotal),
                                    icon: Icons.today_rounded,
                                    tone: scheme.tertiary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _MiniMetric(
                                    label: 'Transactions',
                                    value: '${thisMonth.length}',
                                    icon: Icons.receipt_long_rounded,
                                    tone: scheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    error: (e, _) => GlassCard(
                      child: Text('Error: $e'),
                    ),
                    loading: () => const GlassCard(
                      child: SizedBox(
                        height: 86,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Recent transactions',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList.separated(
                  itemBuilder: (context, index) {
                    final expenses = expensesAsync.valueOrNull ?? const [];
                    if (index >= expenses.length) return const SizedBox.shrink();
                    return _TxnTile(expense: expenses[index]);
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemCount: (expensesAsync.valueOrNull ?? const []).take(8).length,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: tone, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TxnTile extends StatelessWidget {
  const _TxnTile({required this.expense});
  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final e = expense;
    final c = DefaultExpenseCategories.byId(e.categoryId);
    final dateFmt = DateFormat('MMM d');

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: BorderRadius.circular(18),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  c.color.withValues(alpha: 0.22),
                  scheme.secondary.withValues(alpha: 0.14),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              c.icon,
              color: c.color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  '${e.title} • ${dateFmt.format(e.dateTime)}',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            '-${formatBirr(e.amount)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scheme.error,
                ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_c.value);
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.7 + (t * 0.4), -0.8 + (t * 0.3)),
              radius: 1.35,
              colors: [
                scheme.primary.withValues(alpha: 0.18),
                scheme.secondary.withValues(alpha: 0.10),
                scheme.surface.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.38, 1.0],
            ),
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

