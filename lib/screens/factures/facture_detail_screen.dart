import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/facture_controller.dart';
import '../../models/facture_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/status_badge.dart';

class FactureDetailScreen extends StatefulWidget {
  final FactureModel facture;

  const FactureDetailScreen({super.key, required this.facture});

  @override
  State<FactureDetailScreen> createState() => _FactureDetailScreenState();
}

class _FactureDetailScreenState extends State<FactureDetailScreen> {
  final FactureController _controller = Get.find<FactureController>();

  @override
  void initState() {
    super.initState();
    if (widget.facture.idFacture != null) {
      _controller.fetchDetail(widget.facture.idFacture!);
    }
  }

  String _formatCurrency(num? amount) {
    if (amount == null) return '0.00 DH';
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} DH';
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.facture;

    return GlassScaffold(
      appBar: AppBar(
        title: Text('Facture ${f.numFacture}'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.primaryIcons),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── HERO INVOICE CARD ──────────────────────────────────────────
            GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Facture N° ${f.numFacture}',
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 18.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Émise le : ${f.dateFacture ?? "—"}',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                      StatusBadge(status: f.statut ?? (f.isPayee ? 'Payée' : 'En cours')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  const SizedBox(height: 16),

                  // Amount details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAmountCol('Montant HT', _formatCurrency(f.mntHt)),
                      _buildAmountCol('TVA', _formatCurrency(f.mntTva)),
                      _buildAmountCol('Montant TTC', _formatCurrency(f.mntTtc), isBold: true),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  const SizedBox(height: 16),

                  // Solde Remaining
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Solde restant dû :',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatCurrency(f.solde),
                            style: TextStyle(
                              color: (f.solde != null && f.solde! > 0)
                                  ? AppTheme.statusDanger
                                  : AppTheme.statusSuccess,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Échéance :',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            f.dateEcheance ?? '—',
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── RÈGLEMENTS SECTION ──────────────────────────────────────────
            const Row(
              children: [
                Icon(LucideIcons.checkCircle2, color: AppTheme.primaryIcons, size: 20),
                SizedBox(width: 8),
                Text(
                  'Règlements enregistrés',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Obx(() {
              if (_controller.isLoadingDetail.value) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryIcons));
              }

              final detail = _controller.selectedDetail.value;
              final reglements = detail?.reglements ?? [];

              if (reglements.isEmpty) {
                return const GlassContainer(
                  borderRadius: 18,
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Aucun règlement rattaché à cette facture',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reglements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, idx) {
                  final reg = reglements[idx];
                  return GlassContainer(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.statusSuccess.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(LucideIcons.badgeCheck, color: AppTheme.statusSuccess, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reg.modeReglement,
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Réf: ${reg.refReglement} • Date: ${reg.dateCreation ?? "—"}',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          _formatCurrency(reg.montant),
                          style: const TextStyle(
                            color: AppTheme.statusSuccess,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),

            const SizedBox(height: 24),

            // ─── AVOIRS DÉDUITS SECTION ──────────────────────────────────────
            Obx(() {
              final detail = _controller.selectedDetail.value;
              final avoirs = detail?.avoirs ?? [];
              if (avoirs.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(LucideIcons.receipt, color: AppTheme.primaryIcons, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Avoirs déduits',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...avoirs.map((av) => GlassContainer(
                        margin: const EdgeInsets.only(bottom: 10),
                        borderRadius: 16,
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Avoir N° ${av.numAvoir}',
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Créé le : ${av.dateCreation ?? "—"}',
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                                ),
                              ],
                            ),
                            Text(
                              '- ${_formatCurrency(av.montant)}',
                              style: const TextStyle(
                                color: AppTheme.statusWarning,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              );
            }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCol(String label, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: isBold ? const Color(0xFF0F172A) : const Color(0xFF334155),
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            fontSize: isBold ? 14.5 : 13.5,
          ),
        ),
      ],
    );
  }
}
