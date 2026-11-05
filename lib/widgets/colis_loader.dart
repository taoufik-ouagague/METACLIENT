import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Style du colis
enum ColisStyle {
  /// Carton kraft classique avec ruban cyan Meta
  kraft,

  /// Colis high-tech cyan/bleu aux couleurs de la marque
  brand,
}

/// Un loader / spinner exclusif en forme de colis 3D isométrique animé.
///
/// Comprend :
/// - Colis isométrique 3D photoréaliste (ombrage par dégradés zénithaux, biseaux lumineux,
///   ruban adhésif brillant avec rabats 3D, étiquette d'expédition avec code-barres et logo QR,
///   flèches de manipulation et tampon "Fragile")
/// - Rebond fluide Disney-grade avec squash & stretch et micro-inclinaison 3D
/// - Faisceau laser holographique volumétrique avec balayage LiDAR et étincelles aux arêtes
/// - Anneau orbital céleste 360° avec comète néon pulsante et traîne d'étoiles scintillantes
/// - Ombre dynamique au sol avec reflet d'ambiance cyan projeté
/// - Poussières et éclats d'impact à l'atterrissage
class ColisLoader extends StatefulWidget {
  const ColisLoader({
    super.key,
    this.size = 96,
    this.message,
    this.style = ColisStyle.kraft,
    this.showOrbit = true,
    this.showScanner = true,
    this.showShadow = true,
    this.tapeColor,
  });

  /// Taille globale du loader (largeur et hauteur du canvas du colis)
  final double size;

  /// Message optionnel affiché en dessous (ex: "Chargement...", "Recherche...")
  final String? message;

  /// Style visuel (kraft classique ou brand cyan)
  final ColisStyle style;

  /// Afficher l'anneau orbital lumineux qui tourne autour du colis
  final bool showOrbit;

  /// Afficher le balayage laser cyan (faisceau de scan)
  final bool showScanner;

  /// Afficher l'ombre dynamique projetée au sol
  final bool showShadow;

  /// Couleur personnalisée du ruban adhésif (par défaut AppTheme.primary)
  final Color? tapeColor;

  @override
  State<ColisLoader> createState() => _ColisLoaderState();
}

