import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/crbt_controller.dart';
import '../../models/crbt_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/status_badge.dart';

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

    return GlassScaffold(
      appBar: AppBar(
        title: Text(
          'Ordre de Virement ${v.numOv}',
          style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.primaryIcons),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _controller.fetchVirementDetail(v.idVirement),
        color: AppTheme.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          children: [
            // ─── 1. HERO SUMMARY CARD ───────────────────────────────────────
            GlassContainer(
              borderRadius: 22,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.statusSuccess.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.statusSuccess.withOpacity(0.25),
                          ),
                        ),
                        child: const Icon(
                          LucideIcons.arrowUpRight,
                          color: AppTheme.statusSuccess,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Virement ${v.numOv}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Mandat N° : ${v.numeroMandat ?? "—"}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(status: v.status ?? 'Exécuté'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  const SizedBox(height: 14),

                  // Dates & Montant
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

            const SizedBox(height: 22),

            // ─── 2. SECTION HEADER ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.packageCheck, color: AppTheme.primaryIcons, size: 19),
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
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.09),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primary.withOpacity(0.2),
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
                    )),
              ],
            ),

            const SizedBox(height: 12),

            // ─── 3. EXPEDITIONS LIST ────────────────────────────────────────
            Obx(() {
              if (_controller.isLoadingDetail.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                );
              }

              final details = _controller.selectedVirementDetails;
              if (details.isEmpty) {
                return GlassContainer(
                  borderRadius: 18,
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(LucideIcons.inbox, size: 40, color: Color(0xFF94A3B8)),
                        SizedBox(height: 10),
                        Text(
                          'Aucune expédition rattachée à ce virement',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13.5),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: details.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, idx) {
                  final item = details[idx];
                  return GlassContainer(
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              if (item.destination != null && item.destination!.isNotEmpty) ...[
                                const SizedBox(height: 1),
                                Row(
                                  children: [
                                    const Icon(LucideIcons.mapPin, size: 11, color: Color(0xFF94A3B8)),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        item.destination!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                  );
                },
              );
            }),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
