import 'package:expense_tracker/features/expenses/domain/expense.dart';

abstract class ExpenseRepository {
  Stream<List<Expense>> watchAll();
  Future<void> upsert(Expense expense);
  Future<void> deleteById(String id);
}

