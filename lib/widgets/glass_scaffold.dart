import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/config_controller.dart';
import '../theme/app_theme.dart';

class GlassScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool extendBodyBehindAppBar;
  final bool resizeToAvoidBottomInset;
  final bool isLight;

  const GlassScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset = true,
    this.isLight = true,
  });

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: isLight ? AppTheme.bgLight : AppTheme.bgDark,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          // Base Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: isLight ? AppTheme.lightBackgroundGradient : AppTheme.backgroundGradient,
            ),
          ),

          // Luminous Ambient Glow Orbs (Dynamic API Colors: Yellow, Green & Blue with Fallback)
          Builder(
            builder: (context) {
              final configCtrl = Get.isRegistered<ConfigController>()
                  ? Get.find<ConfigController>()
                  : null;

              Widget buildOrbs() {
                final pColor = configCtrl?.primaryColor ?? AppTheme.primary;
                final sColor = configCtrl?.secondaryColor ?? AppTheme.primaryIcons;
                final oColor = configCtrl?.optionalColor ?? const Color(0xFFFDEB03);
                final hasCustom = configCtrl?.hasCustomColors ?? false;

                if (isLight) {
                  return Stack(
                    children: [
                      // Top-Right Orb (Yellow API accent if custom, else cyan)
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
                                (hasCustom ? oColor : AppTheme.primaryIcons).withOpacity(0.16),
                                (hasCustom ? oColor : AppTheme.primaryIcons).withOpacity(0.04),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.50, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Soft Green Orb middle-left
                      Positioned(
                        top: 220,
                        left: -70,
                        child: Container(
                          width: 270,
                          height: 270,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                (hasCustom ? sColor : AppTheme.primary).withOpacity(0.14),
                                (hasCustom ? sColor : AppTheme.primary).withOpacity(0.03),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.50, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Soft Blue Orb bottom-right
                      Positioned(
                        bottom: 30,
                        right: 20,
                        child: Container(
                          width: 290,
                          height: 290,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                (hasCustom ? pColor : const Color(0xFF38BDF8)).withOpacity(0.12),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.60],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Stack(
                    children: [
                      // Top-Right: Warm Yellow Glowing Orb
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
                                (hasCustom ? oColor : AppTheme.primary).withOpacity(0.24),
                                (hasCustom ? oColor : AppTheme.primary).withOpacity(0.06),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.50, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Middle-Left: Emerald Green Glowing Orb behind the card
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
                                (hasCustom ? sColor : AppTheme.primaryIcons).withOpacity(0.25),
                                (hasCustom ? sColor : AppTheme.primaryIcons).withOpacity(0.07),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.50, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Top-Left: Subtle Green glow above logos
                      Positioned(
                        top: -40,
                        left: -40,
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                (hasCustom ? sColor : AppTheme.primaryIcons).withOpacity(0.18),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.55],
                            ),
                          ),
                        ),
                      ),
                      // Bottom-Right: Royal Blue Glowing Orb behind footer
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
                                (hasCustom ? pColor : AppTheme.primary).withOpacity(0.28),
                                (hasCustom ? pColor : AppTheme.primary).withOpacity(0.08),
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
              }

              if (configCtrl != null) {
                return Obx(() => buildOrbs());
              }
              return buildOrbs();
            },
          ),

          // Page Content
          SafeArea(
            child: body,
          ),
        ],
      ),
    );

    return Theme(
      data: isLight ? AppTheme.lightTheme : AppTheme.darkTheme,
      child: scaffold,
    );
  }
}
