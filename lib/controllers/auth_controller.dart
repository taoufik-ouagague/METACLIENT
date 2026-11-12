import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/client_info_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/fcm_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'agence_controller.dart';
import 'crbt_controller.dart';
import 'dashboard_controller.dart';
import 'expedition_controller.dart';
import 'facture_controller.dart';
import 'notification_controller.dart';
import 'prepaye_controller.dart';
import 'retour_fond_controller.dart';

class AuthController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isResendingOtp = false.obs;
  final RxBool isLoggedIn = false.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final Rxn<UserModel> pendingOtpUser = Rxn<UserModel>();
  final Rxn<ClientInfoModel> clientInfo = Rxn<ClientInfoModel>();
  final RxnString profilePhoto = RxnString();
  final RxString fcmToken = ''.obs;

  String _pendingLoginUser = '';

  @override
  void onInit() {
    super.onInit();
    AppChannel.instance.onTokenRefresh((newToken) {
      fcmToken.value = newToken;
      syncFcmToken();
    });
    checkAuthStatus();
  }

  void checkAuthStatus() {
    final hasToken = StorageService.hasToken();
    isLoggedIn.value = hasToken;
    profilePhoto.value = StorageService.getProfilePhoto();
    if (hasToken) {
      final code = StorageService.getUserCode() ?? '';
      final libelle = StorageService.getUserLibelle() ?? '';
      final token = StorageService.getToken() ?? '';
      currentUser.value = UserModel(
        code: code,
        libelle: libelle,
        roles: [],
        token: token,
      );
      fetchClientInfo();
      syncFcmToken();
    }
  }

  Future<bool> login(String loginUser, String password) async {
    try {
      isLoading.value = true;
      final res = await ApiService.login(loginUser, password);

      final token = res['token']?.toString() ?? '';
      if (token.isEmpty) {
        Get.snackbar(
          'Erreur de connexion',
          'Identifiants incorrects ou token manquant',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.85),
          colorText: Colors.white,
        );
        return false;
      }

      final user = UserModel.fromJson(res);

      // Si "connexionOtp": true, rediriger vers l'ecran de saisie du code OTP
      if (user.connexionOtp) {
        pendingOtpUser.value = user;
        _pendingLoginUser = loginUser;
        ApiService.setPendingOtpToken(user.token);
        Get.toNamed('/otp');
        return true;
      }

      await _finaliserConnexion(user, loginUser);
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur de connexion',
        _nettoyerErreurApi(e),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.85),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Vérifie le code OTP saisi via /api/clientmobile/CheckOtpMobile
  Future<bool> verifyOtp(String codeOtp) async {
    final user = pendingOtpUser.value;
    if (user == null) {
      Get.offAllNamed('/login');
      return false;
    }

    try {
      isLoading.value = true;
      ApiService.setPendingOtpToken(user.token);
      final res = await ApiService.checkOtpMobile(codeOtp);

      if (!_estReponseOtpValide(res)) {
        final msg = _extraireMessageApi(res) ?? 'Code OTP incorrect ou expiré';
        Get.snackbar(
          'Code OTP invalide',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.85),
          colorText: Colors.white,
        );
        return false;
      }

      final newToken = res['token']?.toString() ?? '';
      final effectiveUser = newToken.isNotEmpty
          ? UserModel(
              code: user.code,
              libelle: user.libelle,
              roles: user.roles,
              token: newToken,
              connexionOtp: user.connexionOtp,
            )
          : user;

      pendingOtpUser.value = null;
      await _finaliserConnexion(effectiveUser, _pendingLoginUser);
      return true;
    } catch (e) {
      Get.snackbar(
        'Code OTP invalide',
        _nettoyerErreurApi(e),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.85),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Renvoie un nouveau code OTP par e-mail via /api/clientmobile/sendOtpMobile
  Future<bool> resendOtp() async {
    final user = pendingOtpUser.value;
    if (user == null) return false;

    try {
      isResendingOtp.value = true;
      ApiService.setPendingOtpToken(user.token);
      final res = await ApiService.sendOtpMobile();
      final msg =
          _extraireMessageApi(res) ??
          "Code OTP envoyé à l'adresse associée au compte";

      Get.snackbar(
        'Code OTP envoyé',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.statusSuccess.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur d\'envoi',
        _nettoyerErreurApi(e),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.85),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isResendingOtp.value = false;
    }
  }

  void cancelOtp() {
    pendingOtpUser.value = null;
    _pendingLoginUser = '';
    ApiService.setPendingOtpToken(null);
    Get.offAllNamed('/login');
  }

  Future<void> _finaliserConnexion(UserModel user, String loginUser) async {
    ApiService.setPendingOtpToken(null);
    currentUser.value = user;

    await StorageService.setToken(user.token);
    await StorageService.setUserCode(user.code);
    await StorageService.setUserLibelle(user.libelle);
    if (loginUser.isNotEmpty) {
      await StorageService.setLogin(loginUser);
    }

    isLoggedIn.value = true;
    await fetchClientInfo();

    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadDashboardData();
    }
    if (Get.isRegistered<ExpeditionController>()) {
      Get.find<ExpeditionController>().fetchExpeditionsEncours();
      Get.find<ExpeditionController>().fetchAllExpeditions();
    }
    if (Get.isRegistered<FactureController>()) {
      Get.find<FactureController>().fetchFacturesInstances();
      Get.find<FactureController>().fetchAllFactures();
    }
    if (Get.isRegistered<RetourFondController>()) {
      Get.find<RetourFondController>().fetchRetoursCCCT();
      Get.find<RetourFondController>().fetchRetoursBL();
    }
    if (Get.isRegistered<CrbtController>()) {
      Get.find<CrbtController>().fetchExpeditionsCrbt();
      Get.find<CrbtController>().fetchChequesCrbt();
      Get.find<CrbtController>().fetchVirementsCrbt();
    }
    // Ces deux-la ne chargent qu'au onInit, qui tourne avant le login :
    // sans ce rappel la page reste a zero jusqu'au prochain demarrage.
    if (Get.isRegistered<PrepayeController>()) {
      Get.find<PrepayeController>().fetchReleve(resetPage: true);
    }
    if (Get.isRegistered<AgenceController>()) {
      Get.find<AgenceController>().fetchAgences();
    }
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().fetchNotifications();
    }

    // Récupérer et associer le token FCM à la session connectée
    syncFcmToken();

    Get.offAllNamed('/home');
  }

  bool _estReponseOtpValide(Map<String, dynamic> res) {
    if (res['result'] == false ||
        res['valid'] == false ||
        res['status'] == false ||
        res['success'] == false) {
      return false;
    }
    if (res['error'] != null && res['error'].toString().trim().isNotEmpty) {
      return false;
    }
    final msg = _extraireMessageApi(res);
    if (msg != null) {
      final lower = msg.toLowerCase();
      if (lower.contains('incorrect') ||
          lower.contains('invalide') ||
          lower.contains('invalid') ||
          lower.contains('expir') ||
          lower.contains('erreur') ||
          lower.contains('erron') ||
          lower.contains('faux') ||
          lower.contains('non valide') ||
          lower.contains('échou') ||
          lower.contains('echou')) {
        return false;
      }
    }
    return true;
  }

  String? _extraireMessageApi(Map<String, dynamic> res) {
    for (final key in const ['msg', 'message', 'error', 'MSG']) {
      final val = res[key];
      if (val != null && val.toString().trim().isNotEmpty) {
        return val.toString().trim();
      }
    }
    final data = res['data'];
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map) {
        for (final key in const ['msg', 'message', 'error', 'MSG']) {
          final val = first[key];
          if (val != null && val.toString().trim().isNotEmpty) {
            return val.toString().trim();
          }
        }
      }
    }
    return null;
  }

  String _nettoyerErreurApi(Object e) {
    if (e is ApiException) {
      final raw = e.message.trim();
      if (raw.isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            final msg = _extraireMessageApi(decoded);
            if (msg != null) return msg;
          } else if (decoded is List && decoded.isNotEmpty) {
            final msg = _extraireMessageApi({'data': decoded});
            if (msg != null) return msg;
          }
        } catch (_) {}
        return raw;
      }
      return 'Erreur serveur (${e.statusCode})';
    }
    return e.toString().replaceAll('ApiException', '').trim();
  }

  /// Récupère et synchronise le token FCM avec le serveur
  Future<void> syncFcmToken() async {
    try {
      final token = await AppChannel.instance.getTokenAsync();
      if (token != null && token.isNotEmpty) {
        fcmToken.value = token;
        debugPrint('📲 [FCM] Token actif pour la session : $token');

        if (isLoggedIn.value && StorageService.hasToken()) {
          try {
            await ApiService.updateFcmToken(token);
            debugPrint('✅ [FCM] Token mobile enregistré auprès du serveur.');
          } catch (e) {
            debugPrint('⚠️ [FCM] Impossible d\'enregistrer le token serveur : $e');
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ [FCM] Erreur synchronisation token : $e');
    }
  }

  Future<void> fetchClientInfo() async {
    try {
      final res = await ApiService.getInfosClient();
      clientInfo.value = ClientInfoModel.fromJson(res);
    } catch (e) {
      // Info client loading failed or null
    }
  }

  Future<void> updateProfilePhoto(String base64Photo) async {
    profilePhoto.value = base64Photo;
    await StorageService.setProfilePhoto(base64Photo);
  }

  Future<void> logout() async {
    ApiService.setPendingOtpToken(null);
    pendingOtpUser.value = null;
    _pendingLoginUser = '';
    await StorageService.clearAll();
    currentUser.value = null;
    clientInfo.value = null;
    profilePhoto.value = null;
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }
}
