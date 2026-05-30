import 'package:expense_tracker/app/router/app_router.dart';
import 'package:expense_tracker/app/theme/app_theme.dart';
import 'package:expense_tracker/app/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseTrackerApp extends ConsumerWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

