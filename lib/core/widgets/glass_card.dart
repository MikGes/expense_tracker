import 'dart:ui';

import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.50),
            borderRadius: borderRadius,
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

