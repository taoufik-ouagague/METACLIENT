import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/expedition_controller.dart';
import '../../controllers/agence_controller.dart';
import '../../controllers/prepaye_controller.dart';
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
    final prepayeCtrl = Get.find<PrepayeController>();
    final agenceCtrl = Get.find<AgenceController>();
    final searchCtrl = TextEditingController();

    return RefreshIndicator(
      color: AppTheme.primary,
      backgroundColor: Colors.white,
      onRefresh: () async {
        await dashCtrl.loadDashboardData();
        await authCtrl.fetchClientInfo();
        await prepayeCtrl.fetchReleve();
        await agenceCtrl.fetchAgences();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        // Un padding explicite ecrase celui que le Scaffold reserve pour la
        // barre flottante : on le reprend, sinon la derniere rangee reste
        // cachee dessous.
        padding: EdgeInsets.fromLTRB(
          18,
          14,
          18,
          14 + MediaQuery.paddingOf(context).bottom,
        ),
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

            const SizedBox(height: 16),

            // ─── 2. CARTE DE TÊTE : CE QUE LE CLIENT VIENT VOIR ─────────────
            Obx(
              () => ScrollReveal.grille(
                index: 1,
                child: StatCard(
                  vedette: true,
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

            const SizedBox(height: 10),

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
                            attenue:
                                dashCtrl.expeditionsEncoursCount.value == 0,
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
                            attenue: dashCtrl.facturesInstancesCount.value == 0,
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
                          child: Obx(
                            () => StatCard(
                              chargement: prepayeCtrl.isLoading.value,
                              title: 'Solde prépayé',
                              value: _formatCurrency(prepayeCtrl.solde),
                              icon: LucideIcons.wallet,
                              color: const Color(0xFF0D9488),
                              onTap: () => onNavigateTab?.call(5),
                            ),
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
                        attenue: dashCtrl.retoursCcCtCount.value == 0,
                        title: 'Chèques / Traites',
                        value: '${dashCtrl.retoursCcCtCount.value}',
                        icon: LucideIcons.rotateCcw,
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
                        attenue: dashCtrl.retoursBlCount.value == 0,
                        title: 'Retours BL / Factures',
                        value: '${dashCtrl.retoursBlCount.value}',
                        icon: LucideIcons.receipt,
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
                        attenue: dashCtrl.crbtChequesCount.value == 0,
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
                        attenue: dashCtrl.crbtVirementsCount.value == 0,
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

            const SizedBox(height: 10),

            // ─── 5. LE RÉSEAU ───────────────────────────────────────────────
            // Pleine largeur : impair dans la grille, et de nature differente
            // des compteurs du compte client.
            Obx(
              () => ScrollReveal.grille(
                index: 9,
                child: StatCard(
                  chargement: agenceCtrl.isLoading.value,
                  attenue: agenceCtrl.agences.isEmpty,
                  title: 'Agences du réseau',
                  value: '${agenceCtrl.agences.length}',
                  icon: LucideIcons.building2,
                  subtitle: 'Réseau',
                  color: const Color(0xFF4F46E5),
                  onTap: () => onNavigateTab?.call(6),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
