import 'package:flutter/material.dart';

/// Apparition d'une ligne de liste : fondu + remontee.
///
/// Les listes de l'app sont des `ListView.builder` / `.separated` : elles ne
/// construisent une ligne qu'au moment ou elle entre dans le viewport. Animer
/// la premiere construction suffit donc a obtenir une revelation au defilement,
/// sans detecteur de visibilite ni paquet supplementaire.
///
/// `index` ne sert qu'au decalage : les lignes visibles ensemble arrivent en
/// cascade au lieu de surgir d'un bloc. Le modulo borne le retard pour qu'une
/// ligne loin dans la liste ne parte pas avec une seconde de retard.
class ScrollReveal extends StatelessWidget {
  const ScrollReveal({
    super.key,
    required this.index,
    required this.child,
    this.decalage = 14,
  });

  final int index;
  final Widget child;

  /// Distance parcourue vers le haut, en pixels.
  final double decalage;

  static const int _lignesEnCascade = 6;

  @override
  Widget build(BuildContext context) {
    // « Reduire les animations » du systeme : on rend la ligne telle quelle.
    if (MediaQuery.disableAnimationsOf(context)) return child;

    final debut = (index % _lignesEnCascade) * 0.07;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Interval(debut, 1, curve: Curves.easeOutCubic),
      builder: (context, t, enfant) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * decalage),
          child: enfant,
        ),
      ),
      child: child,
    );
  }
}
