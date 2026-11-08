import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/retour_fond_model.dart';
import '../services/api_service.dart';

import '../services/storage_service.dart';

class RetourFondController extends GetxController {
  final RxBool isLoading = false.obs;

  // Active Tab: 0 = Chèques & Traites (CC/CT), 1 = BL & Factures
  final RxInt activeTab = 0.obs;

  /// Retour sélectionné pour afficher le détail à la place de la liste
  final Rxn<RetourFondModel> selectedRetour = Rxn<RetourFondModel>();

  final RxList<RetourFondModel> retoursCCCT = <RetourFondModel>[].obs;
  final RxList<RetourFondModel> retoursBL = <RetourFondModel>[].obs;

  // Pagination & Filter
  final RxInt pageCCCT = 1.obs;
  final RxInt totalPagesCCCT = 1.obs;
  final RxInt pageBL = 1.obs;
  final RxInt totalPagesBL = 1.obs;

  /// Total cote serveur, pas le nombre de lignes deja tirees : l'onglet
  /// annonce la taille reelle du lot, qui ne bouge pas pendant le scroll.
  final RxInt totalElementsCCCT = 0.obs;
  final RxInt totalElementsBL = 0.obs;

  /// Vrai pendant qu'une page suivante arrive : la liste reste a l'ecran et
  /// un rond s'ajoute en pied, au lieu du voile plein ecran.
  final RxBool isLoadingMore = false.obs;

  final RxString filterDu = ''.obs;
  final RxString filterAu = ''.obs;
  final RxString filterNumDeclaration = ''.obs;
  final RxString filterNumPiece = ''.obs;
  final RxString filterClient = ''.obs;

  /// '' = tous, 'O' = remis, 'N' = non remis.
  final RxString filterRemis = ''.obs;

  /// Le parametre `remis` est envoye a l'API, mais celle-ci l'ignore encore :
  /// on refiltre donc la page recue pour que la bascule ait un effet visible.
  List<RetourFondModel> _filtrerRemis(List<RetourFondModel> liste) {
    final remis = filterRemis.value;
    if (remis.isEmpty) return liste;
    final veutRemis = remis == 'O';

    return liste
        .where((r) => ((r.dateRemise ?? '').trim().isNotEmpty) == veutRemis)
        .toList();
  }

  List<RetourFondModel> get retoursCCCTAffiches => _filtrerRemis(retoursCCCT);
  List<RetourFondModel> get retoursBLAffiches => _filtrerRemis(retoursBL);

  @override
  void onInit() {
    super.onInit();
    if (StorageService.hasToken()) {
      fetchRetoursCCCT();
      fetchRetoursBL();
    }
  }

  Future<void> fetchRetoursCCCT({
    bool resetPage = false,
    bool ajout = false,
  }) async {
    if (resetPage) pageCCCT.value = 1;
    final page = ajout ? pageCCCT.value + 1 : pageCCCT.value;

    try {
      if (ajout) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }
      final du = filterDu.value.isEmpty ? null : filterDu.value;
      final au = filterAu.value.isEmpty ? null : filterAu.value;
      final numDec = filterNumDeclaration.value.isEmpty
          ? null
          : filterNumDeclaration.value.trim();
      final numPiece = filterNumPiece.value.isEmpty
          ? null
          : filterNumPiece.value.trim();
      final client = filterClient.value.isEmpty
          ? null
          : filterClient.value.trim();
      final remis = filterRemis.value.isEmpty ? null : filterRemis.value;

      final res = await ApiService.getRetourFondCCCT(
        page: page,
        pageSize: taillePagePaquet,
        du: du,
        au: au,
        numDeclaration: numDec,
        numPiece: numPiece,
        libelleClient: client,
        remis: remis,
      );

      final list = (res['data'] as List? ?? [])
          .map((e) => RetourFondModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (ajout) {
        retoursCCCT.addAll(list);
        // La page n'avance qu'une fois les lignes en place : un appel rate
        // ne doit pas faire sauter un paquet au scroll suivant.
        pageCCCT.value = page;
      } else {
        retoursCCCT.value = list;
      }
      totalPagesCCCT.value = (res['totalPages'] as num?)?.toInt() ?? 1;
      totalElementsCCCT.value = (res['totalElements'] as num?)?.toInt() ?? 0;
    } catch (e) {
      debugPrint('RetourFond CCCT error: $e');
    } finally {
      if (ajout) {
        isLoadingMore.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  Future<void> fetchRetoursBL({
    bool resetPage = false,
    bool ajout = false,
  }) async {
    if (resetPage) pageBL.value = 1;
    final page = ajout ? pageBL.value + 1 : pageBL.value;

    try {
      if (ajout) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }
      final du = filterDu.value.isEmpty ? null : filterDu.value;
      final au = filterAu.value.isEmpty ? null : filterAu.value;
      final numDec = filterNumDeclaration.value.isEmpty
          ? null
          : filterNumDeclaration.value.trim();
      final numPiece = filterNumPiece.value.isEmpty
          ? null
          : filterNumPiece.value.trim();
      final client = filterClient.value.isEmpty
          ? null
          : filterClient.value.trim();
      final remis = filterRemis.value.isEmpty ? null : filterRemis.value;

      final res = await ApiService.getRetourFondBL(
        page: page,
        pageSize: taillePagePaquet,
        du: du,
        au: au,
        numDeclaration: numDec,
        numPiece: numPiece,
        libelleClient: client,
        remis: remis,
      );

      final list = (res['data'] as List? ?? [])
          .map((e) => RetourFondModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (ajout) {
        retoursBL.addAll(list);
        // La page n'avance qu'une fois les lignes en place : un appel rate
        // ne doit pas faire sauter un paquet au scroll suivant.
        pageBL.value = page;
      } else {
        retoursBL.value = list;
      }
      totalPagesBL.value = (res['totalPages'] as num?)?.toInt() ?? 1;
      totalElementsBL.value = (res['totalElements'] as num?)?.toInt() ?? 0;
    } catch (e) {
      debugPrint('RetourFond BL error: $e');
    } finally {
      if (ajout) {
        isLoadingMore.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  /// Reste-t-il des pages a tirer sur l'onglet affiche ?
  bool get aPlusDePages => activeTab.value == 0
      ? pageCCCT.value < totalPagesCCCT.value
      : pageBL.value < totalPagesBL.value;

  /// Tire le paquet suivant de l'onglet affiche. Les gardes rendent l'appel
  /// gratuit : le scroll le declenche a chaque frame passee pres du bas.
  Future<void> chargerPlus() async {
    if (isLoading.value || isLoadingMore.value || !aPlusDePages) return;
    if (activeTab.value == 0) {
      await fetchRetoursCCCT(ajout: true);
    } else {
      await fetchRetoursBL(ajout: true);
    }
  }
}
