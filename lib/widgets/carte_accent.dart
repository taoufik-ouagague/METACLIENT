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
  });

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
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B3A5B).withValues(alpha: 0.07),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: teinte.withValues(alpha: 0.07),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Color.alphaBlend(
                      teinte.withValues(alpha: 0.05),
                      const Color(0xFFF4F9FC),
                    ),
                  ],
                ),
                border: Border.all(color: Colors.white, width: 1.4),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -10,
                    bottom: -14,
                    child: Icon(
                      widget.icone,
                      size: 46,
                      color: teinte.withValues(alpha: 0.055),
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
