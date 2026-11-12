import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../controllers/auth_controller.dart';
import '../controllers/config_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_container.dart';

const TextStyle _styleMarqueOtp = TextStyle(
  color: Colors.white,
  fontSize: 30,
  fontWeight: FontWeight.w900,
  letterSpacing: 1.5,
);

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  static const int _otpLength = 4;

  late final AnimationController _entreeCtrl;
  late final Animation<double> _entreeOpacite;
  late final Animation<Offset> _entreeGlissement;

  final AuthController _authController = Get.find<AuthController>();
  late final List<TextEditingController> _digitCtrls;
  late final List<FocusNode> _focusNodes;

  Timer? _cooldownTimer;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();

    _digitCtrls = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());

    _entreeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    _entreeOpacite = CurvedAnimation(
      parent: _entreeCtrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _entreeGlissement = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entreeCtrl, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _focusNodes.isNotEmpty) {
        _focusNodes.first.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _entreeCtrl.dispose();
    for (final ctrl in _digitCtrls) {
      ctrl.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _codeSaisi =>
      _digitCtrls.map((c) => c.text.trim()).join();

  void _onDigitChanged(int index, String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    // Gestion du copier-coller d'un code complet (ex: "6635")
    if (digitsOnly.length > 1) {
      for (int i = 0; i < _otpLength; i++) {
        _digitCtrls[i].text = i < digitsOnly.length ? digitsOnly[i] : '';
      }
      final targetIndex =
          digitsOnly.length >= _otpLength ? _otpLength - 1 : digitsOnly.length;
      _focusNodes[targetIndex].requestFocus();
      setState(() {});
      if (_codeSaisi.length == _otpLength) {
        FocusScope.of(context).unfocus();
        _onVerifyOtp();
      }
      return;
    }

    if (digitsOnly.isEmpty) {
      _digitCtrls[index].text = '';
      setState(() {});
      return;
    }

    final char = digitsOnly.substring(digitsOnly.length - 1);
    if (_digitCtrls[index].text != char) {
      _digitCtrls[index].text = char;
      _digitCtrls[index].selection = const TextSelection.collapsed(offset: 1);
    }

    setState(() {});

    if (index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      FocusScope.of(context).unfocus();
      if (_codeSaisi.length == _otpLength) {
        _onVerifyOtp();
      }
    }
  }

  KeyEventResult _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_digitCtrls[index].text.isEmpty && index > 0) {
        _digitCtrls[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
        setState(() {});
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Future<void> _onVerifyOtp() async {
    final code = _codeSaisi;
    if (code.length < _otpLength) {
      Get.snackbar(
        'Code incomplet',
        'Veuillez saisir les $_otpLength chiffres du code OTP reçu par e-mail',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.statusWarning.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    final ok = await _authController.verifyOtp(code);
    if (!ok && mounted) {
      for (final ctrl in _digitCtrls) {
        ctrl.clear();
      }
      setState(() {});
      _focusNodes.first.requestFocus();
    }
  }

  Future<void> _onResendOtp() async {
    if (_resendCooldown > 0 || _authController.isResendingOtp.value) return;

    final sent = await _authController.resendOtp();
    if (sent && mounted) {
      for (final ctrl in _digitCtrls) {
        ctrl.clear();
      }
      _focusNodes.first.requestFocus();
      _startCooldown(30);
    }
  }

  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    setState(() => _resendCooldown = seconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Widget _buildOtpCell(int index) {
    return AnimatedBuilder(
      animation: _focusNodes[index],
      builder: (context, _) {
        final hasFocus = _focusNodes[index].hasFocus;
        final isFilled = _digitCtrls[index].text.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 60,
          height: 66,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: hasFocus
                ? AppTheme.primaryIcons.withValues(alpha: 0.14)
                : isFilled
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.white.withValues(alpha: 0.06),
            border: Border.all(
              color: hasFocus
                  ? AppTheme.primaryIcons
                  : isFilled
                  ? AppTheme.primaryIcons.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.20),
              width: hasFocus ? 2.0 : 1.3,
            ),
            boxShadow: hasFocus
                ? [
                    BoxShadow(
                      color: AppTheme.primaryIcons.withValues(alpha: 0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Focus(
              onKeyEvent: (_, event) => _onKeyEvent(index, event),
              child: TextField(
                controller: _digitCtrls[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: _otpLength,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
                cursorColor: AppTheme.primaryIcons,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) => _onDigitChanged(index, val),
                onSubmitted: (_) {
                  if (_codeSaisi.length == _otpLength) {
                    _onVerifyOtp();
                  }
                },
              ),
            ),
          ),
        );
      },
    );
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
            // ─── 1. Background Image ───────────────────────────────────────
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

            // ─── 3. Ambient Cyan & Blue Glow Accents ───────────────────────
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

            // ─── 4. Foreground Content ─────────────────────────────────────
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: FadeTransition(
                    opacity: _entreeOpacite,
                    child: SlideTransition(
                      position: _entreeGlissement,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),

                          // Logo & App Name Header
                          Obx(() {
                            final configCtrl =
                                Get.isRegistered<ConfigController>()
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
                                  GlassContainer(
                                    width: 86,
                                    height: 86,
                                    borderRadius: 24,
                                    padding: const EdgeInsets.all(10),
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

                            return GlassContainer(
                              width: 96,
                              height: 96,
                              borderRadius: 26,
                              padding: const EdgeInsets.all(16),
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
                                  size: 40,
                                  color: AppTheme.primary,
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 20),

                          // Brand Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('META', style: _styleMarqueOtp),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    AppTheme.iconGradient.createShader(bounds),
                                child: const Text(
                                  'CLIENT',
                                  style: _styleMarqueOtp,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Authentification à double facteur (OTP)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // OTP Frosted Glass Card
                          GlassContainer(
                            isLight: false,
                            blur: 16,
                            borderRadius: 28,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 28,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Shield / Mail Icon Badge
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primaryIcons.withValues(
                                      alpha: 0.14,
                                    ),
                                    border: Border.all(
                                      color: AppTheme.primaryIcons.withValues(
                                        alpha: 0.45,
                                      ),
                                      width: 1.4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryIcons.withValues(
                                          alpha: 0.22,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    LucideIcons.mailCheck,
                                    color: AppTheme.primaryIcons,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                const Text(
                                  'Vérification OTP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Obx(() {
                                  final libelle =
                                      _authController
                                          .pendingOtpUser
                                          .value
                                          ?.libelle ??
                                      '';
                                  if (libelle.trim().isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: AppTheme.primaryIcons.withValues(
                                          alpha: 0.12,
                                        ),
                                        border: Border.all(
                                          color: AppTheme.primaryIcons
                                              .withValues(alpha: 0.35),
                                        ),
                                      ),
                                      child: Text(
                                        libelle,
                                        style: const TextStyle(
                                          color: AppTheme.primaryIcons,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  );
                                }),

                                Text(
                                  'Veuillez introduire le code de connexion à usage unique (OTP) envoyé dans votre boîte e-mail.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.72),
                                    fontSize: 13,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // 4 OTP Digit Boxes
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(
                                    _otpLength,
                                    (index) => _buildOtpCell(index),
                                  ),
                                ),
                                const SizedBox(height: 26),

                                // Verify Button
                                Obx(
                                  () => GlassButton(
                                    text: 'Vérifier le code',
                                    icon: LucideIcons.shieldCheck,
                                    gradient: AppTheme.primaryGradient,
                                    isLoading:
                                        _authController.isLoading.value,
                                    onPressed: _onVerifyOtp,
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Resend OTP Link / Button
                                Obx(() {
                                  final isSending =
                                      _authController.isResendingOtp.value;
                                  final disabled =
                                      isSending || _resendCooldown > 0;

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: disabled ? null : _onResendOtp,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (isSending) ...[
                                            const SizedBox(
                                              width: 15,
                                              height: 15,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppTheme.primaryIcons,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Envoi du code en cours...',
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.75,
                                                ),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ] else ...[
                                            Icon(
                                              LucideIcons.refreshCw,
                                              size: 15,
                                              color: disabled
                                                  ? Colors.white.withValues(
                                                      alpha: 0.4,
                                                    )
                                                  : AppTheme.primaryIcons,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _resendCooldown > 0
                                                  ? 'Renvoyer le code (${_resendCooldown}s)'
                                                  : 'Renvoyer le code OTP',
                                              style: TextStyle(
                                                color: disabled
                                                    ? Colors.white.withValues(
                                                        alpha: 0.45,
                                                      )
                                                    : AppTheme.primaryIcons,
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                }),

                                const SizedBox(height: 6),

                                // Back to Login
                                TextButton.icon(
                                  onPressed: _authController.cancelOtp,
                                  icon: Icon(
                                    LucideIcons.arrowLeft,
                                    size: 15,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                  label: Text(
                                    'Retour à la connexion',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.65,
                                      ),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
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
                                        color: Colors.white.withValues(
                                          alpha: 0.55,
                                        ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
