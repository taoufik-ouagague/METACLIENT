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
/// - Colis isométrique 3D réaliste (texture kraft/brand, ruban adhésif, étiquette d'expédition avec code-barres, flèches de manipulation)
/// - Rebond fluide avec squash & stretch
/// - Anneau orbital lumineux en rotation 360° (effet spinner)
/// - Faisceau laser cyan de scan automatique (effet tracking hub)
/// - Ombre dynamique au sol synchronisée avec le saut
/// - Particules d'impact légères à l'atterrissage
/// - Texte de statut animé en option
class ColisLoader extends StatefulWidget {
  const ColisLoader({
    super.key,
    this.size = 64,
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

    // 1. Rebond du colis avec squash & stretch (~1200ms)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..repeat();

    // 2. Rotation continue de l'anneau orbital (~1500ms)
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // 3. Balayage laser vertical (~1600ms en va-et-vient)
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.disposeDisposeSafe();
    _orbitController.disposeDisposeSafe();
    _scannerController.disposeDisposeSafe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double boxSize = widget.size;
    final double totalHeight = widget.showShadow ? boxSize * 1.35 : boxSize;
    final double totalWidth = widget.size * 1.4;

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

extension on AnimationController {
  void disposeDisposeSafe() {
    dispose();
  }
}

/// Peintre vectoriel du colis 3D isométrique avec ses effets
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
    // La base du sol est positionnée vers le bas du canvas
    final double groundY = size.height * 0.78;

    // Rayon / demi-arête du cube isométrique
    final double cubeS = size.width * 0.22;
    final double jumpHeight = cubeS * 0.95;

    // ─── 1. Calcul du Rebond & Squash/Stretch ─────────────────────────
    // Phase 0.0 -> 0.45 : Montée avec amorti
    // Phase 0.45 -> 0.55 : Flottement au sommet (hover)
    // Phase 0.55 -> 0.86 : Chute rapide
    // Phase 0.86 -> 0.94 : Impact et écrasement (squash)
    // Phase 0.94 -> 1.00 : Rétablissement (stretch de rebond)

    double dy = 0.0;
    double scaleX = 1.0;
    double scaleY = 1.0;
    double shadowScale = 1.0;
    double shadowOpacity = 0.32;
    double tiltAngle = 0.0;

    final double t = bounceProgress;
    if (t < 0.45) {
      // Montée
      final double progress = t / 0.45;
      final double eased = Curves.easeOutCubic.transform(progress);
      dy = -jumpHeight * eased;
      scaleY = 1.0 + 0.10 * (1.0 - progress);
      scaleX = 1.0 - 0.06 * (1.0 - progress);
      shadowScale = 1.0 - 0.35 * eased;
      shadowOpacity = 0.32 - 0.17 * eased;
      tiltAngle = 0.06 * math.sin(progress * math.pi);
    } else if (t < 0.55) {
      // Sommet
      final double progress = (t - 0.45) / 0.10;
      dy = -jumpHeight + math.sin(progress * math.pi) * 2.0;
      scaleX = 1.0;
      scaleY = 1.0;
      shadowScale = 0.65;
      shadowOpacity = 0.15;
      tiltAngle = 0.04 * (1.0 - progress);
    } else if (t < 0.86) {
      // Chute
      final double progress = (t - 0.55) / 0.31;
      final double eased = Curves.easeInQuad.transform(progress);
      dy = -jumpHeight * (1.0 - eased);
      scaleY = 1.0 + 0.12 * eased;
      scaleX = 1.0 - 0.07 * eased;
      shadowScale = 0.65 + 0.35 * eased;
      shadowOpacity = 0.15 + 0.17 * eased;
      tiltAngle = -0.04 * eased;
    } else if (t < 0.94) {
      // Impact & Squash
      final double progress = (t - 0.86) / 0.08;
      final double squashFactor = math.sin(progress * math.pi);
      dy = 0.0;
      scaleY = 1.0 - 0.18 * squashFactor;
      scaleX = 1.0 + 0.15 * squashFactor;
      shadowScale = 1.0 + 0.25 * squashFactor;
      shadowOpacity = 0.32 + 0.18 * squashFactor;
      tiltAngle = 0.0;
    } else {
      // Rétablissement
      final double progress = (t - 0.94) / 0.06;
      dy = 0.0;
      scaleY = 1.0 - 0.04 * (1.0 - progress);
      scaleX = 1.0 + 0.03 * (1.0 - progress);
      shadowScale = 1.0;
      shadowOpacity = 0.32;
      tiltAngle = 0.0;
    }

    // ─── 2. Ombre au sol ─────────────────────────────────────────────
    if (showShadow) {
      _drawShadow(canvas, cx, groundY, cubeS, shadowScale, shadowOpacity);
    }

    // ─── 3. Particules d'impact ──────────────────────────────────────
    if (t >= 0.86 && t <= 0.98) {
      _drawImpactDust(canvas, cx, groundY, cubeS, (t - 0.86) / 0.12);
    }

    // ─── 4. Anneau orbital (Partie Arrière) ───────────────────────────
    if (showOrbit) {
      _drawOrbit(
        canvas: canvas,
        cx: cx,
        cy: groundY - cubeS * 1.1 + dy,
        radiusX: cubeS * 1.65,
        radiusY: cubeS * 0.58,
        progress: orbitProgress,
        isBack: true,
      );
    }

    // ─── 5. Dessin du Colis 3D avec Transformations ──────────────────
    canvas.save();
    // Le point d'ancrage pour le squash est le bas du colis
    final double boxBaseY = groundY;
    canvas.translate(cx, boxBaseY + dy);
    canvas.rotate(tiltAngle);
    canvas.scale(scaleX, scaleY);

    // Dessiner le colis avec son centre d'origine en (0, -cubeS * 1.15)
    _drawBox(canvas, Offset.zero, cubeS);

    // ─── 6. Faisceau Laser de Scan (Optionnel) ────────────────────────
    if (showScanner) {
      _drawScannerBeam(canvas, cubeS, scannerProgress);
    }

    canvas.restore();

    // ─── 7. Anneau orbital (Partie Avant) ────────────────────────────
    if (showOrbit) {
      _drawOrbit(
        canvas: canvas,
        cx: cx,
        cy: groundY - cubeS * 1.1 + dy,
        radiusX: cubeS * 1.65,
        radiusY: cubeS * 0.58,
        progress: orbitProgress,
        isBack: false,
      );
    }
  }

  /// Dessine l'ombre elliptique douce projetée au sol
  void _drawShadow(
    Canvas canvas,
    double cx,
    double groundY,
    double cubeS,
    double scale,
    double opacity,
  ) {
    final double rx = cubeS * 1.25 * scale;
    final double ry = cubeS * 0.40 * scale;

    final Rect rect = Rect.fromCenter(
      center: Offset(cx, groundY + 4),
      width: rx * 2,
      height: ry * 2,
    );

    final Paint shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color(0xFF0F172A).withValues(alpha: opacity.clamp(0.0, 0.6)),
          Color(0xFF0F172A).withValues(alpha: (opacity * 0.4).clamp(0.0, 0.4)),
          Color(0xFF0F172A).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);

    canvas.drawOval(rect, shadowPaint);
  }

