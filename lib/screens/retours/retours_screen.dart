import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
      final selected = retourCtrl.selectedRetour.value;

      return PopScope(
        canPop: selected == null,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && retourCtrl.selectedRetour.value != null) {
            retourCtrl.selectedRetour.value = null;
          }
        },
        child: Column(
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
                    'Retours BL / Factures (${retourCtrl.totalElementsBL.value})',
                  ],
                  index: retourCtrl.activeTab.value,
                  onChange: (i) {
                    retourCtrl.selectedRetour.value = null;
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
                        retourCtrl.selectedRetour.value = null;
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
                    onTap: () {
                      retourCtrl.selectedRetour.value = null;
                      _showFilterDialog(context, retourCtrl);
                    },
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

            // ─── APERÇU DÉTAILLÉ (À LA PLACE DE LA LISTE) OU LISTE COMPLETE ───
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final isDetail = child.key == const ValueKey('detail_view');
                  final offsetTween = Tween<Offset>(
                    begin: isDetail ? const Offset(0, 0.06) : const Offset(0, -0.03),
                    end: Offset.zero,
                  );
                  final scaleTween = Tween<double>(
                    begin: isDetail ? 0.96 : 0.98,
                    end: 1.0,
                  );

                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
                    ),
                    child: SlideTransition(
                      position: offsetTween.animate(animation),
                      child: ScaleTransition(
                        scale: scaleTween.animate(animation),
                        child: child,
                      ),
                    ),
                  );
                },
                child: selected != null
                    ? KeyedSubtree(
                        key: const ValueKey('detail_view'),
                        child: _buildRetourDetailView(
                          context,
                          selected,
                          onClose: () => retourCtrl.selectedRetour.value = null,
                        ),
                      )
                    : KeyedSubtree(
                        key: const ValueKey('list_view'),
                        child: Builder(builder: (_) {
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
                                  if (index >= list.length) return const PiedChargement();
                                  final item = list[index];
                                  return ScrollReveal(
                                    index: index,
                                    child: _buildRetourCard(context, item),
                                  );
                                },
                              ),
                            ),
                          );
                        }),
                      ),
              ),
            ),
      ],
    ),
  );
});
}

  Widget _buildRetourDetailView(
    BuildContext context,
    RetourFondModel item, {
    required VoidCallback onClose,
  }) {
    final lignes = [
      MapEntry('Nature', item.nature),
      MapEntry('Type d\'expédition', item.typeExpedition),
      MapEntry('N° pièce', item.numPiece),
      MapEntry('Destinataire', item.destinataire),
      MapEntry('Destination', item.destination),
      MapEntry('Port', item.port),
      MapEntry('Mode de règlement', item.modereglement),
      MapEntry('Banque', item.banque),
      MapEntry('Date d\'envoi', item.dateEnvoi),
      MapEntry('Date d\'encaissement', item.dateEncaissement),
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
      MapEntry('Bordereau', item.bordereau),
      MapEntry('Réf. bordereau', item.cfkBrd?.toString()),
      MapEntry('Date de réception', item.dateReception),
      MapEntry('Date d\'affectation', item.dateAffectation),
      MapEntry('Date de remise', item.dateRemise),
    ].where((e) => valeurRenseignee(e.value)).toList();

    final isMoney = item.fond != null && item.fond! > 0;
    const bleu = Color(0xFF007EBE);
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 6, 16, 12 + bottomPad),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFF8FE),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF269BC4).withValues(alpha: 0.20),
              blurRadius: 22,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // ─── Filigrane comme dans les cartes CT/BL ───────────────────
              Positioned(
                right: -25,
                bottom: 25,
                child: Icon(
                  isMoney ? LucideIcons.coins : LucideIcons.fileText,
                  size: 160,
                  color: const Color(0xFFD9EAFB).withValues(alpha: 0.35),
                ),
              ),

              // ─── Arête haute éclairée (reflet de verre) ────────────────────
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.95),
                        Colors.white.withValues(alpha: 0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // ─── Filet vertical cyan à gauche ─────────────────────────────
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4.5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF007EBE),
                        Color(0xFF29B7D9),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Contenu (En-tête + Lignes) ────────────────────────────────
              Column(
                children: [
                  // ─── En-tête : Icône cyan, Titre + trait cyan, Bouton retour chevron ───
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 16, 14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF9FDEF6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              isMoney ? LucideIcons.coins : LucideIcons.fileText,
                              color: const Color(0xFF0786B9),
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Retour N° ${item.numDeclaration ?? ''}',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF000A3C),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: 32,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: bleu,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onClose,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFD6E7F4),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                LucideIcons.chevronLeft,
                                color: Color(0xFF000A3C),
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, thickness: 1, color: Color(0xFFD9EAF8)),

              // ─── Lignes du tableau avec icônes cyan ───────────────────────
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  physics: const BouncingScrollPhysics(),
                  itemCount: lignes.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF1F5F9),
                  ),
                  itemBuilder: (_, index) {
                    final ligne = lignes[index];
                    final icone = _resolveRetourIcon(ligne.key);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9.5),
                      child: Row(
                        children: [
                          Icon(
                            icone,
                            size: 18,
                            color: const Color(0xFF0284C7),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ligne.key,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF637D9B),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              ligne.value!,
                              textAlign: TextAlign.end,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF000A3C),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
}

  IconData _resolveRetourIcon(String key) {
    final k = key.toLowerCase();
    if (k.contains('nature')) return LucideIcons.sprout;
    if (k.contains('type')) return LucideIcons.layers;
    if (k.contains('déclaration') || k.contains('declaration')) return LucideIcons.hash;
    if (k.contains('pièce') || k.contains('piece')) return LucideIcons.puzzle;
    if (k.contains('destinataire')) return LucideIcons.landmark;
    if (k.contains('destination')) return LucideIcons.user;
    if (k.contains('port')) return LucideIcons.truck;
    if (k.contains('règlement') || k.contains('reglement')) return LucideIcons.creditCard;
    if (k.contains('banque')) return LucideIcons.landmark;
    if (k.contains('envoi')) return LucideIcons.calendar;
    if (k.contains('encaissement')) return LucideIcons.calendarCheck;
    if (k.contains('réception') || k.contains('reception')) return LucideIcons.calendarClock;
    if (k.contains('affectation')) return LucideIcons.calendarPlus;
    if (k.contains('remise')) return LucideIcons.calendarCheck2;
    if (k.contains('ht') || k.contains('ttc')) return LucideIcons.coins;
    if (k.contains('fond')) return LucideIcons.wallet;
    if (k.contains('expédition') || k.contains('expedition')) return LucideIcons.hash;
    if (k.contains('bordereau')) return LucideIcons.fileSpreadsheet;
    return LucideIcons.fileText;
  }

  Widget _buildRetourCard(BuildContext context, RetourFondModel item) {
    final isMoney = item.fond != null && item.fond! > 0;

    // Couleurs relevees au pixel sur la maquette.
    const bleu = Color(0xFF007EBE);
    const bleuVif = Color(0xFF1263BF);
    const encre = Color(0xFF000A3C);
    const gris = Color(0xFF637D9B);
    const vert = Color(0xFF00927A);

    // Les tailles de la maquette (1774 px pour ~366 pt) ramenees a la hauteur
    // des cartes d'expedition, w x 334/953.
    const k = 0.77;
    const serre = 1.15;

    return CarteAccent(
      teinte: bleu,
      icone: isMoney ? LucideIcons.coins : LucideIcons.fileText,
      fondTeinte: false,
      fond: const Color(0xFFEFF8FE),
      rayon: 24,
      ombres: [
        BoxShadow(
          color: const Color(0xFF269BC4).withValues(alpha: 0.20),
          blurRadius: 22,
          offset: const Offset(0, 9),
        ),
      ],
      couleurFiligrane: const Color(0xFFD9EAFB).withValues(alpha: 0.35),
      tailleFiligrane: 92 * k,
      basFiligrane: 56 * k,
      onTap: () => Get.find<RetourFondController>().selectedRetour.value = item,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 11 * k, 12, 9 * k),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── En-tete : icone, declaration, n° piece, nature ───────────
            Row(
              children: [
                Container(
                  width: 42 * k,
                  height: 42 * k,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9FDEF6),
                    borderRadius: BorderRadius.circular(10 * k),
                  ),
                  child: Icon(
                    isMoney ? LucideIcons.coins : LucideIcons.fileText,
                    color: const Color(0xFF0786B9),
                    size: 24 * k,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Décl: ${item.numDeclaration ?? "—"}',
                          maxLines: 1,
                          style: const TextStyle(
                            color: encre,
                            fontSize: 21 * k,
                            height: serre,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (valeurRenseignee(item.numPiece)) ...[
                        SizedBox(height: 2 * k),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: EtiquetteValeur(
                            intitule: 'N° pièce : ',
                            valeur: '${item.numPiece}',
                            couleur: bleuVif,
                            couleurIntitule: gris,
                            taille: 16 * k,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _badgeNature(item.nature, k),
              ],
            ),
            SizedBox(height: 7 * k),
            const Divider(color: Color(0xFFC9E3F4), height: 1),
            SizedBox(height: 7 * k),

            // ─── Destinataire et montant ──────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Destinataire',
                        style: TextStyle(
                          color: const Color(0xFF506B91),
                          fontSize: 16 * k,
                          height: serre,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 1 * k),
                      // Le nom et la ville, separes d'un filet : sur une
                      // seule ligne de texte, la ville se perdait.
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.destinataire ?? '—',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: encre,
                                fontSize: 19 * k,
                                height: serre,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 16 * k,
                            margin: EdgeInsets.symmetric(horizontal: 8 * k),
                            color: const Color(0xFF9BB8D6),
                          ),
                          Flexible(
                            child: Text(
                              item.destination ?? '—',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF0082BF),
                                fontSize: 17 * k,
                                height: serre,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isMoney) ...[
                  SizedBox(width: 10 * k),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Montant Fond',
                        style: TextStyle(
                          color: const Color(0xFF637B99),
                          fontSize: 16 * k,
                          height: serre,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 1 * k),
                      Text(
                        _formatCurrency(item.fond),
                        style: TextStyle(
                          color: bleu,
                          fontSize: 20 * k,
                          height: serre,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            // ─── Banque et encaissement ───────────────────────────────────
            if (item.banque != null ||
                item.dateEncaissement != null ||
                item.dateRemise != null) ...[
              SizedBox(height: 8 * k),
              // Wrap et non Row : la date d'encaissement doit se lire en
              // entier, quitte a passer a la ligne quand la banque est longue.
              Wrap(
                spacing: 12 * k,
                runSpacing: 5 * k,
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
