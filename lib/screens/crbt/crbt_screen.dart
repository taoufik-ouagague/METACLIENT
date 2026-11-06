import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/crbt_controller.dart';
import '../../models/crbt_model.dart';
import '../../widgets/barre_segments.dart';
import '../../theme/app_theme.dart';
import '../../widgets/carte_accent.dart';
import '../../widgets/etiquette_valeur.dart';
import '../../widgets/info_rows_card.dart';
import '../../widgets/status_badge.dart';

import 'cheque_detail_screen.dart';
import 'virement_detail_screen.dart';
import '../../widgets/scroll_reveal.dart';

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
              child: BarreSegments(
                libelles: [
                  'Expéditions (${crbtCtrl.expeditionsCrbt.length})',
                  'Chèques (${crbtCtrl.chequesCrbt.length})',
                  'Virements (${crbtCtrl.virementsCrbt.length})',
                ],
                index: crbtCtrl.activeTab.value,
                onChange: (i) => crbtCtrl.activeTab.value = i,
                tailleTexte: 11.5,
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
                child: CircularProgressIndicator(color: AppTheme.primary),
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

  /// « icone + texte » : l'icone dit la nature du champ, la couleur le relie
  /// au reste de la carte.
  Widget _mention(IconData icone, String texte, Color couleur) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 13, color: couleur.withValues(alpha: 0.75)),
        const SizedBox(width: 4),
        Text(
          texte,
          style: TextStyle(
            color: couleur,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
      // Nouvelle cle a chaque onglet : la revelation rejoue.
      key: const ValueKey<String>('expeditionsCrbt'),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      itemCount: ctrl.expeditionsCrbt.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final item = ctrl.expeditionsCrbt[idx];
        return ScrollReveal(
          index: idx,
          child: CarteAccent(
            teinte: AppTheme.primary,
            icone: LucideIcons.package,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(19, 15, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: EtiquetteValeur(
                          intitule: 'Déclaration : ',
                          valeur: item.numDeclaration,
                          couleur: AppTheme.primary,
                          couleurIntitule: const Color(0xFF475569),
                          taille: 14.5,
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
                  // Destinataire et destination sur toute la largeur, avec
                  // leur icone : en partageant la ligne avec le montant, le
                  // nom finissait en « … ».
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _mention(
                        LucideIcons.user,
                        item.destinataire ?? '—',
                        const Color(0xFF7C3AED),
                      ),
                      _mention(
                        LucideIcons.mapPin,
                        item.destination ?? '—',
                        const Color(0xFF0284C7),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child:
                            item.dateLivraison != null ||
                                item.dateTaxation != null
                            ? EtiquetteValeur(
                                intitule: 'Date : ',
                                valeur:
                                    '${item.dateLivraison ?? item.dateTaxation}',
                                couleur: const Color(0xFF059669),
                              )
                            : const SizedBox.shrink(),
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
                ],
              ),
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
      // Nouvelle cle a chaque onglet : la revelation rejoue.
      key: const ValueKey<String>('chequesCrbt'),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      itemCount: ctrl.chequesCrbt.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final item = ctrl.chequesCrbt[idx];
        return ScrollReveal(
          index: idx,
          child: CarteAccent(
            teinte: AppTheme.primary,
            icone: LucideIcons.banknote,
            onTap: () => _openChequeDetail(context, item),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(19, 15, 15, 15),
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
                                        item.typeRemboursement!
                                            .toLowerCase()
                                            .contains('vir'))
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
      // Nouvelle cle a chaque onglet : la revelation rejoue.
      key: const ValueKey<String>('virementsCrbt'),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      itemCount: ctrl.virementsCrbt.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final item = ctrl.virementsCrbt[idx];
        return ScrollReveal(
          index: idx,
          // Meme habillage que les autres listes : le teal porte la carte,
          // le vert reste au montant, seule valeur qui le merite.
          child: CarteAccent(
            teinte: AppTheme.primary,
            icone: LucideIcons.arrowUpRight,
            onTap: () => _openVirementDetail(context, item),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(19, 15, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          LucideIcons.arrowUpRight,
                          color: AppTheme.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 11),
                      // Le numero seul, sans l'intitule « Virement » que
                      // l'onglet et l'icone disent deja, avec le montant au
                      // bout de la meme ligne.
                      Expanded(
                        child: Text(
                          item.numOv,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatCurrency(item.fond),
                        style: const TextStyle(
                          color: AppTheme.statusSuccess,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        LucideIcons.chevronRight,
                        color: Color(0xFF94A3B8),
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  // Les mentions se replient : sur une seule ligne partagee
                  // avec le montant, elles finissaient toutes en « … ».
                  Wrap(
                    spacing: 12,
                    runSpacing: 5,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Le client n'est pas repete : toute la liste est la
                      // sienne, le nom et le code ne distinguaient rien.
                      if (valeurRenseignee(item.numeroMandat))
                        _mention(
                          LucideIcons.hash,
                          'Mandat ${item.numeroMandat}',
                          const Color(0xFF7C3AED),
                        ),
                      if (valeurRenseignee(item.dateVirement))
                        _mention(
                          LucideIcons.calendar,
                          item.dateVirement!,
                          const Color(0xFF4F46E5),
                        ),
                      if (valeurRenseignee(item.dateMandat))
                        _mention(
                          LucideIcons.fileSignature,
                          'Mandat du ${item.dateMandat}',
                          const Color(0xFF0284C7),
                        ),
                      if (valeurRenseignee(item.status))
                        _mention(
                          LucideIcons.circleDot,
                          item.status!,
                          const Color(0xFFD97706),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
