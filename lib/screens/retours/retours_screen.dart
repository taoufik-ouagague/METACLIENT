import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/retour_fond_controller.dart';
import '../../models/retour_fond_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/barre_segments.dart';
import '../../widgets/carte_accent.dart';
import '../../widgets/carte_filtres.dart';
import '../../widgets/etiquette_valeur.dart';
import '../../widgets/scroll_infini.dart';
import '../../widgets/scroll_reveal.dart';
import '../../widgets/info_rows_card.dart';
import 'bordereau_detail_screen.dart';

class RetoursScreen extends StatelessWidget {
  const RetoursScreen({super.key});

  String _formatCurrency(num? amount) {
    if (amount == null) return '0.00 DH';
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} DH';
  }

  void _showFilterDialog(BuildContext context, RetourFondController ctrl) {
    final duCtrl = TextEditingController(text: ctrl.filterDu.value);
    final auCtrl = TextEditingController(text: ctrl.filterAu.value);
    final declCtrl = TextEditingController(
      text: ctrl.filterNumDeclaration.value,
    );
    final clientCtrl = TextEditingController(text: ctrl.filterClient.value);
    final pieceCtrl = TextEditingController(text: ctrl.filterNumPiece.value);
    final remis = ctrl.filterRemis.value.obs;

    void relancer() {
      ctrl.fetchRetoursCCCT(resetPage: true);
      ctrl.fetchRetoursBL(resetPage: true);
      Get.back<void>();
    }

    Get.dialog(
      CarteFiltres(
        titre: 'Filtres',
        contenu: [
          // Les deux bornes de date tiennent sur une ligne.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ChampFiltre(
                  controleur: duCtrl,
                  libelle: 'DU',
                  exemple: '01/01/2026',
                  icone: LucideIcons.calendar,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChampFiltre(
                  controleur: auCtrl,
                  libelle: 'AU',
                  exemple: '31/12/2026',
                  icone: LucideIcons.calendar,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ChampFiltre(
            controleur: declCtrl,
            libelle: 'N° DÉCLARATION',
            exemple: '260029143',
            icone: LucideIcons.hash,
          ),
          const SizedBox(height: 16),
          ChampFiltre(
            controleur: clientCtrl,
            libelle: 'CLIENT',
            exemple: 'LUMINEA SANTE',
            icone: LucideIcons.building2,
          ),
          const SizedBox(height: 16),
          ChampFiltre(
            controleur: pieceCtrl,
            libelle: 'N° PIÈCE',
            exemple: '2102282',
            icone: LucideIcons.fileText,
          ),
          const SizedBox(height: 20),
          const LibelleFiltre('REMISE'),
          const SizedBox(height: 9),
          Obx(
            () => RailSegments(
              choix: [
                ChoixSegment(
                  actif: remis.value.isEmpty,
                  libelle: 'Tous',
                  onTap: () => remis.value = '',
                ),
                ChoixSegment(
                  actif: remis.value == 'O',
                  libelle: 'Remis',
                  onTap: () => remis.value = 'O',
                ),
                ChoixSegment(
                  actif: remis.value == 'N',
                  libelle: 'Non remis',
                  onTap: () => remis.value = 'N',
                ),
              ],
            ),
          ),
        ],
        onReinitialiser: () {
          ctrl.filterDu.value = '';
          ctrl.filterAu.value = '';
          ctrl.filterNumDeclaration.value = '';
          ctrl.filterClient.value = '';
          ctrl.filterNumPiece.value = '';
          ctrl.filterRemis.value = '';
          relancer();
        },
        onAppliquer: () {
          ctrl.filterDu.value = duCtrl.text.trim();
          ctrl.filterAu.value = auCtrl.text.trim();
          ctrl.filterNumDeclaration.value = declCtrl.text.trim();
          ctrl.filterClient.value = clientCtrl.text.trim();
          ctrl.filterNumPiece.value = pieceCtrl.text.trim();
          ctrl.filterRemis.value = remis.value;
          relancer();
        },
      ),
      barrierColor: voileFiltres,
    );
  }

  @override
  Widget build(BuildContext context) {
    final retourCtrl = Get.find<RetourFondController>();

    return Obx(() {
      return Column(
        children: [
          // ─── TOP TABS (CC/CT vs BL/FACTURES) ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: BarreSegments(
                libelles: [
                  'Chèques / Traites (${retourCtrl.totalElementsCCCT.value})',
                  'BL / Factures (${retourCtrl.totalElementsBL.value})',
                ],
                index: retourCtrl.activeTab.value,
                onChange: (i) {
                  retourCtrl.activeTab.value = i;
                },
              ),
            ),
          ),

          // ─── RECHERCHE RAPIDE PAR N° DE DÉCLARATION ───────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 2, 18, 2),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        TextEditingController(
                            text: retourCtrl.filterNumDeclaration.value,
                          )
                          ..selection = TextSelection.collapsed(
                            offset: retourCtrl.filterNumDeclaration.value.length,
                          ),
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13.5,
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (v) {
                      retourCtrl.filterNumDeclaration.value = v.trim();
                      retourCtrl.fetchRetoursCCCT(resetPage: true);
                      retourCtrl.fetchRetoursBL(resetPage: true);
                    },
                    decoration: InputDecoration(
                      hintText: 'N° déclaration...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13.5,
                      ),
                      prefixIcon: const Icon(
                        LucideIcons.search,
                        color: AppTheme.primary,
                        size: 18,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.9),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppTheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showFilterDialog(context, retourCtrl),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.32),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.filter,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // ─── LISTE COMPLÈTE ───────────────────────────────────────────────
          Expanded(
            child: Builder(
              builder: (_) {
                if (retourCtrl.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  );
                }

                final list = retourCtrl.activeTab.value == 0
                    ? retourCtrl.retoursCCCTAffiches
                    : retourCtrl.retoursBLAffiches;

                if (list.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.fileSearch,
                          color: Color(0xFFCBD5E1),
                          size: 48,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Aucun retour enregistré',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final pied = retourCtrl.isLoadingMore.value;

                return ScrollInfini(
                  onFin: retourCtrl.chargerPlus,
                  child: RefreshIndicator(
                    color: AppTheme.primary,
                    backgroundColor: Colors.white,
                    onRefresh: () async {
                      if (retourCtrl.activeTab.value == 0) {
                        await retourCtrl.fetchRetoursCCCT(resetPage: true);
                      } else {
                        await retourCtrl.fetchRetoursBL(resetPage: true);
                      }
                    },
                    child: ListView.separated(
                      key: ValueKey<int>(retourCtrl.activeTab.value),
                      padding: EdgeInsets.fromLTRB(
                        18,
                        8,
                        18,
                        8 + MediaQuery.paddingOf(context).bottom,
                      ),
                      itemCount: list.length + (pied ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        if (index >= list.length) {
                          return const PiedChargement();
                        }
                        final item = list[index];
                        return ScrollReveal(
                          index: index,
                          child: _buildRetourCard(context, item),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildRetourCard(BuildContext context, RetourFondModel item) {
    final isMoney = item.fond != null && item.fond! > 0;

    // Couleurs relevees au pixel sur la maquette.
    const bleu = Color(0xFF007EBE);
    const bleuVif = Color(0xFF1263BF);
    const gris = Color(0xFF637D9B);
    const vert = Color(0xFF00927A);

    // Les tailles de la maquette (1774 px pour ~366 pt) ramenees a la hauteur
    // des cartes d'expedition, w x 334/953.
    const k = 0.62;
    const serre = 1.1;

    return CarteAccent(
      teinte: bleu,
      icone: isMoney ? LucideIcons.coins : LucideIcons.fileText,
      fondTeinte: false,
      fond: const Color(0xFFEFF8FE),
      rayon: 18,
      ombres: [
        BoxShadow(
          color: const Color(0xFF269BC4).withValues(alpha: 0.20),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      couleurFiligrane: const Color(0xFFD9EAFB).withValues(alpha: 0.35),
      tailleFiligrane: 86 * k,
      basFiligrane: 52 * k,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8 * k, 11, 7 * k),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── En-tete : icone, declaration, n° piece, nature ───────────
            Row(
              children: [
                Container(
                  width: 40 * k,
                  height: 40 * k,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9FDEF6),
                    borderRadius: BorderRadius.circular(10 * k),
                  ),
                  child: Icon(
                    isMoney ? LucideIcons.coins : LucideIcons.fileText,
                    color: const Color(0xFF0786B9),
                    size: 22 * k,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: EtiquetteValeur(
                          intitule: 'N° pièce : ',
                          valeur: valeurRenseignee(item.numPiece)
                              ? '${item.numPiece}'
                              : '—',
                          couleur: bleuVif,
                          couleurIntitule: gris,
                          taille: 17 * k,
                        ),
                      ),
                      if (valeurRenseignee(item.numDeclaration)) ...[
                        SizedBox(height: 2.5 * k),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: EtiquetteValeur(
                            intitule: 'N° décl : ',
                            valeur: '${item.numDeclaration}',
                            couleur: bleuVif,
                            couleurIntitule: gris,
                            taille: 17 * k,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _badgeNature(item.nature, k),
                    if (isMoney) ...[
                      SizedBox(height: 3 * k),
                      Text(
                        _formatCurrency(item.fond),
                        style: const TextStyle(
                          color: Color(0xFF059669),
                          fontSize: 18 * k,
                          height: serre,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            SizedBox(height: 5 * k),
            const Divider(color: Color(0xFFC9E3F4), height: 1),
            SizedBox(height: 5 * k),

            // ─── Destinataire ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Destinataire',
                    style: TextStyle(
                      color: Color(0xFF506B91),
                      fontSize: 15.5 * k,
                      height: serre,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 1.5 * k),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: item.destinataire ?? '—',
                          style: const TextStyle(
                            color: bleuVif,
                            fontSize: 18.5 * k,
                            height: serre,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (valeurRenseignee(item.destination)) ...[
                          const TextSpan(
                            text: '  |  ',
                            style: TextStyle(
                              color: Color(0xFF9BB8D6),
                              fontSize: 16.5 * k,
                              height: serre,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: item.destination!,
                            style: const TextStyle(
                              color: Color(0xFF0082BF),
                              fontSize: 16.5 * k,
                              height: serre,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ─── Banque et encaissement ───────────────────────────────────
            if (item.banque != null ||
                item.dateEncaissement != null ||
                item.dateRemise != null) ...[
              SizedBox(height: 6 * k),
              // Wrap et non Row : la date d'encaissement doit se lire en
              // entier, quitte a passer a la ligne quand la banque est longue.
              Wrap(
                spacing: 12 * k,
                runSpacing: 4 * k,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (item.banque != null)
                    _mentionJeton(
                      LucideIcons.landmark,
                      const Color(0xFFC2EDFC),
                      const Color(0xFF0086CA),
                      'Banque : ',
                      item.banque!,
                      const Color(0xFF0560D2),
                      const Color(0xFF6D809C),
                      k,
                    ),
                  if (item.dateEncaissement != null)
                    _mentionJeton(
                      LucideIcons.check,
                      const Color(0xFFC1F0E4),
                      const Color(0xFF00A486),
                      'Encaissé : ',
                      item.dateEncaissement!,
                      vert,
                      const Color(0xFF415C7D),
                      k,
                    )
                  else if (item.dateRemise != null)
                    _mentionJeton(
                      LucideIcons.check,
                      const Color(0xFFC1F0E4),
                      const Color(0xFF00A486),
                      'Remis : ',
                      item.dateRemise!,
                      vert,
                      const Color(0xFF415C7D),
                      k,
                    ),
                ],
              ),
            ],

            // ─── Bouton Bordereau ─────────────────────────────────────────
            SizedBox(height: 6 * k),
            if (valeurRenseignee(item.bordereau))
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10 * k),
                  onTap: () {
                    if (item.cfkBrd == null) {
                      Get.snackbar(
                        'Bordereau',
                        'Aucun détail disponible pour ce bordereau.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF0F172A).withValues(
                          alpha: 0.88,
                        ),
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(14),
                      );
                      return;
                    }
                    Get.to(
                      () => BordereauDetailScreen(
                        bordereau: item.bordereau!,
                        idBordereau: item.cfkBrd,
                        dateAffectation: item.dateAffectation,
                        dateRemise: item.dateRemise,
                      ),
                      transition: Transition.cupertino,
                      duration: const Duration(milliseconds: 360),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10 * k,
                      vertical: 6 * k,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9EFFC),
                      borderRadius: BorderRadius.circular(10 * k),
                      border: Border.all(
                        color: const Color(0xFF7FCDEE),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.fileSpreadsheet,
                          color: Color(0xFF007EBE),
                          size: 15 * k,
                        ),
                        SizedBox(width: 6 * k),
                        EtiquetteValeur(
                          intitule: 'Bordereau : ',
                          valeur: item.bordereau!,
                          couleur: bleuVif,
                          couleurIntitule: const Color(0xFF415C7D),
                          taille: 16 * k,
                        ),
                        SizedBox(width: 6 * k),
                        const Icon(
                          LucideIcons.chevronRight,
                          color: bleuVif,
                          size: 16 * k,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * k,
                  vertical: 5.5 * k,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4EEF7),
                  borderRadius: BorderRadius.circular(10 * k),
                  border: Border.all(
                    color: const Color(0xFFC8D9EA),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.info,
                      color: Color(0xFF637D9B),
                      size: 14 * k,
                    ),
                    SizedBox(width: 6 * k),
                    const Text(
                      'Aucun bordereau affecté',
                      style: TextStyle(
                        color: Color(0xFF506B91),
                        fontSize: 15 * k,
                        height: serre,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Badge de nature, contour bleu et fond pale.
  Widget _badgeNature(String nature, double k) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * k, vertical: 5 * k),
      decoration: BoxDecoration(
        color: const Color(0xFFBBE8FA),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFF7FCDEE)),
      ),
      child: Text(
        nature,
        style: TextStyle(
          color: const Color(0xFF0083BF),
          fontSize: 14 * k,
          height: 1.15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Jeton colore suivi de son intitule et de sa valeur.
  Widget _mentionJeton(
    IconData icone,
    Color fondJeton,
    Color teinteJeton,
    String intitule,
    String valeur,
    Color couleur,
    Color couleurIntitule,
    double k,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26 * k,
          height: 26 * k,
          decoration: BoxDecoration(
            color: fondJeton,
            borderRadius: BorderRadius.circular(8 * k),
          ),
          child: Icon(icone, color: teinteJeton, size: 15 * k),
        ),
        SizedBox(width: 7 * k),
        EtiquetteValeur(
          intitule: intitule,
          valeur: valeur,
          couleur: couleur,
          couleurIntitule: couleurIntitule,
          taille: 17 * k,
        ),
      ],
    );
  }
}