class _ColisLoaderState extends State<ColisLoader>
    with TickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final AnimationController _orbitController;
  late final AnimationController _scannerController;

  @override
  void initState() {
    super.initState();

    // 1. Rebond du colis avec squash & stretch (~1250ms)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..repeat();

    // 2. Rotation continue de l'anneau orbital (~1350ms)
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1350),
    )..repeat();

    // 3. Balayage laser vertical (~1500ms en va-et-vient)
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _orbitController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double boxSize = widget.size;
    final double totalHeight = widget.showShadow ? boxSize * 1.35 : boxSize;
    final double totalWidth = widget.size * 1.45;

    final Widget loaderWidget = RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _bounceController,
          _orbitController,
          _scannerController,
        ]),
        builder: (context, child) {
          return CustomPaint(
            size: Size(totalWidth, totalHeight),
            painter: _ColisPainter(
              bounceProgress: _bounceController.value,
              orbitProgress: _orbitController.value,
              scannerProgress: _scannerController.value,
              style: widget.style,
              showOrbit: widget.showOrbit,
              showScanner: widget.showScanner,
              showShadow: widget.showShadow,
              tapeColor: widget.tapeColor ?? AppTheme.primary,
            ),
          );
        },
      ),
    );

    if (widget.message == null || widget.message!.trim().isEmpty) {
      return loaderWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        loaderWidget,
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _bounceController,
          builder: (context, child) {
            final double opacity =
                0.75 + 0.25 * math.sin(_bounceController.value * math.pi * 2);
            return Opacity(
              opacity: opacity.clamp(0.6, 1.0),
              child: Text(
                widget.message!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF475569),
                  letterSpacing: 0.2,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Peintre vectoriel haute fidélité du colis 3D isométrique
class _ColisPainter extends CustomPainter {
  _ColisPainter({
    required this.bounceProgress,
    required this.orbitProgress,
    required this.scannerProgress,
    required this.style,
    required this.showOrbit,
    required this.showScanner,
    required this.showShadow,
    required this.tapeColor,
  });

  final double bounceProgress;
  final double orbitProgress;
  final double scannerProgress;
  final ColisStyle style;
  final bool showOrbit;
  final bool showScanner;
  final bool showShadow;
  final Color tapeColor;

  static const double _cos30 = 0.86602540378; // cos(30 deg)
  static const double _sin30 = 0.50000000000; // sin(30 deg)

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double groundY = size.height * 0.82;

    // Rayon de projection isométrique
    final double cubeS = size.width * 0.28;
    final double jumpHeight = cubeS * 0.88;

    // ─── 1. Calcul du Rebond & Squash/Stretch ─────────────────────────
    double dy = 0.0;
    double scaleX = 1.0;
    double scaleY = 1.0;
    double shadowScale = 1.0;
    double shadowOpacity = 0.35;
    double tiltAngle = 0.0;

    final double t = bounceProgress;
    if (t < 0.45) {
      // Montée fluide
      final double progress = t / 0.45;
      final double eased = Curves.easeOutCubic.transform(progress);
      dy = -jumpHeight * eased;
      scaleY = 1.0 + 0.10 * (1.0 - progress);
      scaleX = 1.0 - 0.06 * (1.0 - progress);
      shadowScale = 1.0 - 0.38 * eased;
      shadowOpacity = 0.35 - 0.22 * eased;
      tiltAngle = 0.05 * math.sin(progress * math.pi);
    } else if (t < 0.55) {
      // Sommet avec flottement
      final double progress = (t - 0.45) / 0.10;
      dy = -jumpHeight + math.sin(progress * math.pi) * 2.5;
      scaleX = 1.0;
      scaleY = 1.0;
      shadowScale = 0.62;
      shadowOpacity = 0.13;
      tiltAngle = 0.03 * (1.0 - progress);
    } else if (t < 0.86) {
      // Chute avec anticipation
      final double progress = (t - 0.55) / 0.31;
      final double eased = Curves.easeInQuad.transform(progress);
      dy = -jumpHeight * (1.0 - eased);
      scaleY = 1.0 + 0.12 * eased;
      scaleX = 1.0 - 0.07 * eased;
      shadowScale = 0.62 + 0.38 * eased;
      shadowOpacity = 0.13 + 0.22 * eased;
      tiltAngle = -0.04 * eased;
    } else if (t < 0.94) {
      // Contact au sol & Squash élastique
      final double progress = (t - 0.86) / 0.08;
      final double squashFactor = math.sin(progress * math.pi);
      dy = 0.0;
      scaleY = 1.0 - 0.18 * squashFactor;
      scaleX = 1.0 + 0.16 * squashFactor;
      shadowScale = 1.0 + 0.28 * squashFactor;
      shadowOpacity = 0.35 + 0.22 * squashFactor;
      tiltAngle = 0.0;
    } else {
      // Rétablissement rapide
      final double progress = (t - 0.94) / 0.06;
      dy = 0.0;
      scaleY = 1.0 - 0.04 * (1.0 - progress);
      scaleX = 1.0 + 0.03 * (1.0 - progress);
      shadowScale = 1.0;
      shadowOpacity = 0.35;
      tiltAngle = 0.0;
    }

    // ─── 2. Ombre au sol Multi-Couches avec Reflet Cyan ───────────────
    if (showShadow) {
      _drawShadow(canvas, cx, groundY, cubeS, shadowScale, shadowOpacity);
    }

    // ─── 3. Particules d'impact & Éclats à l'atterrissage ─────────────
    if (t >= 0.86 && t <= 0.98) {
      _drawImpactParticles(canvas, cx, groundY, cubeS, (t - 0.86) / 0.12);
    }

    // ─── 4. Anneau orbital Céleste (Partie Arrière) ───────────────────
    if (showOrbit) {
      _drawOrbit(
        canvas: canvas,
        cx: cx,
        cy: groundY - cubeS * 1.1 + dy,
        radiusX: cubeS * 1.55,
        radiusY: cubeS * 0.52,
        progress: orbitProgress,
        isBack: true,
      );
    }

    // ─── 5. Dessin du Colis 3D avec Transformations ──────────────────
    canvas.save();
    final double boxBaseY = groundY;
    canvas.translate(cx, boxBaseY + dy);
    canvas.rotate(tiltAngle);
    canvas.scale(scaleX, scaleY);

    _drawBox(canvas, Offset.zero, cubeS);

    // ─── 6. Faisceau Laser Holographique (Optionnel) ──────────────────
    if (showScanner) {
      _drawScannerBeam(canvas, cubeS, scannerProgress);
    }

    canvas.restore();

    // ─── 7. Anneau orbital Céleste (Partie Avant) ────────────────────
    if (showOrbit) {
      _drawOrbit(
        canvas: canvas,
        cx: cx,
        cy: groundY - cubeS * 1.1 + dy,
        radiusX: cubeS * 1.55,
        radiusY: cubeS * 0.52,
        progress: orbitProgress,
        isBack: false,
      );
    }
  }

  /// Dessine l'ombre au sol avec reflet d'ambiance cyan
  void _drawShadow(
    Canvas canvas,
    double cx,
    double groundY,
    double cubeS,
    double scale,
    double opacity,
  ) {
    // 1. Reflet d'ambiance cyan sous le carton
    final double glowRx = cubeS * 1.45 * scale;
    final double glowRy = cubeS * 0.50 * scale;
    final Rect glowRect = Rect.fromCenter(
      center: Offset(cx, groundY + 4),
      width: glowRx * 2,
      height: glowRy * 2,
    );
    final Paint cyanGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF22B7CE).withValues(alpha: (opacity * 0.40).clamp(0.0, 0.25)),
          const Color(0xFF0284C7).withValues(alpha: (opacity * 0.15).clamp(0.0, 0.15)),
          Colors.transparent,
        ],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(glowRect);
    canvas.drawOval(glowRect, cyanGlowPaint);

    // 2. Ombre de contact sombre et diffuse
    final double rx = cubeS * 1.25 * scale;
    final double ry = cubeS * 0.38 * scale;
    final Rect rect = Rect.fromCenter(
      center: Offset(cx, groundY + 3),
      width: rx * 2,
      height: ry * 2,
    );
    final Paint shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF09111E).withValues(alpha: opacity.clamp(0.0, 0.65)),
          const Color(0xFF0F1B2D).withValues(alpha: (opacity * 0.45).clamp(0.0, 0.45)),
          Colors.transparent,
        ],
        stops: const [0.0, 0.60, 1.0],
      ).createShader(rect);
    canvas.drawOval(rect, shadowPaint);
  }

  /// Dessine les poussières et étincelles d'impact
  void _drawImpactParticles(
    Canvas canvas,
    double cx,
    double groundY,
    double cubeS,
    double progress,
  ) {
    final double alpha = (1.0 - progress).clamp(0.0, 1.0);
    if (alpha <= 0.0) return;

    final Paint dustPaint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: alpha * 0.45)
      ..style = PaintingStyle.fill;

    final double spread = cubeS * 0.95 + progress * (cubeS * 0.50);
    final double r = 3.5 * (1.0 - progress * 0.45);

    // Nuages de poussière
    canvas.drawCircle(Offset(cx - spread, groundY), r, dustPaint);
    canvas.drawCircle(Offset(cx - spread * 0.82, groundY - 2.5), r * 0.75, dustPaint);
    canvas.drawCircle(Offset(cx + spread, groundY), r, dustPaint);
    canvas.drawCircle(Offset(cx + spread * 0.82, groundY - 2.5), r * 0.75, dustPaint);

    // Éclats / micro-étincelles cyan qui jaillissent
    final Paint sparkPaint = Paint()
      ..color = const Color(0xFF6DD5ED).withValues(alpha: alpha * 0.80)
      ..style = PaintingStyle.fill;
    final double sparkSpread = cubeS * 1.05 + progress * (cubeS * 0.70);
    canvas.drawCircle(Offset(cx - sparkSpread, groundY - 4 * (1 - progress)), 1.4, sparkPaint);
    canvas.drawCircle(Offset(cx + sparkSpread, groundY - 4 * (1 - progress)), 1.4, sparkPaint);
  }

  /// Dessine le colis isométrique 3D photoréaliste
  void _drawBox(Canvas canvas, Offset base, double s) {
    final double vy = -s * 1.15;
    final Offset v0 = Offset(0, vy);
    final Offset v1 = Offset(0, vy - s); // Sommet supérieur
    final Offset v2 = Offset(s * _cos30, vy - s * _sin30); // Sommet haut-droite
    final Offset v3 = Offset(s * _cos30, vy + s * (1 - _sin30)); // Bas-droite
    final Offset v4 = Offset(0, vy + s); // Bas-centre
    final Offset v5 = Offset(-s * _cos30, vy + s * (1 - _sin30)); // Bas-gauche
    final Offset v6 = Offset(-s * _cos30, vy - s * _sin30); // Haut-gauche

    // ── 1. Dégradés réalistes selon le style ─────────────────────────
    final Paint topPaint = Paint();
    final Paint leftPaint = Paint();
    final Paint rightPaint = Paint();
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeJoin = StrokeJoin.round;

    if (style == ColisStyle.kraft) {
      // Face supérieure : éclairage zénithal doux et chaud
      topPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0xFFF7E2C6), Color(0xFFE4B783)],
      ).createShader(Rect.fromPoints(v1, v0));

      // Face gauche : lumière rasante
      leftPaint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [Color(0xFFDDAE77), Color(0xFFB8854F)],
      ).createShader(Rect.fromPoints(v6, v4));

      // Face droite : ombre riche et marquée
      rightPaint.shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: const [Color(0xFFC49156), Color(0xFF915F2E)],
      ).createShader(Rect.fromPoints(v2, v4));

      borderPaint.color = const Color(0xFF7A4A1C).withValues(alpha: 0.35);
    } else {
      // Style High-Tech Cyan
      topPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0xFF38D4EE), Color(0xFF1E9BB8)],
      ).createShader(Rect.fromPoints(v1, v0));

      leftPaint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [Color(0xFF22B7CE), Color(0xFF13778F)],
      ).createShader(Rect.fromPoints(v6, v4));

      rightPaint.shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: const [Color(0xFF1A8DA6), Color(0xFF0D5769)],
      ).createShader(Rect.fromPoints(v2, v4));

      borderPaint.color = const Color(0xFF6DD5ED).withValues(alpha: 0.55);
    }

    // ── 2. Tracé des 3 Faces ─────────────────────────────────────────

    // Face Gauche
    final Path pathLeft = Path()
      ..moveTo(v0.dx, v0.dy)
      ..lineTo(v6.dx, v6.dy)
      ..lineTo(v5.dx, v5.dy)
      ..lineTo(v4.dx, v4.dy)
      ..close();
    canvas.drawPath(pathLeft, leftPaint);
    canvas.drawPath(pathLeft, borderPaint);

    // Face Droite
    final Path pathRight = Path()
      ..moveTo(v0.dx, v0.dy)
      ..lineTo(v2.dx, v2.dy)
      ..lineTo(v3.dx, v3.dy)
      ..lineTo(v4.dx, v4.dy)
      ..close();
    canvas.drawPath(pathRight, rightPaint);
    canvas.drawPath(pathRight, borderPaint);

    // Face Supérieure
    final Path pathTop = Path()
      ..moveTo(v1.dx, v1.dy)
      ..lineTo(v2.dx, v2.dy)
      ..lineTo(v0.dx, v0.dy)
      ..lineTo(v6.dx, v6.dy)
      ..close();
    canvas.drawPath(pathTop, topPaint);
    canvas.drawPath(pathTop, borderPaint);

    // Biseau lumineux sur les arêtes supérieures (effet Apple/Linear)
    final Paint highlightStroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(v1, v2, highlightStroke);
    canvas.drawLine(v1, v6, highlightStroke);

    // Rainure de pliage centrale du carton (sous le ruban)
    final Paint creasePaint = Paint()
      ..color = const Color(0xFF5A340F).withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(v1, v0, creasePaint);

    // Arête verticale avant avec ombre d'occlusion
    final Paint spineShadow = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(v0, v4, spineShadow);

    // ── 3. Ruban Adhésif Haute Fidélité ─────────────────────────────
    _drawTape(canvas, v0, v1, v2, v4, v6, s);

    // ── 4. Étiquette d'Expédition avec Code-Barres & Logo ─────────────
    _drawShippingLabel(canvas, v0, v6, v5, v4, s);

    // ── 5. Flèches de Manipulation & Tampon Fragile ──────────────────
    _drawHandlingMarks(canvas, v0, v2, v3, v4, s);
  }

  /// Dessine le ruban adhésif brillant avec reflet spéculaire et rabats 3D
  void _drawTape(
    Canvas canvas,
    Offset v0,
    Offset v1,
    Offset v2,
    Offset v4,
    Offset v6,
    double s,
  ) {
    final double tw = s * 0.22;

    // Dégradé spéculaire du ruban cyan Meta
    final Rect tapeRect = Rect.fromPoints(
      Offset(v1.dx - tw * _cos30, v1.dy),
      Offset(v0.dx + tw * _cos30, v0.dy),
    );
    final Paint tapePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          tapeColor.withValues(alpha: 0.88),
          const Color(0xFF67E8F9),
          tapeColor,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(tapeRect);

    // Ruban sur la face supérieure
    final Path topTape = Path()
      ..moveTo(v1.dx - tw * _cos30, v1.dy + tw * _sin30)
      ..lineTo(v1.dx + tw * _cos30, v1.dy + tw * _sin30)
      ..lineTo(v0.dx + tw * _cos30, v0.dy - tw * _sin30)
      ..lineTo(v0.dx - tw * _cos30, v0.dy - tw * _sin30)
      ..close();
    canvas.drawPath(topTape, tapePaint);

    // Ligne centrale de brillance brillante
    final Paint tapeGleam = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.10),
          Colors.white.withValues(alpha: 0.65),
          Colors.white.withValues(alpha: 0.15),
        ],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(tapeRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawLine(
      Offset(v1.dx, v1.dy + 1.0),
      Offset(v0.dx, v0.dy - 1.0),
      tapeGleam,
    );

    // Rabat du ruban sur la face avant-gauche avec micro-ombre
    final double tabLen = s * 0.24;
    final Path frontTab = Path()
      ..moveTo(v0.dx - tw * _cos30, v0.dy - tw * _sin30)
      ..lineTo(v0.dx, v0.dy)
      ..lineTo(v0.dx, v0.dy + tabLen)
      ..lineTo(v0.dx - tw * _cos30, v0.dy + tabLen - tw * _sin30)
      ..close();

    // Ombre sous le rabat pour relief 3D
    canvas.drawPath(
      frontTab.shift(const Offset(0.8, 1.2)),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );
    canvas.drawPath(
      frontTab,
      Paint()
        ..shader = LinearGradient(
          colors: [
            tapeColor.withValues(alpha: 0.95),
            tapeColor.withValues(alpha: 0.80),
          ],
        ).createShader(frontTab.getBounds()),
    );

    // Petit rabat face droite
    final Path frontTabRight = Path()
      ..moveTo(v0.dx, v0.dy)
      ..lineTo(v0.dx + tw * _cos30, v0.dy - tw * _sin30)
      ..lineTo(v0.dx + tw * _cos30, v0.dy + tabLen - tw * _sin30)
      ..lineTo(v0.dx, v0.dy + tabLen)
      ..close();
    canvas.drawPath(
      frontTabRight,
      Paint()..color = tapeColor.withValues(alpha: 0.68),
    );
  }

  /// Dessine une étiquette d'expédition avec ombre portée, code-barres net et tampon
  void _drawShippingLabel(
    Canvas canvas,
    Offset v0,
    Offset v6,
    Offset v5,
    Offset v4,
    double s,
  ) {
    final double lx = (v0.dx + v6.dx + v5.dx + v4.dx) / 4;
    final double ly = (v0.dy + v6.dy + v5.dy + v4.dy) / 4 + s * 0.04;

    final double lw = s * 0.38;
    final double lh = s * 0.32;

    final Offset p1 = Offset(lx - lw * _cos30, ly - lw * _sin30 - lh * 0.5);
    final Offset p2 = Offset(lx + lw * _cos30, ly + lw * _sin30 - lh * 0.5);
    final Offset p3 = Offset(lx + lw * _cos30, ly + lw * _sin30 + lh * 0.5);
    final Offset p4 = Offset(lx - lw * _cos30, ly - lw * _sin30 + lh * 0.5);

    final Path labelPath = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();

    // 1. Ombre portée douce sous l'étiquette
    canvas.drawPath(
      labelPath.shift(const Offset(1.2, 1.8)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8),
    );

    // 2. Fond blanc de l'étiquette avec léger dégradé satiné
    final Paint labelSurface = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Colors.white, Color(0xFFF8FAFC)],
      ).createShader(labelPath.getBounds());
    canvas.drawPath(labelPath, labelSurface);

    // Fine bordure d'étiquette
    canvas.drawPath(
      labelPath,
      Paint()
        ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.70)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );

    // 3. Mini badge cyan "EXPRESS" en haut à gauche
    final Offset badgeOrigin = Offset(lx - lw * 0.55 * _cos30, ly - lh * 0.28);
    final Paint badgePaint = Paint()
      ..color = AppTheme.primaryIcons
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(badgeOrigin.dx, badgeOrigin.dy, s * 0.16, s * 0.06),
        const Radius.circular(2),
      ),
      badgePaint,
    );

    // Micro QR-Code carré à droite
    final Offset qrPos = Offset(lx + lw * 0.25 * _cos30, ly - lh * 0.28);
    final Paint darkStamp = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromLTWH(qrPos.dx, qrPos.dy, 4.5, 4.5), darkStamp);
    canvas.drawRect(Rect.fromLTWH(qrPos.dx + 1.2, qrPos.dy + 1.2, 2.1, 2.1), Paint()..color = Colors.white);

    // 4. Lignes de code-barres réalistes (variations d'épaisseurs)
    final Paint thinBar = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final Paint thickBar = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final double startY = ly - lh * 0.05;
    final double endY = ly + lh * 0.38;
    final int barCount = 7;

    for (int i = 0; i < barCount; i++) {
      final double progress = (i + 0.5) / barCount;
      final double currentY = startY + progress * (endY - startY);
      final Offset b1 = Offset(lx - lw * 0.62 * _cos30, currentY - lw * 0.20 * _sin30);
      final Offset b2 = Offset(lx + lw * 0.62 * _cos30, currentY + lw * 0.20 * _sin30);

      // Alternance de lignes épaisses et fines
      final Paint currentPaint = (i == 1 || i == 4 || i == 6) ? thickBar : thinBar;
      canvas.drawLine(b1, b2, currentPaint);
    }
  }

  /// Dessine les flèches de manipulation et un tampon "Fragile"
  void _drawHandlingMarks(
    Canvas canvas,
    Offset v0,
    Offset v2,
    Offset v3,
    Offset v4,
    double s,
  ) {
    final double rx = (v0.dx + v2.dx + v3.dx + v4.dx) / 4;
    final double ry = (v0.dy + v2.dy + v3.dy + v4.dy) / 4 + s * 0.04;

    final Color stampColor = style == ColisStyle.kraft
        ? const Color(0xFF5C3311).withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.45);

    final Paint stampPaint = Paint()
      ..color = stampColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    // Deux flèches "This Way Up" (↑ ↑)
    void drawArrowAt(double ox) {
      final double ax = rx + ox;
      final double ay = ry - s * 0.04;
      final double len = s * 0.20;

      // Tige
      canvas.drawLine(Offset(ax, ay + len * 0.5), Offset(ax, ay - len * 0.5), stampPaint);
      // Pointe
      canvas.drawLine(Offset(ax - 2.5, ay - len * 0.5 + 3.0), Offset(ax, ay - len * 0.5), stampPaint);
      canvas.drawLine(Offset(ax + 2.5, ay - len * 0.5 + 3.0), Offset(ax, ay - len * 0.5), stampPaint);
    }

    drawArrowAt(-s * 0.13);
    drawArrowAt(s * 0.13);

    // Tampon miniature d'un verre "Fragile" en dessous
    final double glassY = ry + s * 0.18;
    canvas.drawLine(Offset(rx - 3, glassY), Offset(rx + 3, glassY), stampPaint); // coupe
    canvas.drawLine(Offset(rx, glassY), Offset(rx, glassY + 4), stampPaint); // pied
    canvas.drawLine(Offset(rx - 2.5, glassY + 4), Offset(rx + 2.5, glassY + 4), stampPaint); // socle
  }

  /// Dessine le balayage laser volumétrique holographique
  void _drawScannerBeam(Canvas canvas, double s, double progress) {
    final double minY = -s * 2.15;
    final double maxY = s * 0.05;
    final double beamY = minY + progress * (maxY - minY);

    final double beamWidth = s * 2.3;
    final double fanHeight = 12.0;

    // 1. Voile volumétrique cyan (fan laser)
    final Rect fanRect = Rect.fromCenter(
      center: Offset(0, beamY),
      width: beamWidth,
      height: fanHeight * 2,
    );
    final Paint fanPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFF22B7CE).withValues(alpha: 0.18),
          const Color(0xFF6DD5ED).withValues(alpha: 0.40),
          const Color(0xFF22B7CE).withValues(alpha: 0.18),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.50, 0.65, 1.0],
      ).createShader(fanRect)
      ..style = PaintingStyle.fill;
    canvas.drawRect(fanRect, fanPaint);

    // 2. Faisceau laser intense
    final Paint beamPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF22B7CE).withValues(alpha: 0.65),
          const Color(0xFF6DD5ED),
          Colors.white,
          const Color(0xFF6DD5ED),
          const Color(0xFF22B7CE).withValues(alpha: 0.65),
          Colors.transparent,
        ],
        stops: const [0.0, 0.20, 0.40, 0.50, 0.60, 0.80, 1.0],
      ).createShader(Rect.fromCenter(center: Offset(0, beamY), width: beamWidth, height: 4.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawLine(Offset(-beamWidth * 0.48, beamY), Offset(beamWidth * 0.48, beamY), beamPaint);

    // Cœur blanc pur au centre
    final Paint corePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-beamWidth * 0.35, beamY), Offset(beamWidth * 0.35, beamY), corePaint);

    // Éclats lumineux aux deux extrémités du laser
    final Paint flarePaint = Paint()
      ..color = const Color(0xFF6DD5ED).withValues(alpha: 0.70)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-beamWidth * 0.45, beamY), 2.2, flarePaint);
    canvas.drawCircle(Offset(beamWidth * 0.45, beamY), 2.2, flarePaint);
  }

  /// Dessine l'anneau orbital céleste avec comète pulsante et étoiles filantes
  void _drawOrbit({
    required Canvas canvas,
    required double cx,
    required double cy,
    required double radiusX,
    required double radiusY,
    required double progress,
    required bool isBack,
  }) {
    final Rect orbitRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: radiusX * 2,
      height: radiusY * 2,
    );

    final double headAngle = progress * 2 * math.pi;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-0.20); // Alignement à l'angle isométrique
    canvas.translate(-cx, -cy);

    // Piste de guidage lumineuse
    final Paint trackPaint = Paint()
      ..color = AppTheme.primaryIcons.withValues(alpha: isBack ? 0.08 : 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawArc(orbitRect, isBack ? math.pi : 0.0, math.pi, false, trackPaint);

    // Traîne lumineuse de la comète
    final double normalizedAngle = headAngle % (2 * math.pi);
    final bool headInThisHalf = isBack
        ? (normalizedAngle >= math.pi && normalizedAngle < 2 * math.pi)
        : (normalizedAngle >= 0.0 && normalizedAngle < math.pi);

    if (headInThisHalf) {
      final double trailLength = math.pi * 0.85;
      final double trailStart = normalizedAngle - trailLength;

      final Paint trailPaint = Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: 0.0,
          endAngle: 2 * math.pi,
          colors: [
            Colors.transparent,
            AppTheme.accentCyan.withValues(alpha: isBack ? 0.25 : 0.45),
            AppTheme.primaryIcons.withValues(alpha: isBack ? 0.55 : 0.90),
            Colors.white,
          ],
          stops: const [0.0, 0.35, 0.75, 1.0],
          transform: GradientRotation(trailStart),
        ).createShader(orbitRect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.4;

      canvas.drawArc(orbitRect, trailStart, trailLength, false, trailPaint);

      // Tête de la comète avec halo pulsant
      final double pulse = 1.0 + 0.25 * math.sin(progress * 8 * math.pi);
      final double headX = cx + radiusX * math.cos(normalizedAngle);
      final double headY = cy + radiusY * math.sin(normalizedAngle);

      // Halo externe
      final Paint outerGlow = Paint()
        ..color = const Color(0xFF6DD5ED).withValues(alpha: isBack ? 0.20 : 0.40)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(headX, headY), 6.5 * pulse, outerGlow);

      // Cœur turquoise
      final Paint midGlow = Paint()
        ..color = AppTheme.primaryIcons
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(headX, headY), 3.2, midGlow);

      // Étincelle blanche centrale
      final Paint coreGlow = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(headX, headY), 1.6, coreGlow);

      // 3 Micro-étoiles / poussières scintillantes en traîne
      for (int i = 1; i <= 3; i++) {
        final double starAngle = normalizedAngle - (i * 0.18);
        final double starX = cx + radiusX * math.cos(starAngle);
        final double starY = cy + radiusY * math.sin(starAngle);
        final double starAlpha = (1.0 - i * 0.25) * (isBack ? 0.40 : 0.85);

        final Paint starPaint = Paint()
          ..color = const Color(0xFF6DD5ED).withValues(alpha: starAlpha)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(starX, starY), 1.2, starPaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ColisPainter oldDelegate) {
    return oldDelegate.bounceProgress != bounceProgress ||
        oldDelegate.orbitProgress != orbitProgress ||
        oldDelegate.scannerProgress != scannerProgress ||
        oldDelegate.style != style ||
        oldDelegate.tapeColor != tapeColor;
  }
}
