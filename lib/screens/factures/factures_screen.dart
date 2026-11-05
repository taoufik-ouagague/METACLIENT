import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/facture_controller.dart';
import '../../models/facture_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/barre_segments.dart';
import '../../widgets/carte_liste.dart';
import '../../widgets/status_badge.dart';
import 'facture_detail_screen.dart';
import '../../widgets/scroll_reveal.dart';

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
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: BarreSegments(
                libelles: [
                  'En instances (${factureCtrl.facturesInstances.length})',
                  'Toutes (${factureCtrl.totalElements.value})',
                ],
                index: factureCtrl.activeTab.value,
                onChange: (i) => factureCtrl.activeTab.value = i,
                tailleTexte: 13,
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
                  _buildFilterChip(
                    'Payées / Clôturées',
                    'cloture',
                    factureCtrl,
                  ),
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
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }

            final list = factureCtrl.activeTab.value == 0
                ? factureCtrl.facturesInstances
                : factureCtrl.allFactures;

            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      LucideIcons.fileCheck,
                      color: Color(0xFFCBD5E1),
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      factureCtrl.activeTab.value == 0
                          ? 'Toutes les factures sont à jour (aucun impayé) !'
                          : 'Aucune facture trouvée',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: Colors.white,
              onRefresh: () async {
                if (factureCtrl.activeTab.value == 0) {
                  await factureCtrl.fetchFacturesInstances();
                } else {
                  await factureCtrl.fetchAllFactures();
                }
              },
              child: ListView.separated(
                // Nouvelle cle a chaque onglet : la revelation rejoue.
                key: ValueKey<int>(factureCtrl.activeTab.value),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return ScrollReveal(
                    index: index,
                    child: _buildFactureCard(item),
                  );
                },
              ),
            );
          }),
        ),

        // ─── PAGINATION BAR FOR ALL FACTURES ───────────────────────────────
        Obx(() {
          if (factureCtrl.activeTab.value == 1 &&
              factureCtrl.totalPages.value > 1) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: CarteListe(
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        LucideIcons.chevronLeft,
                        color: AppTheme.primary,
                      ),
                      onPressed: factureCtrl.currentPage.value > 1
                          ? factureCtrl.previousPage
                          : null,
                    ),
                    Text(
                      'Page ${factureCtrl.currentPage.value} / ${factureCtrl.totalPages.value}',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        LucideIcons.chevronRight,
                        color: AppTheme.primary,
                      ),
                      onPressed:
                          factureCtrl.currentPage.value <
                              factureCtrl.totalPages.value
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

  Widget _buildFilterChip(String label, String value, FactureController ctrl) {
    final isSel = ctrl.filterStatut.value == value;
    return GestureDetector(
      onTap: () {
        ctrl.filterStatut.value = value;
        ctrl.fetchAllFactures(resetPage: true);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSel ? AppTheme.primaryGradient : null,
          color: isSel ? null : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isSel ? Colors.transparent : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: isSel
                  ? AppTheme.primary.withValues(alpha: 0.30)
                  : const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSel ? Colors.white : const Color(0xFF475569),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildFactureCard(FactureModel item) {
    final hasSolde = item.solde != null && item.solde! > 0;

    return CarteListe(
      padding: const EdgeInsets.all(16),
      onTap: () => Get.to(
        () => FactureDetailScreen(facture: item),
        transition: Transition.cupertino,
        duration: const Duration(milliseconds: 360),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasSolde
                      ? AppTheme.statusDanger.withValues(alpha: 0.12)
                      : AppTheme.statusSuccess.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasSolde ? LucideIcons.fileWarning : LucideIcons.fileCheck2,
                  color: hasSolde
                      ? AppTheme.statusDanger
                      : AppTheme.statusSuccess,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'N° ${item.numFacture}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.dateFacture ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                status: item.statut ?? (hasSolde ? 'En instance' : 'Payée'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Montant TTC',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(item.mntTtc),
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Reste à payer (Solde)',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(
                      item.solde ?? (item.isPayee ? 0 : item.mntTtc),
                    ),
                    style: TextStyle(
                      color: hasSolde
                          ? AppTheme.statusDanger
                          : AppTheme.statusSuccess,
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
