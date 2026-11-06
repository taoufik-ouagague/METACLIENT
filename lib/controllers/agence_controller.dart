import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/agence_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AgenceController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<AgenceModel> agences = <AgenceModel>[].obs;
  final RxString recherche = ''.obs;

  /// Codes des agences dont le detail est deplie. L'etat vit ici et non dans
  /// la carte : la ListView recycle ses lignes, une carte qui garderait son
  /// propre booleen le perdrait au defilement.
  final RxSet<String> deplies = <String>{}.obs;

  void basculer(String code) {
    if (!deplies.remove(code)) deplies.add(code);
  }

  /// Le referentiel tient en un seul appel (environ 80 agences) : il est
  /// charge une fois et filtre localement, sans aller-retour par frappe.
  List<AgenceModel> get agencesAffichees {
    final q = recherche.value.trim().toLowerCase();
    if (q.isEmpty) return agences;
    return agences
        .where(
          (a) =>
              a.libelle.toLowerCase().contains(q) ||
              a.code.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    if (StorageService.hasToken()) fetchAgences();
  }

  Future<void> fetchAgences() async {
    try {
      isLoading.value = true;
      final res = await ApiService.getAgences();
      final liste = (res['data'] as List? ?? [])
          .map((e) => AgenceModel.fromJson(Map<String, dynamic>.from(e)))
          .where((a) => a.libelle.isNotEmpty)
          .toList();
      liste.sort((a, b) => a.libelle.compareTo(b.libelle));
      agences.value = liste;
    } catch (e) {
      Get.snackbar(
        'Agences indisponibles',
        e.toString().replaceAll('ApiException', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