  /// Dessine deux petites fumerolles / poussières d'impact lors du contact au sol
  void _drawImpactDust(
    Canvas canvas,
    double cx,
    double groundY,
    double cubeS,
    double progress,
  ) {
    final double alpha = (1.0 - progress).clamp(0.0, 1.0);
    if (alpha <= 0.0) return;

    final Paint dustPaint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: alpha * 0.35)
      ..style = PaintingStyle.fill;

    final double spread = cubeS * 0.9 + progress * (cubeS * 0.5);
    final double r = 3.5 * (1.0 - progress * 0.5);

    // Puff gauche
    canvas.drawCircle(Offset(cx - spread, groundY), r, dustPaint);
    canvas.drawCircle(Offset(cx - spread * 0.85, groundY - 2), r * 0.7, dustPaint);

    // Puff droite
    canvas.drawCircle(Offset(cx + spread, groundY), r, dustPaint);
    canvas.drawCircle(Offset(cx + spread * 0.85, groundY - 2), r * 0.7, dustPaint);
  }

  /// Dessine le cube isométrique (les 3 faces, le ruban adhésif, le code-barres et les flèches)
  void _drawBox(Canvas canvas, Offset base, double s) {
    // Coordonnées du centre haut de projection
    // V0 est le sommet central (vers l'avant)
    final double vy = -s * 1.15;
    final Offset v0 = Offset(0, vy);
    final Offset v1 = Offset(0, vy - s); // Sommet supérieur
    final Offset v2 = Offset(s * _cos30, vy - s * _sin30); // Sommet haut-droite
    final Offset v3 = Offset(s * _cos30, vy + s * (1 - _sin30)); // Bas-droite
    final Offset v4 = Offset(0, vy + s); // Bas-centre (le plus proche en bas)
    final Offset v5 = Offset(-s * _cos30, vy + s * (1 - _sin30)); // Bas-gauche
    final Offset v6 = Offset(-s * _cos30, vy - s * _sin30); // Haut-gauche

    // Palette selon le style choisi
    final Color topColor;
    final Color leftColor;
    final Color rightColor;
    final Color strokeColor;

    if (style == ColisStyle.kraft) {
      // Carton kraft naturel réaliste
      topColor = const Color(0xFFE8C8A0); // Face supérieure (lumière zénithale)
      leftColor = const Color(0xFFD6A974); // Face gauche (lumière latérale)
      rightColor = const Color(0xFFBC8C56); // Face droite (ombrée)
      strokeColor = const Color(0xFF8B5E34).withValues(alpha: 0.35);
    } else {
      // Style High-Tech Cyan Brand
      topColor = const Color(0xFF2CBBD6);
      leftColor = const Color(0xFF1F94B0);
      rightColor = const Color(0xFF14738C);
      strokeColor = const Color(0xFF6DD5ED).withValues(alpha: 0.50);
    }

    final Paint borderPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeJoin = StrokeJoin.round;

    // ── A. Face Gauche ──────────────────────────────────────────────
    final Path pathLeft = Path()
      ..moveTo(v0.dx, v0.dy)
      ..lineTo(v6.dx, v6.dy)
      ..lineTo(v5.dx, v5.dy)
      ..lineTo(v4.dx, v4.dy)
      ..close();
    canvas.drawPath(pathLeft, Paint()..color = leftColor);
    canvas.drawPath(pathLeft, borderPaint);

    // ── B. Face Droite ─────────────────────────────────────────────
    final Path pathRight = Path()
      ..moveTo(v0.dx, v0.dy)
      ..lineTo(v2.dx, v2.dy)
      ..lineTo(v3.dx, v3.dy)
      ..lineTo(v4.dx, v4.dy)
      ..close();
    canvas.drawPath(pathRight, Paint()..color = rightColor);
    canvas.drawPath(pathRight, borderPaint);

    // ── C. Face Supérieure ──────────────────────────────────────────
    final Path pathTop = Path()
      ..moveTo(v1.dx, v1.dy)
      ..lineTo(v2.dx, v2.dy)
      ..lineTo(v0.dx, v0.dy)
      ..lineTo(v6.dx, v6.dy)
      ..close();
    canvas.drawPath(pathTop, Paint()..color = topColor);
    canvas.drawPath(pathTop, borderPaint);

    // ── D. Ruban Adhésif (Packing Tape) ─────────────────────────────
    _drawTape(canvas, v0, v1, v2, v4, v6, s);

    // ── E. Étiquette avec Code-barres sur la Face Gauche ────────────
    _drawShippingLabel(canvas, v0, v6, v5, v4, s);

    // ── F. Flèches de Manipulation "Haut" (↑↑) sur la Face Droite ───
    _drawHandlingArrows(canvas, v0, v2, v3, v4, s);
  }

  /// Dessine le ruban adhésif qui scelle le carton
  void _drawTape(
    Canvas canvas,
    Offset v0,
    Offset v1,
    Offset v2,
    Offset v4,
    Offset v6,
    double s,
  ) {
    final double tw = s * 0.22; // demi-largeur du ruban

    // Ruban sur la face supérieure (de v1 à v0)
    final Path topTape = Path()
      ..moveTo(v1.dx - tw * _cos30, v1.dy + tw * _sin30)
      ..lineTo(v1.dx + tw * _cos30, v1.dy + tw * _sin30)
      ..lineTo(v0.dx + tw * _cos30, v0.dy - tw * _sin30)
      ..lineTo(v0.dx - tw * _cos30, v0.dy - tw * _sin30)
      ..close();

    final Paint tapePaint = Paint()
      ..color = tapeColor.withValues(alpha: 0.90)
      ..style = PaintingStyle.fill;

    canvas.drawPath(topTape, tapePaint);

    // Ligne de reflet brillante au centre du ruban
    final Paint tapeHighlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(v1, v0, tapeHighlight);

    // Rabattement du ruban sur la face avant-gauche (un petit bout qui dépasse)
    final double tabLen = s * 0.22;
    final Path frontTab = Path()
      ..moveTo(v0.dx - tw * _cos30, v0.dy - tw * _sin30)
      ..lineTo(v0.dx, v0.dy)
      ..lineTo(v0.dx, v0.dy + tabLen)
      ..lineTo(v0.dx - tw * _cos30, v0.dy + tabLen - tw * _sin30)
      ..close();
    canvas.drawPath(frontTab, Paint()..color = tapeColor.withValues(alpha: 0.85));

    final Path frontTabRight = Path()
      ..moveTo(v0.dx, v0.dy)
      ..lineTo(v0.dx + tw * _cos30, v0.dy - tw * _sin30)
      ..lineTo(v0.dx + tw * _cos30, v0.dy + tabLen - tw * _sin30)
      ..lineTo(v0.dx, v0.dy + tabLen)
      ..close();
    canvas.drawPath(frontTabRight, Paint()..color = tapeColor.withValues(alpha: 0.72));
  }

  /// Dessine une étiquette blanche miniature d'expédition avec lignes de code-barres
  void _drawShippingLabel(
    Canvas canvas,
    Offset v0,
    Offset v6,
    Offset v5,
    Offset v4,
    double s,
  ) {
    // Calcul du centre de la face gauche
    final double lx = (v0.dx + v6.dx + v5.dx + v4.dx) / 4;
    final double ly = (v0.dy + v6.dy + v5.dy + v4.dy) / 4 + s * 0.05;

    // Dimensions de l'étiquette
    final double lw = s * 0.38;
    final double lh = s * 0.32;

    // Coins isométriques de l'étiquette sur le plan de la face gauche
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

    // Fond étiquette blanc pur avec légère ombre
    canvas.drawPath(
      labelPath,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );

    // Petit carré logo / QR code miniature cyan en haut à gauche
    final Paint qrPaint = Paint()
      ..color = AppTheme.primaryIcons
      ..style = PaintingStyle.fill;
    final Offset qrCenter = Offset(lx - lw * 0.45 * _cos30, ly - lh * 0.25);
    canvas.drawCircle(qrCenter, 1.8, qrPaint);

    // Lignes de code-barres stylisées
    final Paint barPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 4; i++) {
      final double offsetY = (i - 1.5) * (lh * 0.18) + lh * 0.12;
      final Offset b1 = Offset(lx - lw * 0.55 * _cos30, ly + offsetY - lw * 0.2 * _sin30);
      final Offset b2 = Offset(lx + lw * 0.55 * _cos30, ly + offsetY + lw * 0.2 * _sin30);
      canvas.drawLine(b1, b2, barPaint);
    }
  }

  /// Dessine les flèches de manipulation universelles "This Side Up" (↑↑)
  void _drawHandlingArrows(
    Canvas canvas,
    Offset v0,
    Offset v2,
    Offset v3,
    Offset v4,
    double s,
  ) {
    final double rx = (v0.dx + v2.dx + v3.dx + v4.dx) / 4;
    final double ry = (v0.dy + v2.dy + v3.dy + v4.dy) / 4 + s * 0.05;

    final Color arrowColor = style == ColisStyle.kraft
        ? const Color(0xFF6B451C).withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.40);

    final Paint arrowPaint = Paint()
      ..color = arrowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    void drawArrowAt(double offsetX) {
      final double ax = rx + offsetX;
      final double ay = ry;
      final double len = s * 0.22;

      // Tige verticale
      canvas.drawLine(Offset(ax, ay + len * 0.5), Offset(ax, ay - len * 0.5), arrowPaint);
      // Tête de flèche
      canvas.drawLine(Offset(ax - 2.5, ay - len * 0.5 + 3.0), Offset(ax, ay - len * 0.5), arrowPaint);
      canvas.drawLine(Offset(ax + 2.5, ay - len * 0.5 + 3.0), Offset(ax, ay - len * 0.5), arrowPaint);
    }

    drawArrowAt(-s * 0.12);
    drawArrowAt(s * 0.12);
  }

  /// Dessine le balayage laser cyan (faisceau de lecteur code-barres de hub)
  void _drawScannerBeam(Canvas canvas, double s, double progress) {
    // Le faisceau balaye de haut en bas sur toute la hauteur du colis
    final double minY = -s * 2.1;
    final double maxY = 0.0;
    final double beamY = minY + progress * (maxY - minY);

    final double beamWidth = s * 2.2;
    final Rect beamRect = Rect.fromCenter(
      center: Offset(0, beamY),
      width: beamWidth,
      height: 6.0,
    );

    // Lueur diffuse du laser
    final Paint glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF22B7CE).withValues(alpha: 0.0),
          const Color(0xFF22B7CE).withValues(alpha: 0.40),
          const Color(0xFF6DD5ED).withValues(alpha: 0.90),
          const Color(0xFF22B7CE).withValues(alpha: 0.40),
          const Color(0xFF22B7CE).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(beamRect)
      ..style = PaintingStyle.fill;

    canvas.drawRect(beamRect, glowPaint);

    // Cœur laser intense au milieu
    final Paint corePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(-beamWidth * 0.40, beamY),
      Offset(beamWidth * 0.40, beamY),
      corePaint,
    );
  }

  /// Dessine l'anneau orbital lumineux qui tourne autour du colis (partie avant ou arrière)
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

    // On sépare l'ellipse en demi-plan arrière (y < cy, -pi à 0) et avant (y >= cy, 0 à pi)
    // L'angle courant de la tête lumineuse
    final double headAngle = progress * 2 * math.pi;

    canvas.save();
    // Inclinaison de l'orbite de -12 degrés pour correspondre à l'angle isométrique
    canvas.translate(cx, cy);
    canvas.rotate(-0.20);
    canvas.translate(-cx, -cy);

    // Tracé de l'arc correspondant à l'avant ou à l'arrière
    final double sweepStart = isBack ? math.pi : 0.0;
    const double sweepLength = math.pi;

    // Anneau de fond subtil
    final Paint trackPaint = Paint()
      ..color = AppTheme.primaryIcons.withValues(alpha: isBack ? 0.08 : 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawArc(orbitRect, sweepStart, sweepLength, false, trackPaint);

    // Tête lumineuse (comète de chargement)
    final double normalizedAngle = headAngle % (2 * math.pi);
    final bool headInThisHalf = isBack
        ? (normalizedAngle >= math.pi && normalizedAngle < 2 * math.pi)
        : (normalizedAngle >= 0.0 && normalizedAngle < math.pi);

    if (headInThisHalf) {
      final double trailLength = math.pi * 0.75;
      final double trailStart = normalizedAngle - trailLength;

      final Paint trailPaint = Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: 0.0,
          endAngle: 2 * math.pi,
          colors: [
            AppTheme.accentCyan.withValues(alpha: 0.0),
            AppTheme.primaryIcons.withValues(alpha: isBack ? 0.4 : 0.8),
            Colors.white,
          ],
          transform: GradientRotation(trailStart),
        ).createShader(orbitRect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.4;

      canvas.drawArc(orbitRect, trailStart, trailLength, false, trailPaint);

      // Point éclatant en tête de comète
      final double headX = cx + radiusX * math.cos(normalizedAngle);
      final double headY = cy + radiusY * math.sin(normalizedAngle);

      final Paint glowDot = Paint()
        ..color = AppTheme.accentCyan.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(headX, headY), 4.5, glowDot);

      final Paint centerDot = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(headX, headY), 2.0, centerDot);
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
