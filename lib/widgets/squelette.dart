import 'package:flutter/material.dart';

/// Barre grise a reflet glissant, affichee a la place d'une donnee qui n'est
/// pas encore arrivee.
///
/// Ecrite a la main plutot qu'avec un paquet : un degre a trois arrets dont on
/// deplace les bornes suffit, et la carte garde ainsi exactement la meme
/// hauteur avant et apres le chargement — pas de saut quand la valeur arrive.
class Squelette extends StatefulWidget {
  const Squelette({
    super.key,
    this.width,
    required this.height,
    this.radius = 6,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  State<Squelette> createState() => _SqueletteState();
}

class _SqueletteState extends State<Squelette>
    with SingleTickerProviderStateMixin {
  static const Color _fond = Color(0xFFE2E8F0);
  static const Color _reflet = Color(0xFFF8FAFC);

  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1250),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forme = BorderRadius.circular(widget.radius);

    // « Reduire les animations » du systeme : barre fixe, sans reflet.
    if (MediaQuery.disableAnimationsOf(context)) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(color: _fond, borderRadius: forme),
      );
    }

    // Isole le reflet : sans cela, chaque frame repeint la carte entiere.
    return RepaintBoundary(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            // Le reflet traverse la barre de gauche a droite.
            final x = _ctrl.value * 3 - 1.5;
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: forme,
                gradient: LinearGradient(
                  begin: Alignment(x - 1, 0),
                  end: Alignment(x + 1, 0),
                  colors: const [_fond, _reflet, _fond],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
