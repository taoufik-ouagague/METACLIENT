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
  final Rxn<FactureModel> selectedFacture = Rxn<FactureModel>();

  // Filtering & Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalElements = 0.obs;
  /// Vrai pendant qu'une page suivante arrive : la liste reste a l'ecran et
  /// un rond s'ajoute en pied, au lieu du voile plein ecran.
  final RxBool isLoadingMore = false.obs;

  final RxString filterStatut = 'tous'.obs; // 'tous', 'cloture', 'en cours'

  @override
  void onInit() {
    super.onInit();
    if (StorageService.hasToken()) {
      fetchFacturesInstances();
      fetchAllFactures();
    }
  }

  /// Cherche une facture dans allFactures par id ou numero
  FactureModel? trouverFactureComplete(int? idFacture, String? numFacture) {
    if (allFactures.isEmpty) return null;
    for (final a in allFactures) {
      if ((idFacture != null && a.idFacture == idFacture) ||
          (numFacture != null &&
              numFacture.isNotEmpty &&
              a.numFacture == numFacture)) {
        return a;
      }
    }
    return null;
  }

  /// Enrichit les facturesInstances avec les informations completes (mntHt, tva, dateEcheance, couleur)
  void enrichirFacturesInstances() {
    if (allFactures.isEmpty || facturesInstances.isEmpty) return;
    final maj = facturesInstances.map((item) {
      final comp = trouverFactureComplete(item.idFacture, item.numFacture);
      return comp != null ? item.mergeWith(comp) : item;
    }).toList();
    facturesInstances.value = maj;
  }

  /// Recupere la facture complete depuis l'API /api/clientmobile/factures
  Future<FactureModel?> recupererFactureComplete(
    int? idFacture,
    String? numFacture,
  ) async {
    var found = trouverFactureComplete(idFacture, numFacture);
    if (found != null && found.mntHt != null && found.dateEcheance != null) {
      return found;
    }

    try {
      final res = await ApiService.getFactures(page: 1, pageSize: 100);
      final list = (res['data'] as List? ?? [])
          .map((e) => FactureModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      for (final f in list) {
        final idx = allFactures.indexWhere((x) => x.idFacture == f.idFacture);
        if (idx >= 0) {
          allFactures[idx] = f;
        } else {
          allFactures.add(f);
        }
      }

      enrichirFacturesInstances();
      return trouverFactureComplete(idFacture, numFacture);
    } catch (_) {
      return null;
    }
  }

  /// Echeance d'une facture.
  String? echeanceDe(FactureModel f) {
    if ((f.dateEcheance ?? '').trim().isNotEmpty) return f.dateEcheance;
    final comp = trouverFactureComplete(f.idFacture, f.numFacture);
    if ((comp?.dateEcheance ?? '').trim().isNotEmpty) return comp!.dateEcheance;
    return null;
  }

  Future<void> fetchFacturesInstances() async {
    try {
      isLoading.value = true;
      final res = await ApiService.getFacturesInstances();
      List<FactureModel> list = [];
      if (res is List) {
        list = res
            .map((e) => FactureModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else if (res is Map && res['data'] is List) {
        list = (res['data'] as List)
            .map((e) => FactureModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      facturesInstances.value = list;
      enrichirFacturesInstances();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllFactures({
    bool resetPage = false,
    bool ajout = false,
  }) async {
    if (resetPage) currentPage.value = 1;
    final page = ajout ? currentPage.value + 1 : currentPage.value;

    try {
      if (ajout) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }
      final String? regle = filterStatut.value == 'tous'
          ? null
          : filterStatut.value;
      final res = await ApiService.getFactures(
        page: page,
        pageSize: taillePagePaquet,
        regle: regle,
      );

      final list = (res['data'] as List? ?? [])
          .map((e) => FactureModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (ajout) {
        allFactures.addAll(list);
        // La page n'avance qu'une fois les lignes en place : un appel rate
        // ne doit pas faire sauter un paquet au scroll suivant.
        currentPage.value = page;
      } else {
        allFactures.value = list;
      }
      enrichirFacturesInstances();
      final tp = (res['totalPages'] ?? res['total_pages']) as num?;
      final te =
          (res['totalElements'] ?? res['total_elements'] ?? res['total']) as num?;
      totalElements.value = te?.toInt() ?? allFactures.length;
      if (tp != null && tp.toInt() > 0) {
        totalPages.value = tp.toInt();
      } else if (te != null && te.toInt() > 0) {
        totalPages.value = (te.toInt() / taillePagePaquet).ceil();
      } else {
        totalPages.value =
            list.length >= taillePagePaquet ? page + 1 : page;
      }
    } catch (e) {
      Get.snackbar(
        'Erreur de chargement',
        e.toString().replaceAll('ApiException', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      if (ajout) {
        isLoadingMore.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  Future<void> fetchDetail(int idFacture, {FactureModel? base}) async {
    try {
      isLoadingDetail.value = true;
      selectedDetail.value = null;

      // Initialiser selectedFacture
      FactureModel fInit = base ??
          trouverFactureComplete(idFacture, null) ??
          FactureModel(numFacture: '', idFacture: idFacture);
      final cache = trouverFactureComplete(idFacture, fInit.numFacture);
      if (cache != null) {
        fInit = fInit.mergeWith(cache);
      }
      selectedFacture.value = fInit;

      // 1. Charger reglements et avoirs
      final res = await ApiService.getFactureReglements(idFacture);
      final data = (res['data'] as List? ?? []).isNotEmpty
          ? res['data'][0]
          : res;
      selectedDetail.value = FactureDetailModel.fromJson(
        Map<String, dynamic>.from(data),
      );

      // 2. Si des informations manquent (mntHt, dateEcheance, mntTva),
      // les charger depuis l'API de liste des factures
      if (selectedFacture.value?.mntHt == null ||
          selectedFacture.value?.dateEcheance == null ||
          selectedFacture.value?.mntTva == null) {
        final comp = await recupererFactureComplete(
          idFacture,
          selectedFacture.value?.numFacture,
        );
        if (comp != null) {
          selectedFacture.value = selectedFacture.value!.mergeWith(comp);
        }
      }
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

  /// Reste-t-il des pages a tirer ?
  bool get aPlusDePages => currentPage.value < totalPages.value;

  /// Tire le paquet suivant. Les gardes rendent l'appel gratuit : le scroll
  /// la declenche a chaque frame passee pres du bas.
  Future<void> chargerPlus() async {
    if (isLoading.value || isLoadingMore.value || !aPlusDePages) return;
    await fetchAllFactures(ajout: true);
  }
}
