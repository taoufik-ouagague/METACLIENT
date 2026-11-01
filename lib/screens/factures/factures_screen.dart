import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/facture_controller.dart';
import '../../models/facture_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/status_badge.dart';
import 'facture_detail_screen.dart';

class FacturesScreen extends StatelessWidget {
  const FacturesScreen({super.key});

  String _formatCurrency(num? amount) {
    if (amount == null) return '0.00 DH';
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} DH';
  }

  @override
  Widget build(BuildContext context) {
    final factureCtrl = Get.find<FactureController>();

    return Column(
      children: [
        // ─── TOP TABS (EN INSTANCES vs TOUTES) ─────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
          child: Obx(
            () => Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSegmentButton(
                      title: 'En instances (${factureCtrl.facturesInstances.length})',
                      isSelected: factureCtrl.activeTab.value == 0,
                      onTap: () => factureCtrl.activeTab.value = 0,
                    ),
                  ),
                  Expanded(
                    child: _buildSegmentButton(
                      title: 'Toutes (${factureCtrl.totalElements.value})',
                      isSelected: factureCtrl.activeTab.value == 1,
                      onTap: () => factureCtrl.activeTab.value = 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ─── FILTER FOR ALL FACTURES (IF TAB 1) ────────────────────────────
        Obx(() {
          if (factureCtrl.activeTab.value == 1) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Row(
                children: [
                  _buildFilterChip('Tous', 'tous', factureCtrl),
                  const SizedBox(width: 8),
                  _buildFilterChip('Payées / Clôturées', 'cloture', factureCtrl),
                  const SizedBox(width: 8),
                  _buildFilterChip('En cours', 'en cours', factureCtrl),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        const SizedBox(height: 6),

        // ─── LIST CONTENT ──────────────────────────────────────────────────
        Expanded(
          child: Obx(() {
            if (factureCtrl.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryIcons));
            }

            final list = factureCtrl.activeTab.value == 0
                ? factureCtrl.facturesInstances
                : factureCtrl.allFactures;

            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.fileCheck, color: Colors.white.withOpacity(0.3), size: 48),
                    const SizedBox(height: 12),
                    Text(
                      factureCtrl.activeTab.value == 0
                          ? 'Toutes les factures sont à jour (aucun impayé) !'
                          : 'Aucune facture trouvée',
                      style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppTheme.primaryIcons,
              backgroundColor: AppTheme.bgSurface,
              onRefresh: () async {
                if (factureCtrl.activeTab.value == 0) {
                  await factureCtrl.fetchFacturesInstances();
                } else {
                  await factureCtrl.fetchAllFactures();
                }
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return _buildFactureCard(item);
                },
              ),
            );
          }),
        ),

        // ─── PAGINATION BAR FOR ALL FACTURES ───────────────────────────────
        Obx(() {
          if (factureCtrl.activeTab.value == 1 && factureCtrl.totalPages.value > 1) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: GlassContainer(
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.chevronLeft, color: AppTheme.primaryIcons),
                      onPressed: factureCtrl.currentPage.value > 1 ? factureCtrl.previousPage : null,
                    ),
                    Text(
                      'Page ${factureCtrl.currentPage.value} / ${factureCtrl.totalPages.value}',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.chevronRight, color: AppTheme.primaryIcons),
                      onPressed:
                          factureCtrl.currentPage.value < factureCtrl.totalPages.value
                              ? factureCtrl.nextPage
                              : null,
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : Colors.transparent,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, FactureController ctrl) {
    final isSel = ctrl.filterStatut.value == value;
    return GestureDetector(
      onTap: () {
        ctrl.filterStatut.value = value;
        ctrl.fetchAllFactures(resetPage: true);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.primaryIcons.withOpacity(0.2) : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSel ? AppTheme.primaryIcons : Colors.white.withOpacity(0.12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSel ? AppTheme.primaryIcons : Colors.white70,
            fontSize: 12,
            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFactureCard(FactureModel item) {
    final hasSolde = item.solde != null && item.solde! > 0;

    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      onTap: () => Get.to(() => FactureDetailScreen(facture: item)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hasSolde
                          ? AppTheme.statusDanger.withOpacity(0.15)
                          : AppTheme.statusSuccess.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      hasSolde ? LucideIcons.fileWarning : LucideIcons.fileCheck2,
                      color: hasSolde ? AppTheme.statusDanger : AppTheme.statusSuccess,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Facture N° ${item.numFacture}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.dateFacture ?? '—',
                        style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              StatusBadge(status: item.statut ?? (hasSolde ? 'En instance' : 'Payée')),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Montant TTC',
                    style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(item.mntTtc),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Reste à payer (Solde)',
                    style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(item.solde ?? (item.isPayee ? 0 : item.mntTtc)),
                    style: TextStyle(
                      color: hasSolde ? AppTheme.statusDanger : AppTheme.statusSuccess,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
