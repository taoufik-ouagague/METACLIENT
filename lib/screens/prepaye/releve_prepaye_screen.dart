import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/prepaye_controller.dart';
import '../../models/releve_prepaye_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/barre_segments.dart';
import '../../widgets/carte_filtres.dart';
import '../../widgets/carte_liste.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/scroll_reveal.dart';

class RelevePrepayeScreen extends StatelessWidget {
  const RelevePrepayeScreen({super.key});

  static const Color _vert = Color(0xFF059669);
  static const Color _rouge = Color(0xFFE11D48);

  String _montant(num? valeur) {
    final f = NumberFormat('#,##0.00', 'fr_FR');
    return '${f.format(valeur ?? 0)} DH';
  }

  void _ouvrirFiltres(BuildContext context, PrepayeController ctrl) {
    final duCtrl = TextEditingController(text: ctrl.filterDu.value);
    final auCtrl = TextEditingController(text: ctrl.filterAu.value);

    Get.dialog(
      CarteFiltres(
        titre: 'Filtrer le relevé',
        contenu: [
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
        ],
        onReinitialiser: () {
          ctrl.filterDu.value = '';
          ctrl.filterAu.value = '';
          Get.back<void>();
        },
        onAppliquer: () {
          ctrl.filterDu.value = duCtrl.text.trim();
          ctrl.filterAu.value = auCtrl.text.trim();
          Get.back<void>();
        },
      ),
      barrierColor: voileFiltres,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PrepayeController>();

    return Column(
      children: [
        // ─── SOLDE ET TOTAUX ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
          child: Obx(
            () => ScrollReveal.grille(index: 0, child: _carteSolde(ctrl)),
          ),
        ),

        // ─── BASCULE ALIMENTATIONS / CONSOMMATIONS ─────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
          child: Obx(
            () => Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: BarreSegments(
                libelles: const ['Tout', 'Alimentations', 'Consommations'],
                index: switch (ctrl.filterSens.value) {
                  'C' => 1,
                  'D' => 2,
                  _ => 0,
                },
                onChange: (i) => ctrl.filterSens.value = switch (i) {
                  1 => 'C',
                  2 => 'D',
                  _ => '',
                },
                tailleTexte: 12,
              ),
            ),
          ),
        ),

        // ─── FILTRE DE PÉRIODE ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
          child: Obx(
            () => GestureDetector(
              onTap: () => _ouvrirFiltres(context, ctrl),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      LucideIcons.filter,
                      color: Colors.white,
                      size: 17,
                    ),
                    const SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        // Seules les dates concernent ce bouton : le sens a
                        // deja sa bascule, et l'inclure affichait « — → — »
                        // des qu'on changeait d'onglet.
                        ctrl.periodeActive
                            ? ctrl.libellePeriode
                            : 'Filtrer par période',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ─── LISTE DES OPÉRATIONS ──────────────────────────────────────────
        Expanded(
          child: Obx(() {
            if (ctrl.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }

            final liste = ctrl.lignesAffichees;
            if (liste.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.wallet,
                      color: Color(0xFFCBD5E1),
                      size: 48,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Aucune opération sur la période',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: Colors.white,
              onRefresh: () => ctrl.fetchReleve(),
              child: ListView.separated(
                // Nouvelle cle a chaque bascule : la revelation rejoue.
                key: ValueKey<String>(
                  '${ctrl.filterSens.value}|${ctrl.filterDu.value}|${ctrl.filterAu.value}',
                ),
                // Voir agences_screen : la barre flottante masque le bas.
                padding: EdgeInsets.fromLTRB(
                  18,
                  8,
                  18,
                  8 + MediaQuery.paddingOf(context).bottom,
                ),
                itemCount: liste.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) =>
                    ScrollReveal(index: i, child: _carteOperation(liste[i])),
              ),
            );
          }),
        ),

        // ─── PAGINATION ────────────────────────────────────────────────────
        Obx(() {
          if (ctrl.totalPages.value <= 1) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: GlassContainer(
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      LucideIcons.chevronLeft,
                      color: AppTheme.primary,
                    ),
                    onPressed: ctrl.currentPage.value > 1
                        ? ctrl.pagePrecedente
                        : null,
                  ),
                  Text(
                    'Page ${ctrl.currentPage.value} / ${ctrl.totalPages.value}',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.chevronRight,
                      color: AppTheme.primary,
                    ),
                    onPressed: ctrl.currentPage.value < ctrl.totalPages.value
                        ? ctrl.pageSuivante
                        : null,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Bandeau de tete : le solde et les deux totaux qui le composent.
  Widget _carteSolde(PrepayeController ctrl) {
    return CarteListe(
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  LucideIcons.wallet,
                  color: Colors.white,
                  size: 17,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'Solde du compte prépayé',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _montant(ctrl.solde),
              maxLines: 1,
              style: TextStyle(
                color: ctrl.solde >= 0 ? _vert : _rouge,
                fontSize: 25,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _total(
                  'Alimentations',
                  ctrl.totalCredits,
                  _vert,
                  LucideIcons.arrowDownLeft,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _total(
                  'Consommations',
                  ctrl.totalDebits,
                  _rouge,
                  LucideIcons.arrowUpRight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Calculé sur les opérations chargées',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5),
          ),
        ],
      ),
    );
  }

  Widget _total(String libelle, num valeur, Color couleur, IconData icone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: couleur.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 13, color: couleur),
              const SizedBox(width: 5),
              Text(
                libelle,
                style: TextStyle(
                  color: couleur,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _montant(valeur),
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _carteOperation(RelevePrepayeModel ligne) {
    final credit = ligne.estCredit;
    final couleur = credit ? _vert : _rouge;

    return CarteListe(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: couleur.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              credit ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
              color: couleur,
              size: 17,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ligne.operation ?? (credit ? 'Alimentation' : 'Consommation'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.calendar,
                      size: 12,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ligne.dateOperation ?? '—',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11.5,
                      ),
                    ),
                    if ((ligne.classe ?? '').isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _puce(ligne.classe!, const Color(0xFF6366F1)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${credit ? '+' : '−'} ${_montant(ligne.montant)}',
                style: TextStyle(
                  color: couleur,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if ((ligne.etat ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                _puce(ligne.etat!, const Color(0xFF64748B)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _puce(String texte, Color couleur) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        texte,
        style: TextStyle(
          color: couleur,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
