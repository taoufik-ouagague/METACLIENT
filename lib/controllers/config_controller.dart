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
  Color get secondaryColor => clientConfig.value?.secondary ?? AppTheme.primaryIcons;
  Color get optionalColor => clientConfig.value?.optional ?? const Color(0xFFFDEB03);
  Color? get rawOptionalColor => clientConfig.value?.optional;
  String? get logoUrl => clientConfig.value?.logoUrl;

  bool get hasCustomColors =>
      clientConfig.value?.primary != null || clientConfig.value?.secondary != null;

  LinearGradient get buttonGradient {
    return clientConfig.value?.buttonGradient ?? AppTheme.primaryGradient;
  }

  // 3-color brand gradient (Blue -> Green -> Yellow)
  LinearGradient get brandGradient {
    if (hasCustomColors) {
      final p = primaryColor;
      final s = secondaryColor;
      final o = optionalColor;
      return LinearGradient(
        colors: [p, s, o],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }
    return AppTheme.iconGradient;
  }

  // Accent gradient (Green -> Yellow)
  LinearGradient get accentGradient {
    if (hasCustomColors) {
      return LinearGradient(
        colors: [secondaryColor, optionalColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return AppTheme.iconGradient;
  }
}
