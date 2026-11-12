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

import 'cheque_detail_screen.dart';
import 'virement_detail_screen.dart';
import '../../widgets/scroll_infini.dart';
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
                  'Expéditions (${crbtCtrl.totalElementsExpeditions.value})',
                  'Chèques (${crbtCtrl.totalElementsCheques.value})',
                  'Virements (${crbtCtrl.totalElementsVirements.value})',
                ],
                index: crbtCtrl.activeTab.value,
                onChange: (i) => crbtCtrl.activeTab.value = i,
                tailleTexte: 11.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // ─── LIST CONTENT AVEC SCROLL INFINI & PULL-TO-REFRESH ──────────────
        Expanded(
          child: Obx(() {
            if (crbtCtrl.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }

            final pied = crbtCtrl.isLoadingMore.value;

            return ScrollInfini(
              onFin: crbtCtrl.chargerPlus,
              child: RefreshIndicator(
                color: AppTheme.primary,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  switch (crbtCtrl.activeTab.value) {
                    case 0:
                      await crbtCtrl.fetchExpeditionsCrbt(resetPage: true);
                      break;
                    case 1:
                      await crbtCtrl.fetchChequesCrbt(resetPage: true);
                      break;
                    case 2:
                      await crbtCtrl.fetchVirementsCrbt(resetPage: true);
                      break;
                  }
                },
                child: switch (crbtCtrl.activeTab.value) {
                  0 => _buildExpeditionsList(context, crbtCtrl, pied),
                  1 => _buildChequesList(context, crbtCtrl, pied),
                  _ => _buildVirementsList(context, crbtCtrl, pied),
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  /// « icone + texte » : l'icone dit la nature du champ, la couleur le relie
  /// au reste de la carte.
  Widget _mention(
    IconData icone,
    String texte,
    Color couleur, {
    String? intitule,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 11.5, color: couleur.withValues(alpha: 0.75)),
        const SizedBox(width: 3.5),
        if (intitule != null)
          EtiquetteValeur(
            intitule: intitule,
            valeur: texte,
            couleur: couleur,
            taille: 10.5,
          )
        else
          Text(
            texte,
            style: TextStyle(
              color: couleur,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }

  Widget _buildExpeditionsList(
    BuildContext context,
    CrbtController ctrl,
    bool pied,
  ) {
    if (ctrl.expeditionsCrbt.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.packageOpen,
                  color: Color(0xFFCBD5E1),
                  size: 48,
                ),
                SizedBox(height: 12),
                Text(
                  'Aucune expédition CRBT trouvée',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      // Nouvelle cle a chaque onglet : la revelation rejoue.
      key: const ValueKey<String>('expeditionsCrbt'),
      padding: EdgeInsets.fromLTRB(
        18,
        6,
        18,
        8 + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: ctrl.expeditionsCrbt.length + (pied ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        if (idx >= ctrl.expeditionsCrbt.length) return const PiedChargement();
        final item = ctrl.expeditionsCrbt[idx];
        return ScrollReveal(
          index: idx,
          child: CarteAccent(
            teinte: AppTheme.primary,
            icone: LucideIcons.package,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(13, 10, 11, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      EtiquetteValeur(
                        intitule: 'Déclaration : ',
                        valeur: item.numDeclaration,
                        couleur: AppTheme.primary,
                        couleurIntitule: const Color(0xFF475569),
                        taille: 12.4,
                      ),
                      if (item.nature != null &&
                          item.nature!.trim().isNotEmpty &&
                          item.nature != 'null')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.28),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            item.nature!.trim(),
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _mention(
                    LucideIcons.user,
                    item.destinataire ?? '—',
                    const Color(0xFF334155),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _mention(
                              LucideIcons.mapPin,
                              item.destination ?? '—',
                              const Color(0xFF0284C7),
                            ),
                            if (item.dateLivraison != null ||
                                item.dateTaxation != null)
                              EtiquetteValeur(
                                intitule: 'Date : ',
                                valeur:
                                    '${item.dateLivraison ?? item.dateTaxation}',
                                couleur: const Color(0xFF059669),
                                taille: 10.5,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatCurrency(item.fond),
                        style: const TextStyle(
                          color: Color(0xFF059669),
                          fontSize: 12.5,
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
      padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.5),
      decoration: BoxDecoration(
        color: (isVir ? const Color(0xFF0EA5E9) : const Color(0xFFA855F7))
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: (isVir ? const Color(0xFF0EA5E9) : const Color(0xFFA855F7))
              .withValues(alpha: 0.28),
          width: 0.8,
        ),
      ),
      child: Text(
        isVir ? 'Virement' : 'Chèque',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: isVir ? const Color(0xFF0284C7) : const Color(0xFF9333EA),
        ),
      ),
    );
  }

  Widget _buildChequesList(
    BuildContext context,
    CrbtController ctrl,
    bool pied,
  ) {
    if (ctrl.chequesCrbt.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.banknote,
                  color: Color(0xFFCBD5E1),
                  size: 48,
                ),
                SizedBox(height: 12),
                Text(
                  'Aucun chèque CRBT trouvé',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      // Nouvelle cle a chaque onglet : la revelation rejoue.
      key: const ValueKey<String>('chequesCrbt'),
      padding: EdgeInsets.fromLTRB(
        18,
        6,
        18,
        8 + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: ctrl.chequesCrbt.length + (pied ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        if (idx >= ctrl.chequesCrbt.length) return const PiedChargement();
        final item = ctrl.chequesCrbt[idx];
        return ScrollReveal(
          index: idx,
          child: CarteAccent(
            teinte: AppTheme.primary,
            icone: LucideIcons.banknote,
            onTap: () => _openChequeDetail(context, item),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(13, 10, 11, 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      LucideIcons.landmark,
                      color: AppTheme.primary,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 9),
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
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (item.typeRemboursement != null &&
                                item.typeRemboursement!.trim().isNotEmpty) ...[
                              const SizedBox(width: 5),
                              _badgeType(item.typeRemboursement!),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Banque: ${item.banque ?? "—"} • Remise: ${item.dateRemise ?? "—"}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatCurrency(item.montant),
                        style: const TextStyle(
                          color: Color(0xFF059669),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        LucideIcons.chevronRight,
                        color: Color(0xFF94A3B8),
                        size: 14,
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

  Widget _buildVirementsList(
    BuildContext context,
    CrbtController ctrl,
    bool pied,
  ) {
    if (ctrl.virementsCrbt.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.arrowUpRight,
                  color: Color(0xFFCBD5E1),
                  size: 48,
                ),
                SizedBox(height: 12),
                Text(
                  'Aucun ordre de virement trouvé',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      // Nouvelle cle a chaque onglet : la revelation rejoue.
      key: const ValueKey<String>('virementsCrbt'),
      padding: EdgeInsets.fromLTRB(
        18,
        6,
        18,
        8 + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: ctrl.virementsCrbt.length + (pied ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        if (idx >= ctrl.virementsCrbt.length) return const PiedChargement();
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
              padding: const EdgeInsets.fromLTRB(13, 10, 11, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6.5),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          LucideIcons.arrowUpRight,
                          color: AppTheme.primary,
                          size: 14.5,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatCurrency(item.fond),
                        style: const TextStyle(
                          color: Color(0xFF059669),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        LucideIcons.chevronRight,
                        color: Color(0xFF94A3B8),
                        size: 14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Les mentions se replient : sur une seule ligne partagee
                  // avec le montant, elles finissaient toutes en « … ».
                  Wrap(
                    spacing: 10,
                    runSpacing: 3,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (valeurRenseignee(item.dateVirement))
                        _mention(
                          LucideIcons.calendar,
                          item.dateVirement!,
                          const Color(0xFF4F46E5),
                          intitule: 'Date virement : ',
                        ),
                      if (valeurRenseignee(item.status))
                        _mention(
                          LucideIcons.circleDot,
                          item.status!,
                          const Color(0xFFD97706),
                          intitule: 'Statut : ',
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
