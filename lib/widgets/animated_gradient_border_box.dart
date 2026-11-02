import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedGradientBorderBox extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final List<Color> colors;
  final Color? backgroundColor;
  final double blur;

  const AnimatedGradientBorderBox({
    super.key,
    required this.child,
    this.width = 86,
    this.height = 86,
    this.borderRadius = 24,
    this.borderWidth = 1.4,
    this.padding = const EdgeInsets.all(12),
    required this.colors,
    this.backgroundColor,
    this.blur = 16.0,
  });

  @override
  State<AnimatedGradientBorderBox> createState() => _AnimatedGradientBorderBoxState();
}

class _AnimatedGradientBorderBoxState extends State<AnimatedGradientBorderBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColors = widget.colors.length >= 2
        ? widget.colors
        : [Colors.cyan, Colors.blue, Colors.greenAccent];

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Frosted Glass Box (100% authentic frosted glass identical to Splash screen)
          ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.blur,
                sigmaY: widget.blur,
              ),
              child: Container(
                width: widget.width,
                height: widget.height,
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: widget.child,
              ),
            ),
          ),

          // 2. Animated Gradient Border Stroke (Paints ONLY the 1.4px outer stroke, interior remains 100% transparent glass)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _GradientBorderPainter(
                      borderRadius: widget.borderRadius,
                      borderWidth: widget.borderWidth,
                      colors: effectiveColors,
                      animationValue: _animController.value,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double borderRadius;
  final double borderWidth;
  final List<Color> colors;
  final double animationValue;

  _GradientBorderPainter({
    required this.borderRadius,
    required this.borderWidth,
    required this.colors,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (borderWidth <= 0) return;

    final halfBorder = borderWidth / 2;
    final rect = Rect.fromLTWH(
      halfBorder,
      halfBorder,
      size.width - borderWidth,
      size.height - borderWidth,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(math.max(0, borderRadius - halfBorder)),
    );

    final angle = animationValue * 2 * math.pi;
    final begin = Alignment(math.cos(angle), math.sin(angle));
    final end = Alignment(math.cos(angle + math.pi), math.sin(angle + math.pi));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = LinearGradient(
        begin: begin,
        end: end,
        colors: colors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.colors != colors;
  }
}
