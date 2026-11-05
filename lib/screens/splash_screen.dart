import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  bool _sortie = false;

  static const String _splashAssetWebp =
      'assets/img/splash_screen_metaclient.webp';
  static const String _splashAssetPng =
      'assets/img/splash_screen_metaclient.png';

  @override
  void initState() {
    super.initState();

    // Mode immersif / statut bar sombre
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.bgDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));

    _animController.forward();
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    // Laisser le temps à l'utilisateur d'apprécier le splash screen
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    // L'illustration s'ouvre vers l'avant pendant que la page suivante arrive
    // en fondu par-dessus. Elle reste opaque : la faire disparaitre d'abord
    // laissait voir le fond nu du Scaffold entre les deux ecrans.
    setState(() => _sortie = true);
    await Future.delayed(const Duration(milliseconds: 140));
    if (!mounted) return;

    final hasToken = StorageService.hasToken();
    if (hasToken) {
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        top: false,
        bottom: true,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ─── Illustration 3D Splash Complète ────────────────────────────
            Center(
              child: AnimatedScale(
                scale: _sortie ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInCubic,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Image.asset(
                      _splashAssetWebp,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          _splashAssetPng,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                          filterQuality: FilterQuality.high,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
