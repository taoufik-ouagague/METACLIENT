import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/auth_controller.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_text_field.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static void showServerConfigDialog(BuildContext context) {
    final urlCtrl = TextEditingController(text: ApiService.baseUrl);

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.server, color: AppTheme.primary, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Configuration API',
                    style: TextStyle(color: Color(0xFF0F172A), fontSize: 16.5, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Adresse URL du backend METACLIENT :',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const SizedBox(height: 12),
              GlassTextField(
                controller: urlCtrl,
                hintText: 'https://metaphore.kaytechnology.com:6799/CLIENTMOBILE',
                prefixIcon: LucideIcons.link,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Annuler', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (urlCtrl.text.trim().isNotEmpty) {
                        await ApiService.updateBaseUrl(urlCtrl.text.trim());
                        Get.back();
                        Get.snackbar(
                          'Serveur mis à jour',
                          ApiService.baseUrl,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppTheme.statusSuccess.withOpacity(0.85),
                          colorText: Colors.white,
                        );
                      }
                    },
                    child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── PROFILE AVATAR & RAISON SOCIALE ─────────────────────────────
          Obx(() {
            final client = authCtrl.clientInfo.value;
            final user = authCtrl.currentUser.value;
            final name = client?.raisonSociale.isNotEmpty == true
                ? client!.raisonSociale
                : (user?.libelle ?? 'Client');
            final code = client?.code.isNotEmpty == true ? client!.code : (user?.code ?? '—');

            return GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.all(22),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppTheme.iconGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryIcons.withOpacity(0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.building2, color: Colors.white, size: 40),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Code Client: $code',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // ─── CLIENT INFO DETAILS ─────────────────────────────────────────
          const Row(
            children: [
              Icon(LucideIcons.info, color: AppTheme.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Coordonnées & Affectation',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Obx(() {
            final client = authCtrl.clientInfo.value;
            return GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _buildInfoRow(LucideIcons.mapPin, 'Adresse', client?.adresse ?? '—'),
                  const Divider(color: Color(0xFFE2E8F0), height: 20),
                  _buildInfoRow(LucideIcons.building, 'Agence d\'affectation', client?.agenceAffectation ?? '—'),
                  const Divider(color: Color(0xFFE2E8F0), height: 20),
                  _buildInfoRow(LucideIcons.userCheck, 'Commercial dédié', client?.commercialLibelle ?? '—'),
                  const Divider(color: Color(0xFFE2E8F0), height: 20),
                  _buildInfoRow(LucideIcons.phone, 'Téléphone', client?.telephone ?? '—'),
                  if (client?.commercialTelephone != null && client!.commercialTelephone!.isNotEmpty) ...[
                    const Divider(color: Color(0xFFE2E8F0), height: 20),
                    _buildInfoRow(LucideIcons.phoneCall, 'Tél. Commercial', client.commercialTelephone!),
                  ],
                  if (client?.email != null && client!.email!.isNotEmpty) ...[
                    const Divider(color: Color(0xFFE2E8F0), height: 20),
                    _buildInfoRow(LucideIcons.mail, 'Email', client.email!),
                  ],
                ],
              ),
            );
          }),

          const SizedBox(height: 22),

          // ─── PARAMÈTRES RÉSEAU ───────────────────────────────────────────
          const Row(
            children: [
              Icon(LucideIcons.settings, color: AppTheme.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Paramètres Système',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          GlassContainer(
            borderRadius: 20,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.server, color: AppTheme.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Serveur API', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700, fontSize: 14)),
                            Text(ApiService.baseUrl, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5)),
                          ],
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => showServerConfigDialog(context),
                      child: const Text('Modifier', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          // ─── LOGOUT BUTTON ───────────────────────────────────────────────
          GlassButton(
            text: 'Se déconnecter',
            icon: LucideIcons.logOut,
            gradient: const LinearGradient(
              colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
            ),
            onPressed: () => authCtrl.logout(),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primary, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
