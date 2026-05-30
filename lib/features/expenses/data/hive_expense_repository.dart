import 'dart:async';
import 'dart:convert';

import 'package:expense_tracker/features/expenses/domain/expense.dart';
import 'package:expense_tracker/features/expenses/domain/expense_repository.dart';
import 'package:hive/hive.dart';

class HiveExpenseRepository implements ExpenseRepository {
  HiveExpenseRepository(this._box);

  final Box<String> _box;

  List<Expense> _readAll() {
    final items = <Expense>[];
    for (final v in _box.values) {
      final decoded = jsonDecode(v) as Map<String, Object?>;
      items.add(Expense.fromJson(decoded));
    }
    items.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return items;
  }

  @override
  Stream<List<Expense>> watchAll() async* {
    yield _readAll();
    await for (final _ in _box.watch()) {
      yield _readAll();
    }
  }

  @override
  Future<void> upsert(Expense expense) async {
    await _box.put(expense.id, jsonEncode(expense.toJson()));
  }

  @override
  Future<void> deleteById(String id) async {
    await _box.delete(id);
  }
}

