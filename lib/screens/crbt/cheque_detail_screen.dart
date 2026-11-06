import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/crbt_controller.dart';
import '../../models/crbt_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/info_rows_card.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/scroll_reveal.dart';

class ChequeDetailScreen extends StatefulWidget {
  final ChequeCrbtModel cheque;

  const ChequeDetailScreen({super.key, required this.cheque});

  @override
  State<ChequeDetailScreen> createState() => _ChequeDetailScreenState();
}

class _ChequeDetailScreenState extends State<ChequeDetailScreen> {
  final CrbtController _controller = Get.find<CrbtController>();

  @override
  void initState() {
    super.initState();
    _controller.fetchChequeDetail(widget.cheque.idCheque);
  }

  String _formatCurrency(num? amount) {
    if (amount == null) return '0.00 DH';
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} DH';
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cheque;

    return GlassScaffold(
      appBar: AppBar(
        title: Text(
          'Chèque N° ${c.numCheque}',
          style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.primaryIcons),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _controller.fetchChequeDetail(c.idCheque),
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
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Icon(
                          LucideIcons.creditCard,
                          color: AppTheme.primary,
                          size: 22,
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
                                    (c.typeRemboursement != null &&
                                            c.typeRemboursement!
                                                .toLowerCase()
                                                .contains('vir'))
                                        ? 'Virement ${c.numCheque}'
                                        : 'Chèque ${c.numCheque}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (c.typeRemboursement != null &&
                                    c.typeRemboursement!.trim().isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          (c.typeRemboursement!
                                                      .toLowerCase()
                                                      .contains('vir')
                                                  ? const Color(0xFF0EA5E9)
                                                  : const Color(0xFFA855F7))
                                              .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color:
                                            (c.typeRemboursement!
                                                        .toLowerCase()
                                                        .contains('vir')
                                                    ? const Color(0xFF0EA5E9)
                                                    : const Color(0xFFA855F7))
                                                .withValues(alpha: 0.28),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      c.typeRemboursement!
                                              .toLowerCase()
                                              .contains('vir')
                                          ? 'Virement'
                                          : 'Chèque',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            c.typeRemboursement!
                                                .toLowerCase()
                                                .contains('vir')
                                            ? const Color(0xFF0284C7)
                                            : const Color(0xFF9333EA),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Banque : ${c.banque ?? "—"}',
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
                            'Date de remise',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            c.dateRemise ?? c.dateImpression ?? '—',
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
                            _formatCurrency(c.montant),
                            style: const TextStyle(
                              color: AppTheme.primary,
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
                    Icon(
                      LucideIcons.packageCheck,
                      color: AppTheme.primaryIcons,
                      size: 19,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Expéditions couvertes',
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
                        color: AppTheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      '${_controller.selectedChequeDetails.length} colis',
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
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                );
              }

              final details = _controller.selectedChequeDetails;
              if (details.isEmpty) {
                return GlassContainer(
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
                          'Aucune expédition rattachée à ce chèque',
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
                physics: const NeverScrollableScrollPhysics(),
                itemCount: details.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, idx) {
                  final item = details[idx];
                  return ScrollReveal(
                    index: idx,
                    child: GlassContainer(
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
                                if (valeurRenseignee(item.typeRemboursement) ||
                                    valeurRenseignee(item.modeReglement) ||
                                    valeurRenseignee(item.refReglement)) ...[
                                  const SizedBox(height: 1),
                                  Text(
                                    [
                                      item.typeRemboursement,
                                      item.modeReglement,
                                      item.refReglement,
                                    ].where(valeurRenseignee).join(' • '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                                if (valeurRenseignee(item.dateEmission) ||
                                    valeurRenseignee(item.dateValidation)) ...[
                                  const SizedBox(height: 1),
                                  Text(
                                    [
                                      if (valeurRenseignee(item.dateEmission))
                                        'Émis le ${item.dateEmission}',
                                      if (valeurRenseignee(item.dateValidation))
                                        'Validé le ${item.dateValidation}',
                                    ].join(' • '),
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
                              color: AppTheme.primary,
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
    );
  }
}
