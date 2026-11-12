import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/facture_controller.dart';
import '../../models/facture_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/barre_segments.dart';
import '../../widgets/carte_accent.dart';
import 'facture_detail_screen.dart';
import '../../widgets/scroll_infini.dart';
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

            // Seul l'onglet « Toutes » est pagine ; « En instances » tient
            // en un appel et n'a rien de plus a tirer.
            final pagine = factureCtrl.activeTab.value == 1;
            final pied = pagine && factureCtrl.isLoadingMore.value;

            return ScrollInfini(
              onFin: pagine ? factureCtrl.chargerPlus : () {},
              child: RefreshIndicator(
                color: AppTheme.primary,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  if (factureCtrl.activeTab.value == 0) {
                    await factureCtrl.fetchFacturesInstances();
                  } else {
                    await factureCtrl.fetchAllFactures(resetPage: true);
                  }
                },
                child: ListView.separated(
                  // Nouvelle cle a chaque onglet : la revelation rejoue.
                  key: ValueKey<int>(factureCtrl.activeTab.value),
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
                      child: _buildFactureCard(item),
                    );
                  },
                ),
              ),
            );
          }),
        ),

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
    final c = item.couleur?.trim().toLowerCase();
    final bool isGreen = c == 'green' || (c == null && !hasSolde);
    final bool isOrange = c == 'orange';

    // Teinte, icônes et pastille selon la couleur API du backend :
    // - green : facture clôturée / payée
    // - orange : délai de règlement >= 0 (en cours / dans les délais)
    // - red : délai de règlement < 0 (en retard / échue)
    final Color teinte;
    final IconData icone;
    final Color fondIcone;
    final Color fondPastille;
    final Color bordPastille;
    final Color texteStatut;
    final Color jauge;
    final String libelleStatut;
    final IconData iconeStatut;

    if (isGreen) {
      teinte = AppTheme.statusSuccess;
      icone = LucideIcons.fileCheck2;
      fondIcone = teinte.withValues(alpha: 0.13);
      fondPastille = teinte.withValues(alpha: 0.14);
      bordPastille = teinte.withValues(alpha: 0.30);
      texteStatut = teinte;
      jauge = teinte;
      libelleStatut = 'PAYÉE';
      iconeStatut = LucideIcons.checkCircle2;
    } else if (isOrange) {
      const orange = Color(0xFFF59E0B);
      teinte = const Color(0xFFD97706);
      icone = LucideIcons.fileClock;
      fondIcone = orange.withValues(alpha: 0.14);
      fondPastille = const Color(0xFFFEF3C7);
      bordPastille = const Color(0xFFFDE68A);
      texteStatut = const Color(0xFFB45309);
      jauge = orange;
      libelleStatut = 'EN COURS';
      iconeStatut = LucideIcons.clock;
    } else {
      const rouge = Color(0xFFF02F3A);
      teinte = rouge;
      icone = LucideIcons.fileClock;
      fondIcone = const Color(0xFFFEDBE6);
      fondPastille = const Color(0xFFFFDCE3);
      bordPastille = const Color(0xFFFFB9C7);
      texteStatut = const Color(0xFFEF3340);
      jauge = const Color(0xFFF52F43);
      libelleStatut = 'EN RETARD';
      iconeStatut = LucideIcons.alertCircle;
    }

    final ttc = (item.mntTtc ?? 0).toDouble();
    final reste = (item.solde ?? (item.isPayee ? 0 : ttc)).toDouble();
    // Part reglee, de 0 a 1. Sans montant TTC on ne peut rien en dire.
    final regle = ttc > 0 ? ((ttc - reste) / ttc).clamp(0.0, 1.0) : 0.0;
    final pourcent = (regle * 100).round();

    const gris = Color(0xFF647A9F);

    final echeance = Get.find<FactureController>().echeanceDe(item);

    // Mesures relevees sur la maquette (1590 px de large pour ~366 pt ici,
    // soit x0,23). Poppins porte une interligne d'environ 1,5 : on la ramene
    // a 1,15, sinon chaque ligne ajoute un tiers de hauteur a la carte.
    const serre = 1.1;

    // Les tailles fournies donnent une carte de ~167 pt ; celle des
    // expeditions fait w x 334/953, soit ~128 pt. Un facteur unique les y
    // ramene en gardant les proportions entre les elements.
    const k = 0.62;

    return CarteAccent(
      teinte: teinte,
      icone: icone,
      fondTeinte: false,
      fond: const Color(0xFFF5F9FF),
      // Meme rayon que les cartes d'expedition.
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
      basFiligrane: 36 * k,
      onTap: () {
        final ctrl = Get.find<FactureController>();
        final comp =
            ctrl.trouverFactureComplete(item.idFacture, item.numFacture);
        Get.to(
          () => FactureDetailScreen(
            facture: comp != null ? item.mergeWith(comp) : item,
          ),
          transition: Transition.cupertino,
          duration: const Duration(milliseconds: 360),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8 * k, 11, 7 * k),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── En-tete : icone, numero, date, statut ─────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40 * k,
                  height: 40 * k,
                  decoration: BoxDecoration(
                    color: fondIcone,
                    borderRadius: BorderRadius.circular(10 * k),
                  ),
                  child: Icon(icone, color: teinte, size: 22 * k),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'N° ${item.numFacture}',
                      maxLines: 1,
                      style: const TextStyle(
                        color: Color(0xFF0284C7),
                        fontSize: 21 * k,
                        height: serre,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _pastilleStatut(
                  libelleStatut,
                  iconeStatut,
                  texteStatut,
                  fondPastille,
                  bordPastille,
                  k,
                ),
              ],
            ),
            const SizedBox(height: 5 * k),
            const Divider(color: Color(0xFFE5EDF9), height: 1),
            const SizedBox(height: 5 * k),

            // ─── Montants & Progression ───────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: _montant(
                    'Montant TTC',
                    _formatCurrency(item.mntTtc),
                    const Color(0xFF172E50),
                    k,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: _montant(
                    'Reste à payer',
                    _formatCurrency(reste),
                    teinte,
                    k,
                  ),
                ),
                const SizedBox(width: 10),
                _jaugeCirculaire(
                  regle: regle,
                  pourcent: pourcent,
                  jauge: jauge,
                  texteStatut: texteStatut,
                  k: k,
                ),
              ],
            ),
            const SizedBox(height: 6 * k),

            // ─── Date facture & Échéance (Date facture first) ─────────────
            Row(
              children: [
                const Icon(
                  LucideIcons.calendar,
                  size: 16 * k,
                  color: Color(0xFF0284C7),
                ),
                const SizedBox(width: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Date facture : ',
                        style: TextStyle(
                          color: gris,
                          fontSize: 16 * k,
                          height: serre,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: item.dateFacture ?? '—',
                        style: const TextStyle(
                          color: Color(0xFF1263BF),
                          fontSize: 16 * k,
                          height: serre,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  LucideIcons.calendarClock,
                  size: 16 * k,
                  color: isGreen
                      ? AppTheme.statusSuccess
                      : (isOrange
                          ? const Color(0xFFEA580C)
                          : const Color(0xFFEF3340)),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: echeance != null
                      ? Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Échéance : ',
                                style: TextStyle(
                                  color: gris,
                                  fontSize: 16 * k,
                                  height: serre,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: echeance,
                                style: TextStyle(
                                  color: isGreen
                                      ? AppTheme.statusSuccess
                                      : (isOrange
                                          ? const Color(0xFFEA580C)
                                          : const Color(0xFFEF3340)),
                                  fontSize: 16 * k,
                                  height: serre,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : const Text(
                          'Voir le détail',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: gris,
                            fontSize: 16 * k,
                            height: serre,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  size: 16 * k,
                  color: Color(0xFF6D819E),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Pastille de statut : icone + libelle, sur la teinte de la carte.
  Widget _pastilleStatut(
    String libelle,
    IconData icone,
    Color teinte,
    Color fond,
    Color bord,
    double k,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * k, vertical: 5 * k),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: bord),
        boxShadow: [
          BoxShadow(
            color: teinte.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 15 * k, color: teinte),
          SizedBox(width: 5 * k),
          Text(
            libelle,
            style: TextStyle(
              color: teinte,
              fontSize: 14 * k,
              height: 1.15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  /// Intitule gris au-dessus d'un montant en gras.
  Widget _montant(String intitule, String valeur, Color couleur, double k) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          intitule,
          style: TextStyle(
            color: const Color(0xFF647A9F),
            fontSize: 15 * k,
            height: 1.15,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2 * k),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            valeur,
            maxLines: 1,
            style: TextStyle(
              color: couleur,
              fontSize: 19 * k,
              height: 1.15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
    );
  }

  /// Jauge circulaire compacte pour le pourcentage de règlement dans le coin.
  Widget _jaugeCirculaire({
    required double regle,
    required int pourcent,
    required Color jauge,
    required Color texteStatut,
    required double k,
  }) {
    final double taille = 38 * k;
    final double epaisseur = 3.6 * k;

    return SizedBox(
      width: taille,
      height: taille,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: regle > 0 ? regle : 0.0,
            strokeWidth: epaisseur,
            backgroundColor: const Color(0xFFDCE7F7),
            valueColor: AlwaysStoppedAnimation<Color>(jauge),
            strokeCap: StrokeCap.round,
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Text(
                '$pourcent%',
                style: TextStyle(
                  color: texteStatut,
                  fontSize: 13 * k,
                  height: 1.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
