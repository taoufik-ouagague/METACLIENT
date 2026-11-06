import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? color;
  final Border? border;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;
  final bool? isLight;

  /// `blur` vaut 0 par defaut : un BackdropFilter coute un saveLayer plein
  /// ecran, et sur un fond fixe sous un remplissage deja opaque il ne se voit
  /// pas. Pire, enveloppe dans l'Opacity d'une animation d'apparition, il fait
  /// crier Impeller (« SetInheritedOpacity ... CanAcceptOpacity returns
  /// false »). Ne le demander que par-dessus une image ou du contenu qui
  /// defile.
  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blur = 0,
    this.color,
    this.border,
    this.onTap,
    this.boxShadow,
    this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final light = isLight ?? (Theme.of(context).brightness == Brightness.light);

    final effectiveColor =
        color ??
        (light ? Colors.white.withValues(alpha: 0.85) : AppTheme.glassBg);

    final effectiveBorder =
        border ??
        (light
            ? Border.all(color: Colors.white, width: 1.5)
            : Border.all(color: AppTheme.glassBorder, width: 1.2));

    final effectiveShadow =
        boxShadow ??
        (light
            ? [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]);

    Widget boite = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: effectiveBorder,
        boxShadow: effectiveShadow,
      ),
      child: child,
    );

    // Un BackdropFilter coute un saveLayer plein ecran par carte : on ne le
    // pose que si un flou est reellement demande. Sur un fond fixe et sous un
    // remplissage deja opaque, il ne se voyait pas et plombait les frames
    // (le tableau de bord en empilait neuf).
    if (blur > 0) {
      boite = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: boite,
      );
    }

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: boite,
    );

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}
