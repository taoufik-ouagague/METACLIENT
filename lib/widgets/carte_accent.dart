import 'package:flutter/material.dart';

/// Carte de liste accentuee : filet vertical au bord gauche, filigrane dans
/// l'angle, teinte legere et enfoncement a l'appui — le meme traitement que
/// les tuiles de l'accueil.
///
/// Elle ne s'appuie pas sur `CarteListe` : le filet et le filigrane debordent
/// et demandent un ClipRRect, que cette derniere n'a pas.
class CarteAccent extends StatefulWidget {
  const CarteAccent({
    super.key,
    required this.teinte,
    required this.icone,
    required this.child,
    this.onTap,
    this.fondTeinte = true,
    this.tailleFiligrane = 46,
    this.basFiligrane,
    this.rayon = 18,
    this.fond,
    this.ombres,
    this.couleurFiligrane,
  });

  /// Rayon des angles.
  final double rayon;

  /// Fond uni ; remplace le degrade quand il est fourni.
  final Color? fond;

  /// Ombres ; remplacent les trois couches par defaut quand elles sont fournies.
  final List<BoxShadow>? ombres;

  /// Couleur du filigrane ; remplace celle derivee de la teinte.
  final Color? couleurFiligrane;

  /// Distance du filigrane au bas de la carte. Par defaut il deborde du coin ;
  /// une valeur positive le remonte le long du bord droit.
  final double? basFiligrane;

  /// Faux : fond blanc bleute neutre et filigrane gris-bleu ; seuls le filet
  /// et les elements de la carte portent la teinte.
  final bool fondTeinte;

  /// Taille du motif en filigrane dans l'angle.
  final double tailleFiligrane;

  /// Couleur du filet, du filigrane et de la teinte de fond.
  final Color teinte;

  /// Motif pose en filigrane dans l'angle.
  final IconData icone;

  final VoidCallback? onTap;
  final Widget child;

  @override
  State<CarteAccent> createState() => CarteAccentState();
}

class CarteAccentState extends State<CarteAccent> {
  bool _presse = false;

  void _presser(bool actif) {
    if (_presse == actif) return;
    setState(() => _presse = actif);
  }

  @override
  Widget build(BuildContext context) {
    final teinte = widget.teinte;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _presser(true),
      onTapUp: (_) => _presser(false),
      onTapCancel: () => _presser(false),
      child: AnimatedScale(
        scale: _presse ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.rayon),
            // Trois couches, du halo diffus au contact fin : la carte flotte
            // au-dessus du degrade sans y poser de gris.
            boxShadow:
                widget.ombres ??
                [
                  BoxShadow(
                    color: teinte.withValues(alpha: 0.13),
                    blurRadius: 30,
                    spreadRadius: -6,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: const Color(0xFF1B3A5B).withValues(alpha: 0.08),
                    blurRadius: 16,
                    spreadRadius: -3,
                    offset: const Offset(0, 7),
                  ),
                  BoxShadow(
                    color: const Color(0xFF1B3A5B).withValues(alpha: 0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.rayon),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: widget.fond,
                gradient: widget.fond != null
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.fondTeinte
                              ? Colors.white
                              : const Color(0xFFF7FAFE),
                          widget.fondTeinte
                              ? Color.alphaBlend(
                                  teinte.withValues(alpha: 0.05),
                                  const Color(0xFFF4F9FC),
                                )
                              : const Color(0xFFF1F7FD),
                        ],
                      ),
                border: Border.all(color: Colors.white, width: 1.4),
                borderRadius: BorderRadius.circular(widget.rayon),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -widget.tailleFiligrane * 0.18,
                    bottom:
                        widget.basFiligrane ?? -widget.tailleFiligrane * 0.26,
                    child: Icon(
                      widget.icone,
                      size: widget.tailleFiligrane,
                      color:
                          widget.couleurFiligrane ??
                          (widget.fondTeinte
                              ? teinte.withValues(alpha: 0.055)
                              : const Color(0xFFE0EDF7)),
                    ),
                  ),
                  // Arete haute eclairee : l'epaisseur du verre.
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Container(
                      height: 1.4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.95),
                            Colors.white.withValues(alpha: 0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Filet vertical : sur une liste, il se lit mieux au bord
                  // gauche qu'en pied de carte.
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [teinte, teinte.withValues(alpha: 0.35)],
                        ),
                      ),
                    ),
                  ),
                  widget.child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
