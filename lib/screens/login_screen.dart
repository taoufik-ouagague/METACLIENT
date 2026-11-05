import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../controllers/auth_controller.dart';
import '../controllers/config_controller.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _loginCtrl = TextEditingController();
  final TextEditingController _pwdCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePwd = true;
  bool _seSouvenir = false;

  @override
  void initState() {
    super.initState();
    _chargerIdentifiantsMemorises();
  }

  Future<void> _chargerIdentifiantsMemorises() async {
    if (!StorageService.getRememberMe()) return;
    final motDePasse = await StorageService.getRememberedPassword();
    if (!mounted) return;
    setState(() {
      _seSouvenir = true;
      _loginCtrl.text = StorageService.getRememberedLogin() ?? '';
      _pwdCtrl.text = motDePasse ?? '';
    });
  }

  Future<void> _onLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final login = _loginCtrl.text.trim();
    final motDePasse = _pwdCtrl.text;

    final connecte = await _authController.login(login, motDePasse);
    if (!connecte) return;

    if (_seSouvenir) {
      await StorageService.saveCredentials(login, motDePasse);
    } else {
      await StorageService.forgetCredentials();
    }
  }

  @override
  void dispose() {
    _loginCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.bgDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.bgDark,
        resizeToAvoidBottomInset: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ─── 1. Background Image (Futuristic Tech Transport Pathways) ───
            Image.asset(
              'assets/img/login_bg.webp',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, _, _) => Image.asset(
                'assets/img/login_bg.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, _, _) => Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.backgroundGradient,
                  ),
                ),
              ),
            ),

            // ─── 2. Contrast & Deep Vignette Overlay ───────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.bgDark.withValues(alpha: 0.65),
                    AppTheme.bgDark.withValues(alpha: 0.40),
                    AppTheme.bgDark.withValues(alpha: 0.78),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),

            // ─── 3. Subtle Ambient Cyan & Blue Glow Accents (No Yellow/Green) ─
            Positioned(
              top: -60,
              right: -50,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryIcons.withValues(alpha: 0.16),
                      AppTheme.primaryIcons.withValues(alpha: 0.03),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.50, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: -70,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.20),
                      AppTheme.primary.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),

            // ─── 4. Foreground Content (Glass Cards & Form) ────────────────
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),

                      // Logo & App Name Header (Using identical GlassContainer as Splash screen)
                      Obx(() {
                        final configCtrl = Get.isRegistered<ConfigController>()
                            ? Get.find<ConfigController>()
                            : null;
                        final clientLogoUrl = configCtrl?.logoUrl;
                        final hasClientLogo =
                            clientLogoUrl != null &&
                            clientLogoUrl.trim().isNotEmpty;

                        if (hasClientLogo) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // App Logo (Identical to Splash screen GlassContainer)
                              GlassContainer(
                                width: 86,
                                height: 86,
                                borderRadius: 24,
                                padding: const EdgeInsets.all(13),
                                color: Colors.white.withValues(alpha: 0.08),
                                border: Border.all(
                                  color: AppTheme.primaryIcons.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 1.5,
                                ),
                                child: Image.asset(
                                  'assets/img/logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) => const Icon(
                                    LucideIcons.truck,
                                    size: 38,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),

                              // Stylish subtle divider matching the splash cyan accent
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                child: Container(
                                  width: 1.5,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppTheme.primaryIcons.withValues(
                                          alpha: 0.1,
                                        ),
                                        AppTheme.primaryIcons.withValues(
                                          alpha: 0.6,
                                        ),
                                        AppTheme.primaryIcons.withValues(
                                          alpha: 0.1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Client Logo from API
                              GlassContainer(
                                width: 86,
                                height: 86,
                                borderRadius: 24,
                                padding: const EdgeInsets.all(10),
                                blur: 0,
                                color: Colors.white,
                                border: Border.all(
                                  color: AppTheme.primaryIcons.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryIcons.withValues(
                                      alpha: 0.22,
                                    ),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    clientLogoUrl,
                                    fit: BoxFit.contain,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return const Center(
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppTheme.primaryIcons,
                                                ),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (_, _, _) => const Icon(
                                      LucideIcons.building,
                                      size: 32,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        // Fallback: Single centered app logo
                        return GlassContainer(
                          width: 96,
                          height: 96,
                          borderRadius: 26,
                          padding: const EdgeInsets.all(16),
                          color: Colors.white.withValues(alpha: 0.08),
                          border: Border.all(
                            color: AppTheme.primaryIcons.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          child: Image.asset(
                            'assets/img/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              LucideIcons.truck,
                              size: 40,
                              color: AppTheme.primary,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),

                      // Title with pure Cyan/Blue brand gradient (No Green, No Yellow)
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.iconGradient.createShader(bounds),
                        child: const Text(
                          'METACLIENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Espace Client • Suivi Transport & Messagerie',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Login Frosted Glass Card
                      GlassContainer(
                        borderRadius: 28,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 28,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Connexion',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Login Field Title & Input
                              const Text(
                                'Identifiant',
                                style: TextStyle(
                                  color: AppTheme.primaryIcons,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GlassTextField(
                                controller: _loginCtrl,
                                hintText: 'Saisissez votre identifiant',
                                prefixIcon: LucideIcons.user,
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Veuillez saisir votre identifiant'
                                    : null,
                              ),
                              const SizedBox(height: 18),

                              // Password Field Title & Input
                              const Text(
                                'Mot de passe',
                                style: TextStyle(
                                  color: AppTheme.primaryIcons,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GlassTextField(
                                controller: _pwdCtrl,
                                hintText: '••••••',
                                prefixIcon: LucideIcons.lock,
                                obscureText: _obscurePwd,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePwd
                                        ? LucideIcons.eyeOff
                                        : LucideIcons.eye,
                                    color: Colors.white.withValues(alpha: 0.6),
                                    size: 18,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePwd = !_obscurePwd,
                                  ),
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Veuillez saisir votre mot de passe'
                                    : null,
                              ),
                              const SizedBox(height: 14),

                              // Se souvenir de moi (Cyan theme accent, No Green)
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () =>
                                    setState(() => _seSouvenir = !_seSouvenir),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5, 4, 0, 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        curve: Curves.easeOut,
                                        width: 21,
                                        height: 21,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            7,
                                          ),
                                          color: _seSouvenir
                                              ? AppTheme.primaryIcons
                                              : Colors.white.withValues(
                                                  alpha: 0.06,
                                                ),
                                          border: Border.all(
                                            color: _seSouvenir
                                                ? AppTheme.primaryIcons
                                                : Colors.white.withValues(
                                                    alpha: 0.28,
                                                  ),
                                            width: 1.4,
                                          ),
                                          boxShadow: _seSouvenir
                                              ? [
                                                  BoxShadow(
                                                    color: AppTheme.primaryIcons
                                                        .withValues(alpha: 0.35),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: AnimatedScale(
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          curve: Curves.easeOutBack,
                                          scale: _seSouvenir ? 1 : 0,
                                          child: const Icon(
                                            LucideIcons.check,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: _seSouvenir ? 0.95 : 0.7,
                                          ),
                                          fontSize: 13,
                                          fontWeight: _seSouvenir
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                        ),
                                        child: const Text('Se souvenir de moi'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 22),

                              // Submit Button (Explicit brand primary gradient, No Green/Yellow)
                              Obx(
                                () => GlassButton(
                                  text: 'Se connecter',
                                  icon: LucideIcons.logIn,
                                  gradient: AppTheme.primaryGradient,
                                  isLoading: _authController.isLoading.value,
                                  onPressed: _onLogin,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Footer Note - Propulsé par KAY TECHNOLOGY
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24,
                                height: 1,
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  'Propulsé par',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.55),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              Container(
                                width: 24,
                                height: 1,
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Image.asset(
                            'assets/img/kay_tech_logo_white.png',
                            height: 34,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ],
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
