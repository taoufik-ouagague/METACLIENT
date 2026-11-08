import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/client_info_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/fcm_service.dart';
import '../services/storage_service.dart';
import 'agence_controller.dart';
import 'crbt_controller.dart';
import 'dashboard_controller.dart';
import 'expedition_controller.dart';
import 'facture_controller.dart';
import 'prepaye_controller.dart';
import 'retour_fond_controller.dart';

class AuthController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final Rxn<ClientInfoModel> clientInfo = Rxn<ClientInfoModel>();
  final RxnString profilePhoto = RxnString();
  final RxString fcmToken = ''.obs;

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
      currentUser.value = user;

      await StorageService.setToken(user.token);
      await StorageService.setUserCode(user.code);
      await StorageService.setUserLibelle(user.libelle);
      await StorageService.setLogin(loginUser);

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

      // Récupérer et associer le token FCM à la session connectée
      syncFcmToken();

      Get.offAllNamed('/home');
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur de connexion',
        e.toString().replaceAll('ApiException', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.85),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
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
    await StorageService.clearAll();
    currentUser.value = null;
    clientInfo.value = null;
    profilePhoto.value = null;
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }
}
