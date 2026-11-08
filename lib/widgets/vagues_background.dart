import 'package:flutter/material.dart';

/// Peintre personnalisé pour reproduire exactement les vagues organiques du mockup
class VaguesMockupPainter extends CustomPainter {
  const VaguesMockupPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final wavePaint1 = Paint()
      ..color = const Color(0xFFE2F3FD)
      ..style = PaintingStyle.fill;

    final wavePaint2 = Paint()
      ..color = const Color(0xFFD8EFFC)
      ..style = PaintingStyle.fill;

    // 1. Vague en haut à droite (Top-right wave)
    final pathTopRight = Path()
      ..moveTo(w, h * 0.19)
      ..cubicTo(w * 0.68, h * 0.22, w * 0.64, h * 0.29, w, h * 0.33)
      ..close();
    canvas.drawPath(pathTopRight, wavePaint1);

    // 2. Vague en bas à gauche (Bottom-left wave)
    final pathBottomLeft = Path()
      ..moveTo(0, h * 0.74)
      ..cubicTo(w * 0.34, h * 0.77, w * 0.38, h * 0.88, 0, h * 0.94)
      ..close();
    canvas.drawPath(pathBottomLeft, wavePaint1);

    // 3. Vague en bas à droite (Bottom-right wave)
    final pathBottomRight = Path()
      ..moveTo(w * 0.38, h)
      ..cubicTo(w * 0.58, h * 0.86, w * 0.80, h * 0.88, w, h * 0.81)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(pathBottomRight, wavePaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Arrière-plan épuré avec vagues organiques douces en cyan (style MetaClient).
class VaguesBackground extends StatelessWidget {
  const VaguesBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFF7FAFD),
        ),
        child: CustomPaint(
          painter: VaguesMockupPainter(),
        ),
      ),
    );
  }
}
