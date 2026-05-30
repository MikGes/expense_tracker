import 'package:expense_tracker/core/providers/app_init_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(appInitProvider);

    ref.listen(appInitProvider, (_, next) {
      next.whenOrNull(
        data: (_) {
          if (context.mounted) context.go('/dashboard');
        },
      );
    });

    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withValues(alpha: 0.22),
              scheme.secondary.withValues(alpha: 0.14),
              scheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 84,
                    width: 84,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [
                          scheme.primary,
                          scheme.secondary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: scheme.onPrimary,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Mikisho Expense',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Local-first expense tracking',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 22),
                  init.when(
                    data: (_) => const SizedBox.shrink(),
                    error: (e, _) => Column(
                      children: [
                        Text(
                          'Failed to initialize storage.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: scheme.error,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: () => ref.refresh(appInitProvider),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                    loading: () => Column(
                      children: [
                        const SizedBox(
                          height: 26,
                          width: 26,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Preparing your vault…',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

