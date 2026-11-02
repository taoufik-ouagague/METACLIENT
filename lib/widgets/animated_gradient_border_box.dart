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
    this.borderWidth = 1.8,
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

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        final angle = _animController.value * 2 * math.pi;
        // Continuous moving linear gradient coordinates
        final begin = Alignment(math.cos(angle), math.sin(angle));
        final end = Alignment(math.cos(angle + math.pi), math.sin(angle + math.pi));

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: effectiveColors,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.borderWidth),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                math.max(0, widget.borderRadius - widget.borderWidth),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blur,
                  sigmaY: widget.blur,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    // Translucent frosted glass background identical to Splash screen
                    color: widget.backgroundColor ?? Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(
                      math.max(0, widget.borderRadius - widget.borderWidth),
                    ),
                  ),
                  padding: widget.padding,
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
