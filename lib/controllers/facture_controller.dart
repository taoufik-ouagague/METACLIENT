import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/facture_detail_model.dart';
import '../models/facture_model.dart';
import '../services/api_service.dart';

import '../services/storage_service.dart';

class FactureController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoadingDetail = false.obs;

  // Active Tab: 0 = En instances / Impayées, 1 = Toutes les factures
  final RxInt activeTab = 0.obs;

  final RxList<FactureModel> facturesInstances = <FactureModel>[].obs;
  final RxList<FactureModel> allFactures = <FactureModel>[].obs;
  final Rxn<FactureDetailModel> selectedDetail = Rxn<FactureDetailModel>();

  // Filtering & Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalElements = 0.obs;
  final RxString filterStatut = 'tous'.obs; // 'tous', 'cloture', 'en cours'

  @override
  void onInit() {
    super.onInit();
    if (StorageService.hasToken()) {
      fetchFacturesInstances();
      fetchAllFactures();
    }
  }

  Future<void> fetchFacturesInstances() async {
    try {
      isLoading.value = true;
      final res = await ApiService.getFacturesInstances();
      List<FactureModel> list = [];
      if (res is List) {
        list = res.map((e) => FactureModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } else if (res is Map && res['data'] is List) {
        list = (res['data'] as List)
            .map((e) => FactureModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      facturesInstances.value = list;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllFactures({bool resetPage = false}) async {
    if (resetPage) currentPage.value = 1;

    try {
      isLoading.value = true;
      final String? regle = filterStatut.value == 'tous' ? null : filterStatut.value;
      final res = await ApiService.getFactures(
        page: currentPage.value,
        pageSize: 20,
        regle: regle,
      );

      final list = (res['data'] as List? ?? [])
          .map((e) => FactureModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      allFactures.value = list;
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

  Future<void> fetchDetail(int idFacture) async {
    try {
      isLoadingDetail.value = true;
      selectedDetail.value = null;
      final res = await ApiService.getFactureReglements(idFacture);
      final data = (res['data'] as List? ?? []).isNotEmpty ? res['data'][0] : res;
      selectedDetail.value = FactureDetailModel.fromJson(Map<String, dynamic>.from(data));
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
      fetchAllFactures();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchAllFactures();
    }
  }
}
