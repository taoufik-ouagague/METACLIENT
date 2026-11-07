import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Enveloppe une liste defilante et tire le paquet suivant quand le bas
/// approche. Remplace les boutons de page : l'utilisateur ne fait que scroller.
class ScrollInfini extends StatelessWidget {
  const ScrollInfini({
    super.key,
    required this.onFin,
    required this.child,
    this.marge = 300,
  });

  /// Appelee des que le scroll entre dans la zone de declenchement. A charge
  /// du controleur d'ignorer l'appel s'il charge deja ou n'a plus de pages :
  /// la notification arrive a chaque frame tant qu'on reste dans la zone.
  final VoidCallback onFin;

  /// Distance au bas de la liste, en pixels, qui declenche le chargement.
  /// Assez grande pour que le paquet arrive avant qu'on touche le fond.
  final double marge;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (avis) {
        final m = avis.metrics;
        if (m.axis == Axis.vertical && m.pixels >= m.maxScrollExtent - marge) {
          onFin();
        }
        // false : l'avis continue sa route vers les autres listeners.
        return false;
      },
      child: child,
    );
  }
}

/// Rond en pied de liste pendant que le paquet suivant arrive.
class PiedChargement extends StatelessWidget {
  const PiedChargement({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }
}
