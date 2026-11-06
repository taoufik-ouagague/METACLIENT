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
import '../../widgets/status_badge.dart';
import '../../widgets/scroll_reveal.dart';
import '../../widgets/info_rows_card.dart';

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
        titre: 'Filtrer les retours',
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
              const SizedBox(width: 10),
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
          const SizedBox(height: 12),
          ChampFiltre(
            controleur: declCtrl,
            libelle: 'N° DÉCLARATION',
            exemple: '260029143',
            icone: LucideIcons.hash,
          ),
          const SizedBox(height: 12),
          ChampFiltre(
            controleur: clientCtrl,
            libelle: 'CLIENT',
            exemple: 'LUMINEA SANTE',
            icone: LucideIcons.building2,
          ),
          const SizedBox(height: 12),
          ChampFiltre(
            controleur: pieceCtrl,
            libelle: 'N° PIÈCE',
            exemple: '2102282',
            icone: LucideIcons.fileText,
          ),
          const SizedBox(height: 16),
          const LibelleFiltre('REMISE'),
          const SizedBox(height: 7),
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

    return Column(
      children: [
        // ─── TOP TABS (CC/CT vs BL/FACTURES) ──────────────────────────────
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
                  'Chèques / Traites (${retourCtrl.retoursCCCT.length})',
                  'Retours BL / Factures (${retourCtrl.retoursBL.length})',
                ],
                index: retourCtrl.activeTab.value,
                onChange: (i) => retourCtrl.activeTab.value = i,
              ),
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
              // Bouton plein, comme la pastille de l'onglet : en creux et
              // teinte, il se confondait avec le champ de recherche.
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

        // ─── LIST CONTENT ──────────────────────────────────────────────────
        Expanded(
          child: Obx(() {
            if (retourCtrl.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }

            final list = retourCtrl.activeTab.value == 0
                ? retourCtrl.retoursCCCTAffiches
                : retourCtrl.retoursBLAffiches;

            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.fileSearch,
                      color: const Color(0xFFCBD5E1),
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Aucun retour enregistré',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: Colors.white,
              onRefresh: () async {
                if (retourCtrl.activeTab.value == 0) {
                  await retourCtrl.fetchRetoursCCCT();
                } else {
                  await retourCtrl.fetchRetoursBL();
                }
              },
              child: ListView.separated(
                // Nouvelle cle a chaque onglet : la revelation rejoue.
                key: ValueKey<int>(retourCtrl.activeTab.value),
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
                    child: _buildRetourCard(context, item),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  void _ouvrirFiche(BuildContext context, RetourFondModel item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controleur) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controleur,
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              InfoRowsCard(
                titre: 'Retour N° ${item.numDeclaration}',
                icone: LucideIcons.fileText,
                lignes: [
                  MapEntry('Nature', item.nature),
                  MapEntry('Type d\'expédition', item.typeExpedition),
                  MapEntry('N° déclaration', item.numDeclaration),
                  MapEntry('N° pièce', item.numPiece),
                  MapEntry('Bordereau', item.bordereau),
                  MapEntry('Réf. bordereau', item.cfkBrd?.toString()),
                  MapEntry('Destinataire', item.destinataire),
                  MapEntry('Destination', item.destination),
                  MapEntry('Port', item.port),
                  MapEntry('Mode de règlement', item.modereglement),
                  MapEntry('Banque', item.banque),
                  MapEntry('Date d\'envoi', item.dateEnvoi),
                  MapEntry('Date de réception', item.dateReception),
                  MapEntry('Date d\'affectation', item.dateAffectation),
                  MapEntry('Date d\'encaissement', item.dateEncaissement),
                  MapEntry('Date de remise', item.dateRemise),
                  MapEntry(
                    'Montant HT',
                    item.mntHt == null ? null : _formatCurrency(item.mntHt),
                  ),
                  MapEntry(
                    'Montant TTC',
                    item.mntTtc == null ? null : _formatCurrency(item.mntTtc),
                  ),
                  MapEntry(
                    'Fond',
                    item.fond == null ? null : _formatCurrency(item.fond),
                  ),
                  MapEntry('N° expédition', item.idExpedition?.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRetourCard(BuildContext context, RetourFondModel item) {
    final isMoney = item.fond != null && item.fond! > 0;

    // Une seule teinte : les deux natures sont deja distinguees par l'icone
    // (jetons ou document) et par le libelle.
    return CarteAccent(
      teinte: AppTheme.primary,
      icone: isMoney ? LucideIcons.coins : LucideIcons.fileText,
      onTap: () => _ouvrirFiche(context, item),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isMoney ? LucideIcons.coins : LucideIcons.fileText,
                    color: AppTheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Décl: ${item.numDeclaration ?? "—"}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (valeurRenseignee(item.numPiece)) ...[
                        const SizedBox(height: 2),
                        EtiquetteValeur(
                          intitule: 'N° pièce : ',
                          valeur: '${item.numPiece}',
                          couleur: const Color(0xFF7C3AED),
                          taille: 12,
                        ),
                      ],
                      if (item.bordereau != null) ...[
                        const SizedBox(height: 2),
                        EtiquetteValeur(
                          intitule: 'Bordereau : ',
                          valeur: '${item.bordereau}',
                          couleur: const Color(0xFF4F46E5),
                          taille: 11.5,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: item.nature),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFE2E8F0), height: 1),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Destinataire',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: item.destinataire ?? '—',
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: '  ${item.destination ?? "—"}',
                              style: const TextStyle(
                                color: Color(0xFF0284C7),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isMoney) ...[
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Montant Fond',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatCurrency(item.fond),
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            if (item.dateRemise != null ||
                item.dateEncaissement != null ||
                item.banque != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 14,
                runSpacing: 4,
                children: [
                  if (item.banque != null)
                    EtiquetteValeur(
                      intitule: 'Banque : ',
                      valeur: item.banque!,
                      couleur: const Color(0xFF4F46E5),
                      taille: 11.5,
                    ),
                  if (item.dateEncaissement != null)
                    EtiquetteValeur(
                      intitule: 'Encaissé : ',
                      valeur: item.dateEncaissement!,
                      couleur: const Color(0xFF059669),
                      taille: 11.5,
                    ),
                  if (item.dateRemise != null)
                    EtiquetteValeur(
                      intitule: 'Remis : ',
                      valeur: item.dateRemise!,
                      couleur: const Color(0xFFD97706),
                      taille: 11.5,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
