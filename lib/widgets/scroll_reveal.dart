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
    this.echelle = 1,
    this.cascade = 6,
  });

  /// Variante pour une grille affichee d'un bloc (le tableau de bord) : les
  /// cartes se deplient de plus loin, et la cascade couvre toute la grille au
  /// lieu de repartir a zero au bout de six elements.
  const ScrollReveal.grille({
    super.key,
    required this.index,
    required this.child,
    // Assez large pour la grille du tableau de bord : au-dela, une carte
    // repartirait en meme temps que la premiere.
    this.cascade = 12,
  }) : decalage = 26,
       echelle = 0.9;

  final int index;
  final Widget child;

  /// Distance parcourue vers le haut, en pixels.
  final double decalage;

  /// Taille de depart, 1 pour n'appliquer aucun grossissement. En dessous de 1
  /// la carte se deplie en arrivant ; reserve aux grilles (tableau de bord),
  /// une liste qui defile n'en a pas besoin.
  final double echelle;

  /// Nombre d'elements avant que le retard ne reparte a zero : il borne
  /// l'attente d'une ligne situee loin dans une liste.
  final int cascade;

  @override
  Widget build(BuildContext context) {
    // « Reduire les animations » du systeme : on rend la ligne telle quelle.
    if (MediaQuery.disableAnimationsOf(context)) return child;

    final debut = (index % cascade) * 0.07;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Interval(debut, 1, curve: Curves.easeOutCubic),
      builder: (context, t, enfant) {
        Widget rendu = Transform.translate(
          offset: Offset(0, (1 - t) * decalage),
          child: enfant,
        );

        if (echelle != 1) {
          rendu = Transform.scale(
            scale: echelle + (1 - echelle) * t,
            child: rendu,
          );
        }

        return Opacity(opacity: t, child: rendu);
      },
      child: child,
    );
  }
}
