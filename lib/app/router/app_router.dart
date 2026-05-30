import 'package:expense_tracker/features/dashboard/presentation/dashboard_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/expense_form_sheet.dart';
import 'package:expense_tracker/features/insights/presentation/insights_screen.dart';
import 'package:expense_tracker/features/settings/presentation/settings_screen.dart';
import 'package:expense_tracker/features/splash/presentation/splash_screen.dart';
import 'package:expense_tracker/features/transactions/presentation/transactions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      ShellRoute(
        builder: (context, state, navigator) => _AppShell(
          navigator: navigator,
          location: state.uri.toString(),
        ),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionsScreen(),
          ),
          GoRoute(
            path: '/insights',
            builder: (context, state) => const InsightsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    debugLogDiagnostics: true,
  );
});

class _AppShell extends ConsumerWidget {
  const _AppShell({
    required this.navigator,
    required this.location,
  });

  final Widget navigator;
  final String location;

  static const _tabs = <(String label, IconData icon, String location)>[
    ('Dashboard', Icons.grid_view_rounded, '/dashboard'),
    ('Transactions', Icons.receipt_long_rounded, '/transactions'),
    ('Insights', Icons.auto_graph_rounded, '/insights'),
    ('Settings', Icons.settings_rounded, '/settings'),
  ];

  int _indexForLocation(String location) {
    final idx = _tabs.indexWhere((t) => location.startsWith(t.$3));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _indexForLocation(location);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: navigator,
      extendBody: true,
      floatingActionButton: (location.startsWith('/dashboard') ||
              location.startsWith('/transactions'))
          ? FloatingActionButton.extended(
              onPressed: () async {
                await showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const _SheetSurface(
                    child: ExpenseFormSheet(),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add expense'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surface.withValues(alpha: 0.85),
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
                ],
              ),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: NavigationBar(
              height: 70,
              backgroundColor: Colors.transparent,
              indicatorColor: colorScheme.primary.withValues(alpha: 0.16),
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                final location = _tabs[index].$3;
                if (location != GoRouterState.of(context).uri.toString()) {
                  context.go(location);
                }
              },
              destinations: [
                for (final t in _tabs)
                  NavigationDestination(
                    icon: Icon(t.$2),
                    label: t.$1,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetSurface extends StatelessWidget {
  const _SheetSurface({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: child,
    );
  }
}

