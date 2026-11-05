import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Style du colis (conservé pour rétro-compatibilité)
enum ColisStyle {
  kraft,
  brand,
}

/// Un loader / spinner studio photoréaliste animé en forme de colis 3D.
///
/// Intègre l'animation vidéo/boucle 3D générée en haute résolution :
/// - Colis kraft avec texture réaliste, étiquette code-barres et tampon Fragile
/// - Lévitation fluide avec balancement 3D et reflet spéculaire sur le ruban
/// - Ombre portée dynamique au sol
/// - Fond 100% transparent pour s'intégrer harmonieusement sur tous les fonds
class ColisLoader extends StatelessWidget {
  const ColisLoader({
    super.key,
    this.size = 110,
    this.message,
    this.style = ColisStyle.kraft,
    this.showOrbit = true,
    this.showScanner = true,
    this.showShadow = true,
    this.tapeColor,
  });

  /// Taille globale du loader (largeur et hauteur du colis)
  final double size;

  /// Message optionnel affiché en dessous
  final String? message;

  /// Style visuel (kraft ou brand)
  final ColisStyle style;

  /// Paramètres optionnels de rétrocompatibilité
  final bool showOrbit;
  final bool showScanner;
  final bool showShadow;
  final Color? tapeColor;

  static const String _primaryAsset = 'assets/img/colis_spinner.gif';
  static const String _fallbackAsset = 'assets/img/colis_spinner.webp';

  @override
  Widget build(BuildContext context) {
    final Widget spinner = RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Image.asset(
            _primaryAsset,
            width: size,
            height: size,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                _fallbackAsset,
                width: size,
                height: size,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                filterQuality: FilterQuality.high,
              );
            },
          ),
        ),
      ),
    );

    if (message == null || message!.trim().isEmpty) {
      return spinner;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        spinner,
        const SizedBox(height: 10),
        Text(
          message!,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF475569),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
