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

  // Pagination & Totaux pour chaque volet
  final RxInt pageExpeditions = 1.obs;
  final RxInt totalPagesExpeditions = 1.obs;
  final RxInt totalElementsExpeditions = 0.obs;

  final RxInt pageCheques = 1.obs;
  final RxInt totalPagesCheques = 1.obs;
  final RxInt totalElementsCheques = 0.obs;

  final RxInt pageVirements = 1.obs;
  final RxInt totalPagesVirements = 1.obs;
  final RxInt totalElementsVirements = 0.obs;

  /// Vrai pendant qu'une page suivante arrive : la liste reste a l'ecran et
  /// un rond s'ajoute en pied, au lieu du voile plein ecran.
  final RxBool isLoadingMore = false.obs;

  final RxList<ExpeditionModel> expeditionsCrbt = <ExpeditionModel>[].obs;
  final RxList<ChequeCrbtModel> chequesCrbt = <ChequeCrbtModel>[].obs;
  final RxList<VirementCrbtModel> virementsCrbt = <VirementCrbtModel>[].obs;

  final RxList<ChequeCrbtDetailItem> selectedChequeDetails =
      <ChequeCrbtDetailItem>[].obs;
  final RxList<VirementCrbtDetailItem> selectedVirementDetails =
      <VirementCrbtDetailItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (StorageService.hasToken()) {
      fetchExpeditionsCrbt();
      fetchChequesCrbt();
      fetchVirementsCrbt();
    }
  }

  void _majPagination({
    required Map<String, dynamic> res,
    required int recuCount,
    required int pageActuelle,
    required RxInt totalPages,
    required RxInt totalElements,
    required int totalExistant,
  }) {
    final tp = (res['totalPages'] ?? res['total_pages']) as num?;
    final te =
        (res['totalElements'] ?? res['total_elements'] ?? res['total']) as num?;
    totalElements.value = te?.toInt() ?? totalExistant;
    if (tp != null && tp.toInt() > 0) {
      totalPages.value = tp.toInt();
    } else if (te != null && te.toInt() > 0) {
      totalPages.value = (te.toInt() / taillePagePaquet).ceil();
    } else {
      totalPages.value =
          recuCount >= taillePagePaquet ? pageActuelle + 1 : pageActuelle;
    }
  }

  Future<void> fetchExpeditionsCrbt({
    bool resetPage = false,
    bool ajout = false,
  }) async {
    if (resetPage) pageExpeditions.value = 1;
    final page = ajout ? pageExpeditions.value + 1 : pageExpeditions.value;

    try {
      if (ajout) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }
      final res = await ApiService.getExpeditionsCrbt(
        page: page,
        pageSize: taillePagePaquet,
      );
      final list = (res['data'] as List? ?? [])
          .map((e) => ExpeditionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (ajout) {
        expeditionsCrbt.addAll(list);
        pageExpeditions.value = page;
      } else {
        expeditionsCrbt.value = list;
      }

      _majPagination(
        res: res,
        recuCount: list.length,
        pageActuelle: page,
        totalPages: totalPagesExpeditions,
        totalElements: totalElementsExpeditions,
        totalExistant: expeditionsCrbt.length,
      );
    } catch (_) {
    } finally {
      if (ajout) {
        isLoadingMore.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  Future<void> fetchChequesCrbt({
    bool resetPage = false,
    bool ajout = false,
  }) async {
    if (resetPage) pageCheques.value = 1;
    final page = ajout ? pageCheques.value + 1 : pageCheques.value;

    try {
      if (ajout) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }
      final res = await ApiService.getChequesCrbt(
        page: page,
        pageSize: taillePagePaquet,
      );
      final list = (res['data'] as List? ?? [])
          .map((e) => ChequeCrbtModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (ajout) {
        chequesCrbt.addAll(list);
        pageCheques.value = page;
      } else {
        chequesCrbt.value = list;
      }

      _majPagination(
        res: res,
        recuCount: list.length,
        pageActuelle: page,
        totalPages: totalPagesCheques,
        totalElements: totalElementsCheques,
        totalExistant: chequesCrbt.length,
      );
    } catch (_) {
    } finally {
      if (ajout) {
        isLoadingMore.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  Future<void> fetchChequeDetail(int idCheque) async {
    try {
      isLoadingDetail.value = true;
      selectedChequeDetails.clear();
      final res = await ApiService.getDetailChequeCrbt(idCheque);
      final list = (res['data'] as List? ?? [])
          .map(
            (e) => ChequeCrbtDetailItem.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
      selectedChequeDetails.value = list;
    } catch (e) {
      Get.snackbar(
        'Détail indisponible',
        e.toString().replaceAll('ApiException', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> fetchVirementsCrbt({
    bool resetPage = false,
    bool ajout = false,
  }) async {
    if (resetPage) pageVirements.value = 1;
    final page = ajout ? pageVirements.value + 1 : pageVirements.value;

    try {
      if (ajout) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }
      final res = await ApiService.getVirementCrbt(
        page: page,
        pageSize: taillePagePaquet,
      );
      final list = (res['data'] as List? ?? [])
          .map((e) => VirementCrbtModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (ajout) {
        virementsCrbt.addAll(list);
        pageVirements.value = page;
      } else {
        virementsCrbt.value = list;
      }

      _majPagination(
        res: res,
        recuCount: list.length,
        pageActuelle: page,
        totalPages: totalPagesVirements,
        totalElements: totalElementsVirements,
        totalExistant: virementsCrbt.length,
      );
    } catch (_) {
    } finally {
      if (ajout) {
        isLoadingMore.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  Future<void> fetchVirementDetail(int idVirement) async {
    try {
      isLoadingDetail.value = true;
      selectedVirementDetails.clear();
      final res = await ApiService.getDetailVirementCrbt(idVirement);
      final list = (res['data'] as List? ?? [])
          .map(
            (e) =>
                VirementCrbtDetailItem.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
      selectedVirementDetails.value = list;
    } catch (e) {
      Get.snackbar(
        'Détail indisponible',
        e.toString().replaceAll('ApiException', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Reste-t-il des pages a tirer sur l'onglet actif ?
  bool get aPlusDePages {
    switch (activeTab.value) {
      case 0:
        return pageExpeditions.value < totalPagesExpeditions.value;
      case 1:
        return pageCheques.value < totalPagesCheques.value;
      case 2:
        return pageVirements.value < totalPagesVirements.value;
      default:
        return false;
    }
  }

  /// Tire le paquet suivant de l'onglet actif.
  Future<void> chargerPlus() async {
    if (isLoading.value || isLoadingMore.value || !aPlusDePages) return;
    switch (activeTab.value) {
      case 0:
        await fetchExpeditionsCrbt(ajout: true);
        break;
      case 1:
        await fetchChequesCrbt(ajout: true);
        break;
      case 2:
        await fetchVirementsCrbt(ajout: true);
        break;
    }
  }
}
