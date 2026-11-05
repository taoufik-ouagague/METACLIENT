import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/expedition_controller.dart';
import '../../models/expedition_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/barre_segments.dart';
import '../../widgets/carte_filtres.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/status_badge.dart';
import 'expedition_detail_screen.dart';
import '../../widgets/scroll_reveal.dart';
import '../../widgets/info_rows_card.dart';

class ExpeditionsScreen extends StatelessWidget {
  const ExpeditionsScreen({super.key});

  String _formatCurrency(num? amount) {
    if (amount == null) return '0.00 DH';
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} DH';
  }

  void _showFilterDialog(BuildContext context, ExpeditionController ctrl) {
    final duCtrl = TextEditingController(text: ctrl.filterDu.value);
    final auCtrl = TextEditingController(text: ctrl.filterAu.value);
    final declCtrl = TextEditingController(text: ctrl.searchQuery.value);
    final clientCtrl = TextEditingController(
      text: ctrl.filterNumeroClient.value,
    );
    final colisCtrl = TextEditingController(text: ctrl.filterColis.value);
    final fondCtrl = TextEditingController(text: ctrl.filterMntFond.value);
    final livre = ctrl.filterLivre.value.obs;

    void relancer() {
      ctrl.fetchAllExpeditions(resetPage: true);
      Get.back<void>();
    }

    Get.dialog(
      CarteFiltres(
        titre: 'Filtrer les expéditions',
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
            exemple: '260006839',
            icone: LucideIcons.hash,
          ),
          const SizedBox(height: 12),
          ChampFiltre(
            controleur: clientCtrl,
            libelle: 'N° CLIENT',
            exemple: '06891D',
            icone: LucideIcons.building2,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ChampFiltre(
                  controleur: colisCtrl,
                  libelle: 'COLIS',
                  exemple: '1',
                  icone: LucideIcons.package,
                  clavier: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChampFiltre(
                  controleur: fondCtrl,
                  libelle: 'MONTANT FOND',
                  exemple: '0',
                  icone: LucideIcons.wallet,
                  clavier: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const LibelleFiltre('LIVRAISON'),
          const SizedBox(height: 7),
          Obx(
            () => RailSegments(
              choix: [
                ChoixSegment(
                  actif: livre.value == 'tous',
                  libelle: 'Toutes',
                  onTap: () => livre.value = 'tous',
                ),
                ChoixSegment(
                  actif: livre.value == 'oui',
                  libelle: 'Livrées',
                  onTap: () => livre.value = 'oui',
                ),
                ChoixSegment(
                  actif: livre.value == 'non',
                  libelle: 'Non livrées',
                  onTap: () => livre.value = 'non',
                ),
              ],
            ),
          ),
        ],
        onReinitialiser: () {
          ctrl.filterDu.value = '';
          ctrl.filterAu.value = '';
          ctrl.searchQuery.value = '';
          ctrl.filterNumeroClient.value = '';
          ctrl.filterColis.value = '';
          ctrl.filterMntFond.value = '';
          ctrl.filterLivre.value = 'tous';
          relancer();
        },
        onAppliquer: () {
          ctrl.filterDu.value = duCtrl.text.trim();
          ctrl.filterAu.value = auCtrl.text.trim();
          ctrl.searchQuery.value = declCtrl.text.trim();
          ctrl.filterNumeroClient.value = clientCtrl.text.trim();
          ctrl.filterColis.value = colisCtrl.text.trim();
          ctrl.filterMntFond.value = fondCtrl.text.trim();
          ctrl.filterLivre.value = livre.value;
          relancer();
        },
      ),
      barrierColor: voileFiltres,
    );
  }

  @override
  Widget build(BuildContext context) {
    final expCtrl = Get.find<ExpeditionController>();

    return Column(
      children: [
        // ─── TOP TABS (EN COURS vs TOUTES) ─────────────────────────────────
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
                  'En cours (${expCtrl.expeditionsEncours.length})',
                  'Toutes (${expCtrl.totalElements.value})',
                ],
                index: expCtrl.activeTab.value,
                onChange: (i) => expCtrl.activeTab.value = i,
                tailleTexte: 13,
              ),
            ),
          ),
        ),

        // ─── SEARCH & FILTER BAR ───────────────────────────────────────────
        // Sous Obx : le dialogue de filtres ecrit dans `searchQuery`, le champ
        // et la croix d'effacement doivent suivre.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: Obx(
            () => Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.search,
                          color: AppTheme.primaryIcons,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller:
                                TextEditingController(
                                    text: expCtrl.searchQuery.value,
                                  )
                                  ..selection = TextSelection.collapsed(
                                    offset: expCtrl.searchQuery.value.length,
                                  ),
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 13,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'N° déclaration...',
                              hintStyle: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12.5,
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (v) {
                              expCtrl.searchQuery.value = v.trim();
                              expCtrl.fetchAllExpeditions(resetPage: true);
                            },
                          ),
                        ),
                        if (expCtrl.searchQuery.value.isNotEmpty)
                          IconButton(
                            icon: const Icon(
                              LucideIcons.x,
                              color: Color(0xFF94A3B8),
                              size: 16,
                            ),
                            onPressed: () {
                              expCtrl.searchQuery.value = '';
                              expCtrl.fetchAllExpeditions(resetPage: true);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Bouton plein, comme la pastille de l'onglet : en creux et
                // teinte, il se confondait avec le champ de recherche.
                GestureDetector(
                  onTap: () => _showFilterDialog(context, expCtrl),
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
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          LucideIcons.filter,
                          color: Colors.white,
                          size: 19,
                        ),
                        if (expCtrl.filtresActifs)
                          Positioned(
                            top: 9,
                            right: 9,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primary,
                                  width: 1.4,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // ─── LIST CONTENT ──────────────────────────────────────────────────
        Expanded(
          child: Obx(() {
            if (expCtrl.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }

            final list = expCtrl.activeTab.value == 0
                ? expCtrl.expeditionsEncours
                : expCtrl.allExpeditions;

            if (list.isEmpty) {
              return const Center(
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
                      'Aucune expédition trouvée',
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
                if (expCtrl.activeTab.value == 0) {
                  await expCtrl.fetchExpeditionsEncours();
                } else {
                  await expCtrl.fetchAllExpeditions();
                }
              },
              child: ListView.separated(
                // Nouvelle cle a chaque onglet : la revelation rejoue.
                key: ValueKey<int>(expCtrl.activeTab.value),
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
                    child: _buildExpeditionCard(item),
                  );
                },
              ),
            );
          }),
        ),

        // ─── PAGINATION BAR FOR ALL EXPEDITIONS ────────────────────────────
        Obx(() {
          if (expCtrl.activeTab.value == 1 && expCtrl.totalPages.value > 1) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: GlassContainer(
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
                      onPressed: expCtrl.currentPage.value > 1
                          ? expCtrl.previousPage
                          : null,
                    ),
                    Text(
                      'Page ${expCtrl.currentPage.value} / ${expCtrl.totalPages.value}',
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
                          expCtrl.currentPage.value < expCtrl.totalPages.value
                          ? expCtrl.nextPage
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

  Widget _buildExpeditionCard(ExpeditionModel item) {
    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(15),
      onTap: () {
        if (item.idExpedition != null) {
          Get.to(
            () => ExpeditionDetailScreen(idExpedition: item.idExpedition!),
            transition: Transition.cupertino,
            duration: const Duration(milliseconds: 360),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.package,
                  color: AppTheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        item.numDeclaration,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                status: item.statut ?? (item.isLivree ? 'Livré' : 'En cours'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Route: Origine -> Destination
          Row(
            children: [
              const Icon(
                LucideIcons.mapPin,
                size: 13,
                color: AppTheme.primaryIcons,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${item.origine ?? "—"} → ${item.destination ?? "—"}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatCurrency(item.mntTtc),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Destinataire & Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Dest: ${item.destinataire ?? "—"}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '${item.colis ?? 1} colis • ${item.poids ?? 0} kg',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),

          if (valeurRenseignee(item.processus) ||
              valeurRenseignee(item.dateLivraison) ||
              valeurRenseignee(item.dateLivPh) ||
              (item.fond ?? 0) > 0 ||
              (item.valeurDeclaree ?? 0) > 0) ...[
            const SizedBox(height: 6),
            Text(
              [
                if ((item.fond ?? 0) > 0)
                  '${item.nature ?? "Fond"} : ${_formatCurrency(item.fond)}',
                if (valeurRenseignee(item.processus)) item.processus,
                if (valeurRenseignee(item.dateLivraison))
                  'Livré le ${item.dateLivraison}',
                if (valeurRenseignee(item.dateLivPh))
                  'Prévu le ${item.dateLivPh}',
                if ((item.notificationLivraison ?? '0') != '0') 'Notifié',
                if ((item.valeurDeclaree ?? 0) > 0)
                  'Val. déclarée ${_formatCurrency(item.valeurDeclaree)}',
              ].join(' • '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
