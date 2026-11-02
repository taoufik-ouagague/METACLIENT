import 'package:flutter/material.dart';
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

          // Luminous Ambient Glow Orbs
          if (isLight) ...[
            // Subtle Cyan Orb top-right
            Positioned(
              top: -60,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryIcons.withOpacity(0.12),
                ),
              ),
            ),
            // Soft Teal Orb middle-left
            Positioned(
              top: 240,
              left: -70,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(0.08),
                ),
              ),
            ),
            // Soft Sky-Blue Orb bottom-right
            Positioned(
              bottom: 40,
              right: 20,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF38BDF8).withOpacity(0.09),
                ),
              ),
            ),
          ] else ...[
            // Deep glowing dark orbs for Splash & Login
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(0.22),
                ),
              ),
            ),
            Positioned(
              top: 250,
              left: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryIcons.withOpacity(0.15),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              right: 40,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(0.18),
                ),
              ),
            ),
          ],

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
