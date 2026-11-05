import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/crbt_controller.dart';
import '../../models/crbt_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/info_rows_card.dart';
import '../../widgets/carte_liste.dart';
import '../../widgets/scroll_reveal.dart';

class VirementDetailScreen extends StatefulWidget {
  final VirementCrbtModel virement;

  const VirementDetailScreen({super.key, required this.virement});

  @override
  State<VirementDetailScreen> createState() => _VirementDetailScreenState();
}

class _VirementDetailScreenState extends State<VirementDetailScreen> {
  final CrbtController _controller = Get.find<CrbtController>();

  @override
  void initState() {
    super.initState();
    _controller.fetchVirementDetail(widget.virement.idVirement);
  }

  String _formatCurrency(num? amount) {
    if (amount == null) return '0.00 DH';
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} DH';
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.virement;

    // Meme mise en page que le detail d'expedition : bandeau degrade, cartes
    // posees dessus.
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      body: Stack(
        children: [
          Column(
            children: [
              // Bandeau et carte de synthese fixes : la liste defile dessous
              // et disparait sous la carte, au lieu de l'emporter avec elle.
              Stack(
                children: [
                  _entete(v),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      18,
                      MediaQuery.paddingOf(context).top + 134 - 30,
                      18,
                      14,
                    ),
                    child: CarteListe(
                      borderRadius: 22,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Le numero d'OV et le statut sont dans le bandeau.
                          Row(
                            children: [
                              const Text(
                                'Mandat N° ',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  v.numeroMandat ?? '—',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(height: 1, color: Color(0xFFEDF2F7)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Date du virement',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    v.dateVirement ?? v.dateMandat ?? '—',
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Montant total',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatCurrency(v.fond),
                                    style: const TextStyle(
                                      color: AppTheme.statusSuccess,
                                      fontSize: 18.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      _controller.fetchVirementDetail(v.idVirement),
                  color: AppTheme.primary,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                    children: [
                      // ─── 2. SECTION HEADER ──────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                LucideIcons.packageCheck,
                                color: AppTheme.primaryIcons,
                                size: 19,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Expéditions créditées',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Obx(
                            () => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.09),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: Text(
                                '${_controller.selectedVirementDetails.length} colis',
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ─── 3. EXPEDITIONS LIST ────────────────────────────────────────
                      Obx(() {
                        if (_controller.isLoadingDetail.value) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: CircularProgressIndicator(
                                color: AppTheme.primary,
                              ),
                            ),
                          );
                        }

                        final details = _controller.selectedVirementDetails;
                        if (details.isEmpty) {
                          return CarteListe(
                            borderRadius: 18,
                            padding: const EdgeInsets.symmetric(
                              vertical: 36,
                              horizontal: 20,
                            ),
                            child: const Center(
                              child: Column(
                                children: [
                                  Icon(
                                    LucideIcons.inbox,
                                    size: 40,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Aucune expédition rattachée à ce virement',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: details.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, idx) {
                            final item = details[idx];
                            return ScrollReveal(
                              index: idx,
                              child: CarteListe(
                                borderRadius: 16,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.iconGradient,
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      child: const Icon(
                                        LucideIcons.package,
                                        color: Colors.white,
                                        size: 19,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Décl: ${item.numDeclaration}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xFF0F172A),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13.5,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Dest: ${item.destinataire ?? "—"}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (valeurRenseignee(
                                                item.modeReglement,
                                              ) ||
                                              valeurRenseignee(
                                                item.refReglement,
                                              )) ...[
                                            const SizedBox(height: 1),
                                            Text(
                                              [
                                                    item.modeReglement,
                                                    item.refReglement,
                                                  ]
                                                  .where(valeurRenseignee)
                                                  .join(' • '),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Color(0xFF64748B),
                                                fontSize: 11.5,
                                              ),
                                            ),
                                          ],
                                          if (valeurRenseignee(
                                            item.dateEmission,
                                          )) ...[
                                            const SizedBox(height: 1),
                                            Text(
                                              'Émis le ${item.dateEmission}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Color(0xFF94A3B8),
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                          if (valeurRenseignee(
                                            item.dateValidation,
                                          )) ...[
                                            const SizedBox(height: 1),
                                            Text(
                                              'Validé le ${item.dateValidation}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Color(0xFF94A3B8),
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                          if (item.destination != null &&
                                              item.destination!.isNotEmpty) ...[
                                            const SizedBox(height: 1),
                                            Row(
                                              children: [
                                                const Icon(
                                                  LucideIcons.mapPin,
                                                  size: 11,
                                                  color: Color(0xFF94A3B8),
                                                ),
                                                const SizedBox(width: 3),
                                                Expanded(
                                                  child: Text(
                                                    item.destination!,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Color(0xFF94A3B8),
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _formatCurrency(item.montant),
                                      style: const TextStyle(
                                        color: AppTheme.statusSuccess,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Pose au-dessus du scroll : dans le bandeau il serait inaccessible.
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: SizedBox(
                height: 48,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(
                      LucideIcons.arrowLeft,
                      color: Colors.white,
                    ),
                    onPressed: () => Get.back<void>(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _entete(VirementCrbtModel v) {
    return Container(
      height: MediaQuery.paddingOf(context).top + 134,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B7A94), AppTheme.primary, Color(0xFF3FC1D8)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  // Place reservee au bouton de retour, pour aligner le titre.
                  SizedBox(width: 48, height: 48),
                  Text(
                    'Ordre de Virement',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.arrowUpRight,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.numOv,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        v.status ?? 'Exécuté',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
