import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/crbt_controller.dart';
import '../../models/crbt_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/status_badge.dart';

class CrbtScreen extends StatelessWidget {
  const CrbtScreen({super.key});

  String _formatCurrency(num? amount) {
    if (amount == null) return '0.00 DH';
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} DH';
  }

  void _showChequeDetailDialog(BuildContext context, ChequeCrbtModel cheque, CrbtController ctrl) {
    ctrl.fetchChequeDetail(cheque.idCheque);

    Get.bottomSheet(
      GlassContainer(
        borderRadius: 28,
        padding: const EdgeInsets.all(22),
        color: Colors.white.withOpacity(0.96),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chèque N° ${cheque.numCheque}',
                      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Banque: ${cheque.banque ?? "—"} • ${_formatCurrency(cheque.montant)}',
                      style: const TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: Color(0xFF64748B)),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: Color(0xFFE2E8F0), height: 1),
            const SizedBox(height: 14),

            const Text(
              'Expéditions couvertes par ce chèque :',
              style: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            Obx(() {
              if (ctrl.isLoadingDetail.value) {
                return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppTheme.primary)));
              }

              if (ctrl.selectedChequeDetails.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('Aucune expédition rattachée', style: TextStyle(color: Color(0xFF64748B)))),
                );
              }

              return Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: ctrl.selectedChequeDetails.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final item = ctrl.selectedChequeDetails[idx];
                    return GlassContainer(
                      borderRadius: 14,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Décl: ${item.numDeclaration}', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700, fontSize: 13)),
                              Text('Dest: ${item.destinataire ?? "—"} (${item.destination ?? "—"})', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5)),
                            ],
                          ),
                          Text(_formatCurrency(item.montant), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 13.5)),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showVirementDetailDialog(BuildContext context, VirementCrbtModel virement, CrbtController ctrl) {
    ctrl.fetchVirementDetail(virement.idVirement);

    Get.bottomSheet(
      GlassContainer(
        borderRadius: 28,
        padding: const EdgeInsets.all(22),
        color: Colors.white.withOpacity(0.96),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ordre de Virement ${virement.numOv}',
                      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Mandat: ${virement.numeroMandat ?? "—"} • ${_formatCurrency(virement.fond)}',
                      style: const TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: Color(0xFF64748B)),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: Color(0xFFE2E8F0), height: 1),
            const SizedBox(height: 14),

            const Text(
              'Expéditions créditées par ce virement :',
              style: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            Obx(() {
              if (ctrl.isLoadingDetail.value) {
                return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppTheme.primary)));
              }

              if (ctrl.selectedVirementDetails.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('Aucune expédition rattachée', style: TextStyle(color: Color(0xFF64748B)))),
                );
              }

              return Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: ctrl.selectedVirementDetails.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final item = ctrl.selectedVirementDetails[idx];
                    return GlassContainer(
                      borderRadius: 14,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Décl: ${item.numDeclaration}', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700, fontSize: 13)),
                              Text('Dest: ${item.destinataire ?? "—"} (${item.destination ?? "—"})', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5)),
                            ],
                          ),
                          Text(_formatCurrency(item.montant), style: const TextStyle(color: AppTheme.statusSuccess, fontWeight: FontWeight.w700, fontSize: 13.5)),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final crbtCtrl = Get.find<CrbtController>();

    return Column(
      children: [
        // ─── TOP TABS (EXPÉDITIONS CRBT vs CHÈQUES vs VIREMENTS) ───────────
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
          child: Obx(
            () => Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSegmentButton(
                      title: 'Expéditions (${crbtCtrl.expeditionsCrbt.length})',
                      isSelected: crbtCtrl.activeTab.value == 0,
                      onTap: () => crbtCtrl.activeTab.value = 0,
                    ),
                  ),
                  Expanded(
                    child: _buildSegmentButton(
                      title: 'Chèques (${crbtCtrl.chequesCrbt.length})',
                      isSelected: crbtCtrl.activeTab.value == 1,
                      onTap: () => crbtCtrl.activeTab.value = 1,
                    ),
                  ),
                  Expanded(
                    child: _buildSegmentButton(
                      title: 'Virements (${crbtCtrl.virementsCrbt.length})',
                      isSelected: crbtCtrl.activeTab.value == 2,
                      onTap: () => crbtCtrl.activeTab.value = 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // ─── LIST CONTENT ──────────────────────────────────────────────────
        Expanded(
          child: Obx(() {
            if (crbtCtrl.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
            }

            if (crbtCtrl.activeTab.value == 0) {
              return _buildExpeditionsList(crbtCtrl);
            } else if (crbtCtrl.activeTab.value == 1) {
              return _buildChequesList(context, crbtCtrl);
            } else {
              return _buildVirementsList(context, crbtCtrl);
            }
          }),
        ),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpeditionsList(CrbtController ctrl) {
    if (ctrl.expeditionsCrbt.isEmpty) {
      return const Center(
        child: Text('Aucune expédition CRBT trouvée', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      itemCount: ctrl.expeditionsCrbt.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final item = ctrl.expeditionsCrbt[idx];
        return GlassContainer(
          borderRadius: 18,
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Déclaration: ${item.numDeclaration}', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14.5, fontWeight: FontWeight.w700)),
                  StatusBadge(status: item.nature ?? 'CRBT'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dest: ${item.destinataire ?? "—"} (${item.destination ?? "—"})', style: const TextStyle(color: Color(0xFF475569), fontSize: 12.5)),
                  Text(_formatCurrency(item.fond), style: const TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w800)),
                ],
              ),
              if (item.dateLivraison != null || item.dateTaxation != null) ...[
                const SizedBox(height: 4),
                Text('Date: ${item.dateLivraison ?? item.dateTaxation}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildChequesList(BuildContext context, CrbtController ctrl) {
    if (ctrl.chequesCrbt.isEmpty) {
      return const Center(
        child: Text('Aucun chèque CRBT trouvé', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      itemCount: ctrl.chequesCrbt.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final item = ctrl.chequesCrbt[idx];
        return GlassContainer(
          borderRadius: 18,
          padding: const EdgeInsets.all(15),
          onTap: () => _showChequeDetailDialog(context, item, ctrl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.landmark, color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chèque N° ${item.numCheque}', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14.5, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text('Banque: ${item.banque ?? "—"} • Remise: ${item.dateRemise ?? "—"}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Text(_formatCurrency(item.montant), style: const TextStyle(color: AppTheme.primary, fontSize: 14.5, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 6),
                  const Icon(LucideIcons.chevronRight, color: Color(0xFF94A3B8), size: 16),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVirementsList(BuildContext context, CrbtController ctrl) {
    if (ctrl.virementsCrbt.isEmpty) {
      return const Center(
        child: Text('Aucun ordre de virement trouvé', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      itemCount: ctrl.virementsCrbt.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final item = ctrl.virementsCrbt[idx];
        return GlassContainer(
          borderRadius: 18,
          padding: const EdgeInsets.all(15),
          onTap: () => _showVirementDetailDialog(context, item, ctrl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.statusSuccess.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.arrowUpRight, color: AppTheme.statusSuccess, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Virement: ${item.numOv}', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14.5, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text('Mandat: ${item.numeroMandat ?? "—"} • ${item.dateVirement ?? "—"}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Text(_formatCurrency(item.fond), style: const TextStyle(color: AppTheme.statusSuccess, fontSize: 14.5, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 6),
                  const Icon(LucideIcons.chevronRight, color: Color(0xFF94A3B8), size: 16),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
