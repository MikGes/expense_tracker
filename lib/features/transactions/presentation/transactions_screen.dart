import 'package:expense_tracker/core/widgets/glass_card.dart';
import 'package:expense_tracker/features/expenses/domain/expense_category.dart';
import 'package:expense_tracker/features/expenses/presentation/expense_form_sheet.dart';
import 'package:expense_tracker/features/expenses/presentation/expenses_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/formatters/money_format.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final expensesAsync = ref.watch(expensesStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: expensesAsync.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 46,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No expenses yet',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap “Add expense” to create your first transaction.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          final dateFmt = DateFormat('EEE, MMM d');
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final e = expenses[index];
              final c = DefaultExpenseCategories.byId(e.categoryId);
              return Dismissible(
                key: ValueKey(e.id),
                background: _SwipeBg(
                  alignment: Alignment.centerLeft,
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  color: scheme.primary,
                ),
                secondaryBackground: _SwipeBg(
                  alignment: Alignment.centerRight,
                  icon: Icons.delete_rounded,
                  label: 'Delete',
                  color: scheme.error,
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    await showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => Container(
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(26),
                          ),
                        ),
                        child: ExpenseFormSheet(initial: e),
                      ),
                    );
                    return false;
                  }

                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete expense?'),
                      content: Text('“${e.title}” will be removed permanently.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await ref.read(expenseRepositoryProvider).deleteById(e.id);
                    return true;
                  }
                  return false;
                },
                child: GlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  borderRadius: BorderRadius.circular(18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: c.color.withValues(alpha: 0.18),
                        child: Icon(c.icon, color: c.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${e.title} • ${dateFmt.format(e.dateTime)}',
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '-${formatBirr(e.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: scheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemCount: expenses.length,
          );
        },
        error: (e, _) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _SwipeBg extends StatelessWidget {
  const _SwipeBg({
    required this.alignment,
    required this.icon,
    required this.label,
    required this.color,
  });

  final Alignment alignment;
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

