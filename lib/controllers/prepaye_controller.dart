import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/releve_prepaye_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class PrepayeController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<RelevePrepayeModel> lignes = <RelevePrepayeModel>[].obs;

  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalElements = 0.obs;

  final RxString filterDu = ''.obs;
  final RxString filterAu = ''.obs;

  /// '' = tout, 'C' = alimentations, 'D' = consommations.
  final RxString filterSens = ''.obs;

  /// Une borne de date au moins est posee.
  bool get periodeActive =>
      filterDu.value.isNotEmpty || filterAu.value.isNotEmpty;

  bool get filtresActifs => periodeActive || filterSens.value.isNotEmpty;

  /// Periode telle qu'elle se lit sur le bouton, une seule borne comprise.
  String get libellePeriode {
    final du = filterDu.value;
    final au = filterAu.value;
    if (du.isEmpty) return 'Jusqu\'au $au';
    if (au.isEmpty) return 'Depuis le $du';
    return '$du  →  $au';
  }

  /// `jj/MM/aaaa` -> date, ou null si la chaine n'a pas cette forme.
  static DateTime? _date(String? texte) {
    final parts = (texte ?? '').split('/');
    if (parts.length != 3) return null;
    final j = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final a = int.tryParse(parts[2]);
    if (j == null || m == null || a == null) return null;
    return DateTime(a, m, j);
  }

  /// Le sens et la periode sont appliques ici : l'API du releve ne prend pas
  /// de corps (elle repond 405 en POST), donc elle ne sait pas filtrer.
  List<RelevePrepayeModel> get lignesAffichees {
    final sens = filterSens.value;
    final du = _date(filterDu.value);
    final au = _date(filterAu.value);

    return lignes.where((l) {
      if (sens.isNotEmpty && l.estCredit != (sens == 'C')) return false;

      if (du != null || au != null) {
        final d = _date(l.dateOperation);
        if (d == null) return false;
        if (du != null && d.isBefore(du)) return false;
        if (au != null && d.isAfter(au)) return false;
      }
      return true;
    }).toList();
  }

  /// Totaux de ce qui est affiche, pas du compte entier : l'API pagine, et la
  /// reponse d'exemple renvoie `totalElements: 0`. Le libelle de l'ecran le dit.
  num get totalCredits => lignesAffichees
      .where((l) => l.estCredit)
      .fold<num>(0, (somme, l) => somme + l.montant);
  num get totalDebits => lignesAffichees
      .where((l) => !l.estCredit)
      .fold<num>(0, (somme, l) => somme + l.montant);
  num get solde => totalCredits - totalDebits;

  @override
  void onInit() {
    super.onInit();
    if (StorageService.hasToken()) fetchReleve();
  }

  Future<void> fetchReleve({bool resetPage = false}) async {
    if (resetPage) currentPage.value = 1;

    try {
      isLoading.value = true;
      final res = await ApiService.getRelevePrepaye(
        page: currentPage.value,
        pageSize: 20,
      );

      lignes.value = (res['data'] as List? ?? [])
          .map((e) => RelevePrepayeModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      totalPages.value = (res['totalPages'] as num?)?.toInt() ?? 1;
      totalElements.value = (res['totalElements'] as num?)?.toInt() ?? 0;
    } catch (e) {
      Get.snackbar(
        'Relevé indisponible',
        e.toString().replaceAll('ApiException', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void pageSuivante() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      fetchReleve();
    }
  }

  void pagePrecedente() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchReleve();
    }
  }
}
