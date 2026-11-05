import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/retour_fond_model.dart';
import '../services/api_service.dart';

import '../services/storage_service.dart';

class RetourFondController extends GetxController {
  final RxBool isLoading = false.obs;

  // Active Tab: 0 = Chèques & Traites (CC/CT), 1 = BL & Factures
  final RxInt activeTab = 0.obs;

  final RxList<RetourFondModel> retoursCCCT = <RetourFondModel>[].obs;
  final RxList<RetourFondModel> retoursBL = <RetourFondModel>[].obs;

  // Pagination & Filter
  final RxInt pageCCCT = 1.obs;
  final RxInt totalPagesCCCT = 1.obs;
  final RxInt pageBL = 1.obs;
  final RxInt totalPagesBL = 1.obs;

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

  Future<void> fetchRetoursCCCT({bool resetPage = false}) async {
    if (resetPage) pageCCCT.value = 1;

    try {
      isLoading.value = true;
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
        page: pageCCCT.value,
        pageSize: 20,
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

      retoursCCCT.value = list;
      totalPagesCCCT.value = (res['totalPages'] as num?)?.toInt() ?? 1;
    } catch (e) {
      debugPrint('RetourFond CCCT error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRetoursBL({bool resetPage = false}) async {
    if (resetPage) pageBL.value = 1;

    try {
      isLoading.value = true;
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
        page: pageBL.value,
        pageSize: 20,
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

      retoursBL.value = list;
      totalPagesBL.value = (res['totalPages'] as num?)?.toInt() ?? 1;
    } catch (e) {
      debugPrint('RetourFond BL error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
