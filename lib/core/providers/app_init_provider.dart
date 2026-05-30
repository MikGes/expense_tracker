import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const expensesBoxName = 'expenses_box_v1';

final appInitProvider = FutureProvider<void>((ref) async {
  await Hive.initFlutter();
  await Hive.openBox<String>(expensesBoxName);
});

final expensesBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>(expensesBoxName);
});

