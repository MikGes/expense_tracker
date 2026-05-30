import 'package:expense_tracker/core/providers/app_init_provider.dart';
import 'package:expense_tracker/features/expenses/data/hive_expense_repository.dart';
import 'package:expense_tracker/features/expenses/domain/expense.dart';
import 'package:expense_tracker/features/expenses/domain/expense_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final box = ref.watch(expensesBoxProvider);
  return HiveExpenseRepository(box);
});

final expensesStreamProvider = StreamProvider<List<Expense>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchAll();
});

