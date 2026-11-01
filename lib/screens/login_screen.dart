import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../controllers/auth_controller.dart';
import '../services/api_service.dart';
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
  final TextEditingController _loginCtrl = TextEditingController(text: 'client');
  final TextEditingController _pwdCtrl = TextEditingController(text: '123456');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePwd = true;

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      _authController.login(_loginCtrl.text, _pwdCtrl.text);
    }
  }

  void _showServerConfigDialog() {
    final urlCtrl = TextEditingController(text: ApiService.baseUrl);

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryIcons.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.server, color: AppTheme.primaryIcons, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Configuration Serveur',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Adresse URL de l\'API METACLIENT (BaseUrl) :',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(height: 12),
              GlassTextField(
                controller: urlCtrl,
                hintText: 'http://192.168.x.x:1599/METACLIENT',
                prefixIcon: LucideIcons.link,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Annuler', style: TextStyle(color: Colors.white60)),
                  ),
                  const SizedBox(width: 8),
                  GlassButton(
                    width: 120,
                    height: 42,
                    text: 'Enregistrer',
                    onPressed: () async {
                      if (urlCtrl.text.trim().isNotEmpty) {
                        await ApiService.updateBaseUrl(urlCtrl.text.trim());
                        Get.back();
                        Get.snackbar(
                          'Serveur mis à jour',
                          ApiService.baseUrl,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppTheme.statusSuccess.withOpacity(0.85),
                          colorText: Colors.white,
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top Server Config Quick Button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  tooltip: 'Paramètres du serveur API',
                  onPressed: _showServerConfigDialog,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: const Icon(LucideIcons.settings, color: AppTheme.primaryIcons, size: 18),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Logo & App Name Header
              GlassContainer(
                width: 90,
                height: 90,
                borderRadius: 24,
                padding: const EdgeInsets.all(14),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: AppTheme.primaryIcons.withOpacity(0.4), width: 1.2),
                child: Image.asset(
                  'assets/img/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    LucideIcons.truck,
                    size: 40,
                    color: AppTheme.primaryIcons,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              ShaderMask(
                shaderCallback: (bounds) => AppTheme.iconGradient.createShader(bounds),
                child: const Text(
                  'METACLIENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Espace Client • Suivi Transport & Messagerie',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 32),

              // Login Frosted Glass Card
              GlassContainer(
                borderRadius: 28,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
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

                      // Login Field
                      GlassTextField(
                        controller: _loginCtrl,
                        labelText: 'Identifiant / Code client',
                        hintText: 'Ex: client',
                        prefixIcon: LucideIcons.user,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Veuillez saisir votre identifiant' : null,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      GlassTextField(
                        controller: _pwdCtrl,
                        labelText: 'Mot de passe',
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
                      const SizedBox(height: 26),

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

              // Footer Note
              Text(
                'Propulsé par KAY TECHNOLOGY',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
