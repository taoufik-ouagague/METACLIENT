import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../controllers/auth_controller.dart';
import '../controllers/config_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_scaffold.dart';
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

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      _authController.login(_loginCtrl.text, _pwdCtrl.text);
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
    return GlassScaffold(
      isLight: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Logo & App Name Header (with dynamic client logo beside app logo)
              Obx(() {
                final configCtrl = Get.isRegistered<ConfigController>()
                    ? Get.find<ConfigController>()
                    : null;
                final clientLogoUrl = configCtrl?.logoUrl;
                final hasClientLogo = clientLogoUrl != null && clientLogoUrl.trim().isNotEmpty;

                if (hasClientLogo) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // App Logo (Homogeneous clean frosted glass card)
                      GlassContainer(
                        width: 86,
                        height: 86,
                        borderRadius: 24,
                        padding: const EdgeInsets.all(13),
                        color: Colors.white.withOpacity(0.92),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.85),
                          width: 1.2,
                        ),
                        child: Image.asset(
                          'assets/img/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            LucideIcons.truck,
                            size: 38,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),

                      // Stylish Homogeneous Divider blending Yellow, Green & Blue
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Container(
                          width: 2,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                (configCtrl?.optionalColor ?? AppTheme.accentCyan).withOpacity(0.2),
                                (configCtrl?.optionalColor ?? AppTheme.accentCyan).withOpacity(0.85),
                                (configCtrl?.secondaryColor ?? AppTheme.primaryIcons).withOpacity(0.85),
                                (configCtrl?.primaryColor ?? AppTheme.primary).withOpacity(0.2),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Client Logo from API (Matching homogeneous clean frosted glass card)
                      GlassContainer(
                        width: 86,
                        height: 86,
                        borderRadius: 24,
                        padding: const EdgeInsets.all(11),
                        color: Colors.white.withOpacity(0.92),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.85),
                          width: 1.2,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            clientLogoUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      configCtrl?.primaryColor ?? AppTheme.primary,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => const Icon(
                              LucideIcons.building,
                              size: 32,
                              color: Color(0xFF64748B),
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
                  color: Colors.white.withOpacity(0.92),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.85),
                    width: 1.2,
                  ),
                  child: Image.asset(
                    'assets/img/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      LucideIcons.truck,
                      size: 40,
                      color: AppTheme.primary,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Title with dynamic 3-color brand gradient (Blue -> Green -> Yellow)
              Obx(() {
                final configCtrl = Get.isRegistered<ConfigController>()
                    ? Get.find<ConfigController>()
                    : null;
                final textGradient = configCtrl?.brandGradient ?? AppTheme.iconGradient;
                return ShaderMask(
                  shaderCallback: (bounds) => textGradient.createShader(bounds),
                  child: const Text(
                    'METACLIENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 6),
              Text(
                'Espace Client • Suivi Transport & Messagerie',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 32),

              // Login Frosted Glass Card
              GlassContainer(
                borderRadius: 28,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
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
                      const SizedBox(height: 6),
                      Text(
                        'Entrez vos identifiants pour accéder à votre espace',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login Field Title & Input
                      Obx(() {
                        final configCtrl = Get.isRegistered<ConfigController>()
                            ? Get.find<ConfigController>()
                            : null;
                        final labelColor = configCtrl?.secondaryColor ?? AppTheme.primaryIcons;
                        return Text(
                          'Identifiant',
                          style: TextStyle(
                            color: labelColor,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      GlassTextField(
                        controller: _loginCtrl,
                        hintText: 'Saisissez votre identifiant',
                        prefixIcon: LucideIcons.user,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Veuillez saisir votre identifiant' : null,
                      ),
                      const SizedBox(height: 18),

                      // Password Field Title & Input
                      Obx(() {
                        final configCtrl = Get.isRegistered<ConfigController>()
                            ? Get.find<ConfigController>()
                            : null;
                        final labelColor = configCtrl?.secondaryColor ?? AppTheme.primaryIcons;
                        return Text(
                          'Mot de passe',
                          style: TextStyle(
                            color: labelColor,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      GlassTextField(
                        controller: _pwdCtrl,
                        hintText: '••••••',
                        prefixIcon: LucideIcons.lock,
                        obscureText: _obscurePwd,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePwd ? LucideIcons.eyeOff : LucideIcons.eye,
                            color: Colors.white.withOpacity(0.6),
                            size: 18,
                          ),
                          onPressed: () => setState(() => _obscurePwd = !_obscurePwd),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Veuillez saisir votre mot de passe' : null,
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      Obx(
                        () => GlassButton(
                          text: 'Se connecter',
                          icon: LucideIcons.logIn,
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
                        color: Colors.white.withOpacity(0.18),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Propulsé par',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 1,
                        color: Colors.white.withOpacity(0.18),
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
    );
  }
}
