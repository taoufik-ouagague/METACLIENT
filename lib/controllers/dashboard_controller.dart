import 'package:get/get.dart';
import '../models/expedition_model.dart';
import '../models/facture_model.dart';
import '../services/api_service.dart';

import '../services/storage_service.dart';

class DashboardController extends GetxController {
  final RxBool isLoading = false.obs;

  final RxInt expeditionsEncoursCount = 0.obs;
  final RxInt totalExpeditionsCount = 0.obs;
  final RxInt facturesInstancesCount = 0.obs;
  final RxDouble totalSoldeDu = 0.0.obs;

  /// Un compteur par ecran de l'application.
  final RxInt retoursCcCtCount = 0.obs;
  final RxInt retoursBlCount = 0.obs;
  final RxInt crbtChequesCount = 0.obs;
  final RxInt crbtVirementsCount = 0.obs;

  final RxList<ExpeditionModel> recentExpeditions = <ExpeditionModel>[].obs;
  final RxList<FactureModel> urgentFactures = <FactureModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (StorageService.hasToken()) {
      loadDashboardData();
    }
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      // 1. Fetch Expéditions en cours
      try {
        final resEncours = await ApiService.getExpeditionsEncours();
        final list = (resEncours['data'] as List? ?? [])
            .map((e) => ExpeditionModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        expeditionsEncoursCount.value = list.length;
        recentExpeditions.value = list.take(5).toList();
      } catch (_) {}

      // 2. Fetch Mes expéditions overview count
      try {
        final resExp = await ApiService.getExpeditions(page: 1, pageSize: 5);
        totalExpeditionsCount.value =
            (resExp['totalElements'] as num?)?.toInt() ?? 0;
        if (recentExpeditions.isEmpty) {
          final list = (resExp['data'] as List? ?? [])
              .map(
                (e) => ExpeditionModel.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList();
          recentExpeditions.value = list.take(5).toList();
        }
      } catch (_) {}

      // 3. Fetch Factures en instances
      try {
        final resInst = await ApiService.getFacturesInstances();
        List<FactureModel> listInst = [];
        if (resInst is List) {
          listInst = resInst
              .map((e) => FactureModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else if (resInst is Map && resInst['data'] is List) {
          listInst = (resInst['data'] as List)
              .map((e) => FactureModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
        facturesInstancesCount.value = listInst.length;
        urgentFactures.value = listInst.take(4).toList();

        double total = 0;
        for (var f in listInst) {
          total += (f.solde ?? f.mntTtc ?? 0).toDouble();
        }
        totalSoldeDu.value = total;
      } catch (_) {}

      // 3. Compteurs des retours et du CRBT : on ne demande qu'une ligne,
      // seul `totalElements` nous interesse.
      await Future.wait([
        _compter(
          () => ApiService.getRetourFondCCCT(page: 1, pageSize: 1),
          retoursCcCtCount,
        ),
        _compter(
          () => ApiService.getRetourFondBL(page: 1, pageSize: 1),
          retoursBlCount,
        ),
        _compter(
          () => ApiService.getChequesCrbt(page: 1, pageSize: 1),
          crbtChequesCount,
        ),
        _compter(
          () => ApiService.getVirementCrbt(page: 1, pageSize: 1),
          crbtVirementsCount,
        ),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  /// Lit `totalElements` d'un endpoint pagine ; en cas d'echec le compteur
  /// reste a sa valeur precedente plutot que de faire echouer le tableau.
  Future<void> _compter(
    Future<Map<String, dynamic>> Function() appel,
    RxInt compteur,
  ) async {
    try {
      final res = await appel();
      compteur.value = (res['totalElements'] as num?)?.toInt() ?? 0;
    } catch (_) {}
  }
}
