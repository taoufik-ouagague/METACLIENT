import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/client_info_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'crbt_controller.dart';
import 'dashboard_controller.dart';
import 'expedition_controller.dart';
import 'facture_controller.dart';
import 'retour_fond_controller.dart';

class AuthController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final Rxn<ClientInfoModel> clientInfo = Rxn<ClientInfoModel>();

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  void checkAuthStatus() {
    final hasToken = StorageService.hasToken();
    isLoggedIn.value = hasToken;
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
          backgroundColor: const Color(0xFFEF4444).withOpacity(0.85),
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

      Get.offAllNamed('/home');
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur de connexion',
        e.toString().replaceAll('ApiException', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withOpacity(0.85),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
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

  Future<void> logout() async {
    await StorageService.clearAll();
    currentUser.value = null;
    clientInfo.value = null;
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }
}
