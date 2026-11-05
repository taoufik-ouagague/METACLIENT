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
  final Rxn<ExpeditionDetailModel> selectedDetail =
      Rxn<ExpeditionDetailModel>();

  /// Resultats du suivi : l'API renvoie une liste, car un meme numero de
  /// declaration peut porter plusieurs expeditions (un aller et son retour).
  final RxList<ExpeditionDetailModel> resultatsTracking =
      <ExpeditionDetailModel>[].obs;

  // Pagination & Filtering
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalElements = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxString filterDu = ''.obs;
  final RxString filterAu = ''.obs;
  final RxString filterLivre = 'tous'.obs;
  final RxString filterNumeroClient = ''.obs;
  final RxString filterColis = ''.obs;
  final RxString filterMntFond = ''.obs;

  /// Vrai des qu'un filtre autre que la recherche par numero est actif : sert
  /// a marquer le bouton de filtres dans la barre.
  bool get filtresActifs =>
      filterDu.value.isNotEmpty ||
      filterAu.value.isNotEmpty ||
      filterLivre.value != 'tous' ||
      filterNumeroClient.value.isNotEmpty ||
      filterColis.value.isNotEmpty ||
      filterMntFond.value.isNotEmpty;

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
      final numDec = searchQuery.value.isEmpty
          ? null
          : searchQuery.value.trim();
      final livre = filterLivre.value == 'tous' ? null : filterLivre.value;
      final client = filterNumeroClient.value.trim();
      final colis = filterColis.value.trim();
      final fond = filterMntFond.value.trim();

      final res = await ApiService.getExpeditions(
        page: currentPage.value,
        pageSize: 20,
        du: du,
        au: au,
        numDeclaration: numDec,
        livre: livre,
        numeroClient: client.isEmpty ? null : client,
        colis: colis.isEmpty ? null : int.tryParse(colis),
        mntFond: fond.isEmpty ? null : num.tryParse(fond.replaceAll(',', '.')),
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
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Suivi par n° de declaration. Remplit `resultatsTracking` et renvoie le
  /// nombre de lignes trouvees — l'API repond 200 avec une liste vide quand le
  /// numero est inconnu, ce n'est pas une erreur.
  Future<int> fetchTracking(String numDeclaration) async {
    try {
      isLoadingDetail.value = true;
      resultatsTracking.clear();
      final res = await ApiService.getTrackingExpedition(numDeclaration);
      final liste = res['data'] as List? ?? [];
      resultatsTracking.assignAll(
        liste.map(
          (e) => ExpeditionDetailModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        ),
      );

      return resultatsTracking.length;
    } catch (e) {
      Get.snackbar(
        'Suivi indisponible',
        e.toString().replaceAll('ApiException', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.8),
        colorText: Colors.white,
      );

      return 0;
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Details deja ramenes pendant la session.
  ///
  /// ponytail: cache sans plafond ; a borner si une session parcourt des
  /// milliers d'expeditions.
  final Map<int, ExpeditionDetailModel> _detailsConnus = {};

  /// Ouvre le detail d'une expedition.
  ///
  /// Une expedition deja consultee s'affiche immediatement, et l'appel reseau
  /// la rafraichit par-dessus : le tourniquet ne revient que si l'on n'a
  /// vraiment rien a montrer. Vider `selectedDetail` avant l'appel, comme
  /// auparavant, imposait l'attente a chaque ouverture, meme repetee.
  Future<void> fetchDetail(int idExpedition) async {
    final connu = _detailsConnus[idExpedition];
    selectedDetail.value = connu;
    isLoadingDetail.value = connu == null;

    try {
      final res = await ApiService.getExpeditionDetail(idExpedition);
      final data = (res['data'] as List? ?? []).isNotEmpty
          ? res['data'][0]
          : res;
      final detail = ExpeditionDetailModel.fromJson(
        Map<String, dynamic>.from(data),
      );
      _detailsConnus[idExpedition] = detail;
      selectedDetail.value = detail;
    } catch (e) {
      // Si une version est deja a l'ecran, on la garde plutot que de la vider.
      if (connu == null) {
        Get.snackbar(
          'Détail indisponible',
          e.toString().replaceAll('ApiException', '').trim(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.8),
          colorText: Colors.white,
        );
      }
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
