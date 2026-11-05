import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';
import 'squelette.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? color;

  /// Tant que la donnee n'est pas arrivee, la valeur et le libelle sont
  /// remplaces par des barres a reflet, a hauteur identique.
  final bool chargement;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.onTap,
    this.color,
    this.chargement = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accentColor = color ?? AppTheme.primaryIcons;

    return GlassContainer(
      onTap: onTap,
      blur: 0,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: accentColor, size: 16),
              ),
              if (subtitle != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: chargement
                ? const Squelette(width: 58, height: 19, radius: 7)
                : _valeurAnimee(
                    TextStyle(
                      color: isLight ? const Color(0xFF0F172A) : Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
          ),
          const SizedBox(height: 2),
          if (chargement)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Squelette(height: 10, radius: 5),
            )
          else
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isLight
                    ? const Color(0xFF64748B)
                    : Colors.white.withValues(alpha: 0.7),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  /// Un compteur defile jusqu'a sa valeur ; les montants, deja formates en
  /// chaine, ne peuvent pas etre interpoles et arrivent donc en fondu.
  ///
  /// Les donnees du tableau de bord arrivent apres le premier rendu : la carte
  /// est construite a zero, puis l'animation part de la valeur affichee vers
  /// la nouvelle (TweenAnimationBuilder n'utilise `begin` qu'au premier build).
  Widget _valeurAnimee(TextStyle style) {
    final cible = int.tryParse(value);

    if (cible == null) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        transitionBuilder: (enfant, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.35),
              end: Offset.zero,
            ).animate(animation),
            child: enfant,
          ),
        ),
        child: Text(
          value,
          key: ValueKey<String>(value),
          maxLines: 1,
          style: style,
        ),
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: cible.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, valeur, _) =>
          Text('${valeur.round()}', maxLines: 1, style: style),
    );
  }
}
