import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/crbt_model.dart';
import '../models/expedition_model.dart';
import '../services/api_service.dart';

import '../services/storage_service.dart';

class CrbtController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoadingDetail = false.obs;

  // Active Tab: 0 = Expéditions CRBT, 1 = Chèques CRBT, 2 = Virements & Mandats
  final RxInt activeTab = 0.obs;

  final RxList<ExpeditionModel> expeditionsCrbt = <ExpeditionModel>[].obs;
  final RxList<ChequeCrbtModel> chequesCrbt = <ChequeCrbtModel>[].obs;
  final RxList<VirementCrbtModel> virementsCrbt = <VirementCrbtModel>[].obs;

  final RxList<ChequeCrbtDetailItem> selectedChequeDetails = <ChequeCrbtDetailItem>[].obs;
  final RxList<VirementCrbtDetailItem> selectedVirementDetails = <VirementCrbtDetailItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (StorageService.hasToken()) {
      fetchExpeditionsCrbt();
      fetchChequesCrbt();
      fetchVirementsCrbt();
    }
  }

  Future<void> fetchExpeditionsCrbt() async {
    try {
      isLoading.value = true;
      final res = await ApiService.getExpeditionsCrbt(page: 1, pageSize: 25);
      final list = (res['data'] as List? ?? [])
          .map((e) => ExpeditionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      expeditionsCrbt.value = list;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchChequesCrbt() async {
    try {
      isLoading.value = true;
      final res = await ApiService.getChequesCrbt(page: 1, pageSize: 25);
      final list = (res['data'] as List? ?? [])
          .map((e) => ChequeCrbtModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      chequesCrbt.value = list;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchChequeDetail(int idCheque) async {
    try {
      isLoadingDetail.value = true;
      selectedChequeDetails.clear();
      final res = await ApiService.getDetailChequeCrbt(idCheque);
      final list = (res['data'] as List? ?? [])
          .map((e) => ChequeCrbtDetailItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      selectedChequeDetails.value = list;
    } catch (e) {
      Get.snackbar(
        'Détail indisponible',
        e.toString().replaceAll('ApiException', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> fetchVirementsCrbt() async {
    try {
      isLoading.value = true;
      final res = await ApiService.getVirementCrbt(page: 1, pageSize: 25);
      final list = (res['data'] as List? ?? [])
          .map((e) => VirementCrbtModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      virementsCrbt.value = list;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchVirementDetail(int idVirement) async {
    try {
      isLoadingDetail.value = true;
      selectedVirementDetails.clear();
      final res = await ApiService.getDetailVirementCrbt(idVirement);
      final list = (res['data'] as List? ?? [])
          .map((e) => VirementCrbtDetailItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      selectedVirementDetails.value = list;
    } catch (e) {
      Get.snackbar(
        'Détail indisponible',
        e.toString().replaceAll('ApiException', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoadingDetail.value = false;
    }
  }
}
