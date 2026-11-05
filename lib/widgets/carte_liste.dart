import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Carte de liste de l'application : degrade blanc, liseret clair et double
/// ombre (une neutre, une teintee). Un blanc plat se perd sur le fond clair ;
/// ce relief le decolle sans l'alourdir.
///
/// Partagee par les six tableaux de l'expedition pour qu'ils se ressemblent.
class CarteListe extends StatelessWidget {
  const CarteListe({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.onTap,
    this.borderRadius = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final carte = Container(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 13, 16, 13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF4F9FC)],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B3A5B).withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.06),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: onTap == null
          ? carte
          : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(borderRadius),
                onTap: onTap,
                child: carte,
              ),
            ),
    );
  }
}
