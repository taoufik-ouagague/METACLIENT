import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/config_controller.dart';
import '../theme/app_theme.dart';

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final LinearGradient? gradient;
  final Color? textColor;

  const GlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 52,
    this.gradient,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildContent(LinearGradient effectiveGradient, Color effectiveShadowColor) {
      return Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: effectiveGradient,
          boxShadow: [
            BoxShadow(
              color: effectiveShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isLoading ? null : onPressed,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: textColor ?? Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          text,
                          style: TextStyle(
                            color: textColor ?? Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    }

    // 1. Explicit gradient passed as parameter
    if (gradient != null) {
      return buildContent(gradient!, gradient!.colors.first.withValues(alpha: 0.35));
    }

    // 2. Dynamic config from API (if available) with fallback to normal color
    if (Get.isRegistered<ConfigController>()) {
      return Obx(() {
        final configCtrl = Get.find<ConfigController>();
        final effectiveGradient = configCtrl.buttonGradient;
        final effectiveShadow = configCtrl.primaryColor.withValues(alpha: 0.35);
        return buildContent(effectiveGradient, effectiveShadow);
      });
    }

    // 3. Fallback normal theme
    return buildContent(AppTheme.primaryGradient, AppTheme.primary.withValues(alpha: 0.35));
  }
}
