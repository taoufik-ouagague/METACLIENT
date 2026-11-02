import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/config_controller.dart';
import '../theme/app_theme.dart';

/// Arrière-plan ambiant partagé : dégradé doux et orbes lumineux subtils.
/// Posé sous le contenu des pages et du drawer pour un effet glassmorphism épuré.
class AmbientBackground extends StatelessWidget {
  final bool isLight;

  const AmbientBackground({super.key, this.isLight = true});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    Widget buildBackground() {
      final configCtrl = Get.isRegistered<ConfigController>()
          ? Get.find<ConfigController>()
          : null;

      final pColor = configCtrl?.primaryColor ?? AppTheme.primary;
      final sColor = configCtrl?.secondaryColor ?? AppTheme.primaryIcons;
      final oColor = configCtrl?.optionalColor ?? const Color(0xFFFDEB03);
      final hasCustom = configCtrl?.hasCustomColors ?? false;

      if (!isLight) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.backgroundGradient,
              ),
            ),
            // Top-right: Yellow Orb
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      (hasCustom ? oColor : AppTheme.primary).withValues(alpha: 0.24),
                      (hasCustom ? oColor : AppTheme.primary).withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.50, 1.0],
                  ),
                ),
              ),
            ),
            // Middle-left: Green Orb
            Positioned(
              top: 220,
              left: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      (hasCustom ? sColor : AppTheme.primaryIcons).withValues(alpha: 0.25),
                      (hasCustom ? sColor : AppTheme.primaryIcons).withValues(alpha: 0.07),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.50, 1.0],
                  ),
                ),
              ),
            ),
            // Bottom-right: Deep Blue Orb
            Positioned(
              bottom: -60,
              right: 20,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      (hasCustom ? pColor : AppTheme.primary).withValues(alpha: 0.28),
                      (hasCustom ? pColor : AppTheme.primary).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ],
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

          // 2. Orbes lumineux ambiants adaptatifs
          // Top-right: Yellow API accent
          Positioned(
            top: -60,
            right: -50,
            child: Container(
              width: 310,
              height: 310,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (hasCustom ? oColor : AppTheme.primaryIcons).withValues(alpha: 0.18),
                    (hasCustom ? oColor : AppTheme.primaryIcons).withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // Top-left: Green accent
          Positioned(
            top: 70,
            left: -60,
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (hasCustom ? sColor : AppTheme.primary).withValues(alpha: 0.14),
                    (hasCustom ? sColor : AppTheme.primary).withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.50, 1.0],
                ),
              ),
            ),
          ),

          // Center: Royal Blue accent
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
                    (hasCustom ? pColor : AppTheme.primaryIcons).withValues(alpha: 0.12),
                    (hasCustom ? pColor : const Color(0xFF38BDF8)).withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.50, 1.0],
                ),
              ),
            ),
          ),

          // Bottom-left: Green / Blue blend
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
                    (hasCustom ? sColor : AppTheme.primary).withValues(alpha: 0.13),
                    (hasCustom ? pColor : const Color(0xFF38BDF8)).withValues(alpha: 0.03),
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

    if (Get.isRegistered<ConfigController>()) {
      return Obx(() => buildBackground());
    }
    return buildBackground();
  }
}
