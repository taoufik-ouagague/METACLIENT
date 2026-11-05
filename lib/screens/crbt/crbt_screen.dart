import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/crbt_controller.dart';
import '../../models/crbt_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/info_rows_card.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/status_badge.dart';

import 'cheque_detail_screen.dart';
import 'virement_detail_screen.dart';
import '../../widgets/scroll_reveal.dart';
import '../../widgets/colis_loader.dart';

class CrbtScreen extends StatelessWidget {
  const CrbtScreen({super.key});

  String _formatCurrency(num? amount) {
    if (amount == null) return '0.00 DH';
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} DH';
  }

  void _openChequeDetail(BuildContext context, ChequeCrbtModel cheque) {
    Get.to(
      () => ChequeDetailScreen(cheque: cheque),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 360),
    );
  }

  void _openVirementDetail(BuildContext context, VirementCrbtModel virement) {
    Get.to(
      () => VirementDetailScreen(virement: virement),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 360),
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
                color: Colors.white.withValues(alpha: 0.7),
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
              return const Center(
                child: ColisLoader(
                  size: 64,
                  message: 'Chargement des règlements...',
                ),
              );
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
        child: Text(
          'Aucune expédition CRBT trouvée',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      itemCount: ctrl.expeditionsCrbt.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final item = ctrl.expeditionsCrbt[idx];
        return ScrollReveal(
          index: idx,
          child: GlassContainer(
            borderRadius: 18,
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Déclaration: ${item.numDeclaration}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (item.typeRemboursementLibelle != null)
                      _badgeType(item.typeRemboursementLibelle!)
                    else
                      StatusBadge(status: item.nature ?? 'CRBT'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Dest: ${item.destinataire ?? "—"} (${item.destination ?? "—"})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatCurrency(item.fond),
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                if (item.dateLivraison != null ||
                    item.dateTaxation != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${item.dateLivraison ?? item.dateTaxation}',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _badgeType(String type) {
    final lower = type.toLowerCase();
    final bool isVir = lower.contains('vir');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isVir ? const Color(0xFF0EA5E9) : const Color(0xFFA855F7))
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (isVir ? const Color(0xFF0EA5E9) : const Color(0xFFA855F7))
              .withValues(alpha: 0.28),
          width: 0.8,
        ),
      ),
      child: Text(
        isVir ? 'Virement' : 'Chèque',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isVir ? const Color(0xFF0284C7) : const Color(0xFF9333EA),
        ),
      ),
    );
  }

  Widget _buildChequesList(BuildContext context, CrbtController ctrl) {
    if (ctrl.chequesCrbt.isEmpty) {
      return const Center(
        child: Text(
          'Aucun chèque CRBT trouvé',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      itemCount: ctrl.chequesCrbt.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final item = ctrl.chequesCrbt[idx];
        return ScrollReveal(
          index: idx,
          child: GlassContainer(
            borderRadius: 18,
            padding: const EdgeInsets.all(15),
            onTap: () => _openChequeDetail(context, item),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.landmark,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              (item.typeRemboursement != null &&
                                      item.typeRemboursement!.toLowerCase().contains('vir'))
                                  ? 'Virement N° ${item.numCheque}'
                                  : 'Chèque N° ${item.numCheque}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (item.typeRemboursement != null &&
                              item.typeRemboursement!.trim().isNotEmpty) ...[
                            const SizedBox(width: 6),
                            _badgeType(item.typeRemboursement!),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Banque: ${item.banque ?? "—"} • Remise: ${item.dateRemise ?? "—"}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatCurrency(item.montant),
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      LucideIcons.chevronRight,
                      color: Color(0xFF94A3B8),
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVirementsList(BuildContext context, CrbtController ctrl) {
    if (ctrl.virementsCrbt.isEmpty) {
      return const Center(
        child: Text(
          'Aucun ordre de virement trouvé',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      itemCount: ctrl.virementsCrbt.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final item = ctrl.virementsCrbt[idx];
        return ScrollReveal(
          index: idx,
          child: GlassContainer(
            borderRadius: 18,
            padding: const EdgeInsets.all(15),
            onTap: () => _openVirementDetail(context, item),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.statusSuccess.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.arrowUpRight,
                    color: AppTheme.statusSuccess,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Virement: ${item.numOv}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Mandat: ${item.numeroMandat ?? "—"} • ${item.dateVirement ?? "—"}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11.5,
                        ),
                      ),
                      if (valeurRenseignee(item.libelleClient) ||
                          valeurRenseignee(item.codeClient)) ...[
                        const SizedBox(height: 2),
                        Text(
                          [
                            item.libelleClient,
                            item.codeClient,
                          ].where(valeurRenseignee).join(' • '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                      if (valeurRenseignee(item.dateMandat) ||
                          valeurRenseignee(item.status)) ...[
                        const SizedBox(height: 2),
                        Text(
                          [
                            if (valeurRenseignee(item.dateMandat))
                              'Mandat du ${item.dateMandat}',
                            if (valeurRenseignee(item.status)) item.status,
                          ].join(' • '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatCurrency(item.fond),
                      style: const TextStyle(
                        color: AppTheme.statusSuccess,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      LucideIcons.chevronRight,
                      color: Color(0xFF94A3B8),
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
