import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/expedition_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/scroll_reveal.dart';
import '../../widgets/stat_card.dart';

class DashboardTab extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const DashboardTab({super.key, this.onNavigateTab});

  String _formatCurrency(num? amount) {
    if (amount == null) return '0.00 DH';
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} DH';
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final dashCtrl = Get.find<DashboardController>();
    final expCtrl = Get.find<ExpeditionController>();
    final searchCtrl = TextEditingController();

    return RefreshIndicator(
      color: AppTheme.primary,
      backgroundColor: Colors.white,
      onRefresh: () async {
        await dashCtrl.loadDashboardData();
        await authCtrl.fetchClientInfo();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── QUICK DECLARATION SEARCH BAR ─────────────────────────────
            ScrollReveal.grille(
              index: 0,
              child: GlassContainer(
                borderRadius: 18,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.search,
                      color: AppTheme.primaryIcons,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchCtrl,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 13.5,
                        ),
                        decoration: const InputDecoration(
                          hintText:
                              'Rechercher N° déclaration (ex: F644759)...',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (query) {
                          if (query.trim().isNotEmpty) {
                            expCtrl.searchQuery.value = query.trim();
                            expCtrl.fetchAllExpeditions(resetPage: true);
                            onNavigateTab?.call(1);
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        LucideIcons.arrowRightCircle,
                        color: AppTheme.primaryIcons,
                        size: 22,
                      ),
                      onPressed: () {
                        if (searchCtrl.text.trim().isNotEmpty) {
                          expCtrl.searchQuery.value = searchCtrl.text.trim();
                          expCtrl.fetchAllExpeditions(resetPage: true);
                          onNavigateTab?.call(1);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ─── 3. STATS KPI GRID ───────────────────────────────────────────
            Obx(
              () => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ScrollReveal.grille(
                          index: 0,
                          child: StatCard(
                            chargement: dashCtrl.isLoading.value,
                            title: 'En cours de livraison',
                            value: '${dashCtrl.expeditionsEncoursCount.value}',
                            icon: LucideIcons.truck,
                            subtitle: 'En temps réel',
                            color: const Color(0xFF0284C7),
                            onTap: () => onNavigateTab?.call(1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ScrollReveal.grille(
                          index: 1,
                          child: StatCard(
                            chargement: dashCtrl.isLoading.value,
                            title: 'Total Expéditions',
                            value: '${dashCtrl.totalExpeditionsCount.value}',
                            icon: LucideIcons.packageCheck,
                            subtitle: 'Historique',
                            color: const Color(0xFF6366F1),
                            onTap: () => onNavigateTab?.call(1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ScrollReveal.grille(
                          index: 2,
                          child: StatCard(
                            chargement: dashCtrl.isLoading.value,
                            title: 'Factures en instances',
                            value: '${dashCtrl.facturesInstancesCount.value}',
                            icon: LucideIcons.fileWarning,
                            subtitle: 'À régler',
                            color: const Color(0xFFD97706),
                            onTap: () => onNavigateTab?.call(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ScrollReveal.grille(
                          index: 3,
                          child: StatCard(
                            chargement: dashCtrl.isLoading.value,
                            title: 'Solde dû total',
                            value: _formatCurrency(dashCtrl.totalSoldeDu.value),
                            icon: LucideIcons.wallet,
                            subtitle: 'Impayé',
                            color: const Color(0xFFE11D48),
                            onTap: () => onNavigateTab?.call(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── 4. COMPTEURS DES AUTRES ÉCRANS ─────────────────────────────
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: ScrollReveal.grille(
                      index: 4,
                      child: StatCard(
                        chargement: dashCtrl.isLoading.value,
                        title: 'Chèques / Traites',
                        value: '${dashCtrl.retoursCcCtCount.value}',
                        icon: LucideIcons.rotateCcw,
                        subtitle: 'Retours',
                        color: const Color(0xFFA855F7),
                        onTap: () => onNavigateTab?.call(3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ScrollReveal.grille(
                      index: 5,
                      child: StatCard(
                        chargement: dashCtrl.isLoading.value,
                        title: 'Retours BL / Factures',
                        value: '${dashCtrl.retoursBlCount.value}',
                        icon: LucideIcons.receipt,
                        subtitle: 'Documents',
                        color: const Color(0xFF0891B2),
                        onTap: () => onNavigateTab?.call(3),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: ScrollReveal.grille(
                      index: 6,
                      child: StatCard(
                        chargement: dashCtrl.isLoading.value,
                        title: 'Chèques encaissés',
                        value: '${dashCtrl.crbtChequesCount.value}',
                        icon: LucideIcons.banknote,
                        subtitle: 'CRBT',
                        color: const Color(0xFF059669),
                        onTap: () => onNavigateTab?.call(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ScrollReveal.grille(
                      index: 7,
                      child: StatCard(
                        chargement: dashCtrl.isLoading.value,
                        title: 'Ordres de virement',
                        value: '${dashCtrl.crbtVirementsCount.value}',
                        icon: LucideIcons.arrowUpRight,
                        subtitle: 'CRBT',
                        color: const Color(0xFFEC4899),
                        onTap: () => onNavigateTab?.call(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
