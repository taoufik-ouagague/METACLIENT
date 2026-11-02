import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Arrière-plan ambiant partagé : dégradé doux et orbes lumineux subtils.
/// Posé sous le contenu des pages et du drawer pour un effet glassmorphism épuré.
class AmbientBackground extends StatelessWidget {
  final bool isLight;

  const AmbientBackground({super.key, this.isLight = true});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    if (!isLight) {
      return Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Dégradé de fond subtil et lumineux
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEBF3FA), // Bleu glacier très doux
                Color(0xFFF8FAFC), // Blanc ardoise épuré
                Color(0xFFF0F6FB), // Nuance brand subtile
                Color(0xFFE8F2FA), // Base bleutée douce
              ],
              stops: [0.0, 0.35, 0.70, 1.0],
            ),
          ),
        ),

        // 2. Orbes lumineux ambiants
        Positioned(
          top: -60,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryIcons.withOpacity(0.18),
                  AppTheme.primaryIcons.withOpacity(0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),

        Positioned(
          top: 70,
          left: -60,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.12),
                  AppTheme.primary.withOpacity(0.03),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.50, 1.0],
              ),
            ),
          ),
        ),

        Positioned(
          top: size.height * 0.35,
          left: size.width * 0.20,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryIcons.withOpacity(0.14),
                  const Color(0xFF38BDF8).withOpacity(0.04),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.50, 1.0],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 30,
          left: -50,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.12),
                  const Color(0xFF38BDF8).withOpacity(0.04),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.50, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
