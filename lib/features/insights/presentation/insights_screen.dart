import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/expenses/presentation/expenses_providers.dart';
import 'package:expense_tracker/core/formatters/money_format.dart';
import 'package:expense_tracker/features/expenses/domain/expense_category.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final expenses = ref.watch(expensesStreamProvider).valueOrNull ?? const [];
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final thisMonth = expenses.where((e) => !e.dateTime.isBefore(monthStart)).toList();
    final monthTotal = thisMonth.fold<double>(0, (sum, e) => sum + e.amount);

    final byCategory = <String, double>{};
    for (final e in thisMonth) {
      byCategory[e.categoryId] = (byCategory[e.categoryId] ?? 0) + e.amount;
    }
    final top = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategoryId = top.isEmpty ? DefaultExpenseCategories.other.id : top.first.key;
    final topCategory = DefaultExpenseCategories.byId(topCategoryId);
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        physics: const BouncingScrollPhysics(),
        children: [
          _InsightCard(
            title: 'This month',
            subtitle: 'Total spent',
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                formatBirr(monthTotal),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InsightCard(
            title: 'Spending trend',
            subtitle: 'Last 7 days',
            child: SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: scheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: scheme.primary.withValues(alpha: 0.16),
                      ),
                      spots: const [
                        FlSpot(0, 12),
                        FlSpot(1, 18),
                        FlSpot(2, 14),
                        FlSpot(3, 26),
                        FlSpot(4, 22),
                        FlSpot(5, 28),
                        FlSpot(6, 24),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InsightCard(
            title: 'Top categories',
            subtitle: 'This month',
            child: SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 46,
                  sectionsSpace: 2,
                  sections: [
                    PieChartSectionData(
                      value: top.isEmpty ? 1 : top.first.value,
                      color: topCategory.color,
                      showTitle: false,
                      radius: 56,
                    ),
                    PieChartSectionData(
                      value: top.length > 1 ? top[1].value : 0,
                      color: scheme.secondary,
                      showTitle: false,
                      radius: 52,
                    ),
                    PieChartSectionData(
                      value: top.length > 2 ? top[2].value : 0,
                      color: scheme.tertiary,
                      showTitle: false,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: top.length > 3 ? top[3].value : 0,
                      color: scheme.error,
                      showTitle: false,
                      radius: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  scheme.primary.withValues(alpha: 0.16),
                  scheme.secondary.withValues(alpha: 0.10),
                ],
              ),
              border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.lightbulb_rounded, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tip: Your top category this month is ${topCategory.name}. Consider setting a weekly budget for it.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

