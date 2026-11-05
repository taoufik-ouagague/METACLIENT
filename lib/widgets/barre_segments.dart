import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Bascule a deux ou trois onglets, avec un curseur qui glisse d'un onglet a
/// l'autre.
///
/// Teinter le fond de chaque bouton ne donnait pas de mouvement : un degrade
/// qui devient `null` ne s'interpole pas, la pastille sautait. Ici elle est
/// unique et c'est sa position qui s'anime.
class BarreSegments extends StatelessWidget {
  const BarreSegments({
    super.key,
    required this.libelles,
    required this.index,
    required this.onChange,
    this.tailleTexte = 12.5,
  });

  final List<String> libelles;
  final int index;
  final ValueChanged<int> onChange;
  final double tailleTexte;

  static const Duration _duree = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    final n = libelles.length;

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedAlign(
          // -1 colle a gauche, 1 a droite : l'onglet choisi donne la position.
          alignment: Alignment(n == 1 ? 0 : -1 + 2 * index / (n - 1), 0),
          duration: _duree,
          curve: Curves.easeOutCubic,
          child: FractionallySizedBox(
            widthFactor: 1 / n,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          children: [
            for (var i = 0; i < n; i++)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChange(i),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: _duree,
                      curve: Curves.easeOutCubic,
                      style: TextStyle(
                        color: i == index
                            ? Colors.white
                            : const Color(0xFF64748B),
                        fontSize: tailleTexte,
                        fontWeight: i == index
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      child: Text(
                        libelles[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
