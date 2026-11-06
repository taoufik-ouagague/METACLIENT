import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/client_config_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class ConfigController extends GetxController {
  final Rxn<ClientConfigModel> clientConfig = Rxn<ClientConfigModel>();
  final RxBool isLoadingConfig = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCachedConfig();
    fetchConfig();
  }

  void _loadCachedConfig() {
    try {
      final raw = StorageService.getClientConfigRaw();
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          clientConfig.value = ClientConfigModel.fromJson(decoded);
        }
      }
    } catch (_) {}
  }

  Future<void> fetchConfig() async {
    try {
      isLoadingConfig.value = true;
      final res = await ApiService.getConfig();
      if (res['config'] != null && res['config'] is Map) {
        final configMap = Map<String, dynamic>.from(res['config']);
        final config = ClientConfigModel.fromJson(configMap);
        clientConfig.value = config;
        await StorageService.setClientConfigRaw(jsonEncode(configMap));
      }
    } catch (e) {
      // If network error, retain cached config or defaults
    } finally {
      isLoadingConfig.value = false;
    }
  }

  Color get primaryColor => clientConfig.value?.primary ?? AppTheme.primary;
  Color get secondaryColor =>
      clientConfig.value?.secondary ?? AppTheme.primaryIcons;
  Color get optionalColor =>
      clientConfig.value?.optional ?? AppTheme.accentCyan;
  Color? get rawOptionalColor => clientConfig.value?.optional;
  String? get logoUrl => clientConfig.value?.logoUrl;

  bool get hasCustomColors =>
      clientConfig.value?.primary != null ||
      clientConfig.value?.secondary != null;

  LinearGradient get buttonGradient {
    return clientConfig.value?.buttonGradient ?? AppTheme.primaryGradient;
  }

  // Brand gradient (Theme cyan / blue)
  LinearGradient get brandGradient {
    return AppTheme.iconGradient;
  }

  // Accent gradient (Theme cyan / blue)
  LinearGradient get accentGradient {
    return AppTheme.iconGradient;
  }
}
