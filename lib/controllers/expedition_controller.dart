import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/expedition_detail_model.dart';
import '../models/expedition_model.dart';
import '../services/api_service.dart';

import '../services/storage_service.dart';

class ExpeditionController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoadingDetail = false.obs;

  // Active Tab: 0 = En cours, 1 = Historique complet
  final RxInt activeTab = 0.obs;

  // Data lists
  final RxList<ExpeditionModel> expeditionsEncours = <ExpeditionModel>[].obs;
  final RxList<ExpeditionModel> allExpeditions = <ExpeditionModel>[].obs;
  final Rxn<ExpeditionDetailModel> selectedDetail = Rxn<ExpeditionDetailModel>();

  // Pagination & Filtering
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalElements = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxString filterDu = ''.obs;
  final RxString filterAu = ''.obs;
  final RxString filterLivre = 'tous'.obs;

  @override
  void onInit() {
    super.onInit();
    if (StorageService.hasToken()) {
      fetchExpeditionsEncours();
      fetchAllExpeditions();
    }
  }

  Future<void> fetchExpeditionsEncours() async {
    try {
      isLoading.value = true;
      final res = await ApiService.getExpeditionsEncours();
      final list = (res['data'] as List? ?? [])
          .map((e) => ExpeditionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      expeditionsEncours.value = list;
    } catch (e) {
      // Handled silently or empty
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllExpeditions({bool resetPage = false}) async {
    if (resetPage) currentPage.value = 1;

    try {
      isLoading.value = true;
      final du = filterDu.value.isEmpty ? null : filterDu.value;
      final au = filterAu.value.isEmpty ? null : filterAu.value;
      final numDec = searchQuery.value.isEmpty ? null : searchQuery.value.trim();
      final livre = filterLivre.value == 'tous' ? null : filterLivre.value;

      final res = await ApiService.getExpeditions(
        page: currentPage.value,
        pageSize: 20,
        du: du,
        au: au,
        numDeclaration: numDec,
        livre: livre,
      );

      final list = (res['data'] as List? ?? [])
          .map((e) => ExpeditionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      allExpeditions.value = list;
      totalPages.value = (res['totalPages'] as num?)?.toInt() ?? 1;
      totalElements.value = (res['totalElements'] as num?)?.toInt() ?? 0;
    } catch (e) {
      Get.snackbar(
        'Erreur de chargement',
        e.toString().replaceAll('ApiException', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDetail(int idExpedition) async {
    try {
      isLoadingDetail.value = true;
      selectedDetail.value = null;
      final res = await ApiService.getExpeditionDetail(idExpedition);
      final data = (res['data'] as List? ?? []).isNotEmpty ? res['data'][0] : res;
      selectedDetail.value = ExpeditionDetailModel.fromJson(Map<String, dynamic>.from(data));
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

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      fetchAllExpeditions();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchAllExpeditions();
    }
  }
}
