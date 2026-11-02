import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/expedition_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/status_badge.dart';

class ExpeditionDetailScreen extends StatefulWidget {
  final int idExpedition;

  const ExpeditionDetailScreen({super.key, required this.idExpedition});

  @override
  State<ExpeditionDetailScreen> createState() => _ExpeditionDetailScreenState();
}

class _ExpeditionDetailScreenState extends State<ExpeditionDetailScreen> {
  final ExpeditionController _controller = Get.find<ExpeditionController>();

  @override
  void initState() {
    super.initState();
    _controller.fetchDetail(widget.idExpedition);
  }

  String _formatCurrency(num? amount) {
    if (amount == null) return '0.00 DH';
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} DH';
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      isLight: true,
      appBar: AppBar(
        title: const Text(
          'Détail Expédition',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.primary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoadingDetail.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        final detail = _controller.selectedDetail.value;
        if (detail == null) {
          return const Center(
            child: Text(
              'Aucune donnée disponible',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── HERO HEADER CARD ──────────────────────────────────────────
              GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'N° ${detail.numDeclaration}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Date taxation : ${detail.dateTaxation ?? "—"}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: detail.port ?? 'Standard'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE2E8F0), height: 1),
                    const SizedBox(height: 16),

                    // Route (Origine -> Destination)
                    Row(
                      children: [
                        _buildRoutePill(LucideIcons.circleDot, 'Origine', detail.origine ?? '—'),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Divider(color: AppTheme.primary.withOpacity(0.3), thickness: 1.5),
                          ),
                        ),
                        _buildRoutePill(LucideIcons.mapPin, 'Destination', detail.destination ?? '—'),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Metrics Row (Poids, Colis, TTC, Fond)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricCol('Poids', '${detail.poids ?? 0} kg'),
                        _buildMetricCol('Colis', '${detail.colis ?? 0} colis'),
                        _buildMetricCol('Montant TTC', _formatCurrency(detail.mntTtc)),
                        _buildMetricCol('Fond CRBT', _formatCurrency(detail.fond)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ─── EXPÉDITEUR & DESTINATAIRE ──────────────────────────────────
              GlassContainer(
                borderRadius: 20,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildActorRow(LucideIcons.send, 'Expéditeur', detail.expediteur ?? '—', detail.expediteurAdresse),
                    const SizedBox(height: 14),
                    const Divider(color: Color(0xFFE2E8F0), height: 1),
                    const SizedBox(height: 14),
                    _buildActorRow(LucideIcons.userCheck, 'Destinataire', detail.destinataire ?? '—', null),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── SUIVI PROCESSUS (TIMELINE DE LIVRAISON) ───────────────────
              const Row(
                children: [
                  Icon(LucideIcons.gitCommit, color: AppTheme.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Suivi & Étapes de Livraison',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (detail.processus.isEmpty)
                const GlassContainer(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(18),
                  child: Center(
                    child: Text(
                      'Aucune étape de transport enregistrée',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: detail.processus.length,
                  itemBuilder: (context, idx) {
                    final step = detail.processus[idx];
                    final isLast = idx == detail.processus.length - 1;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isLast
                                      ? AppTheme.statusSuccess.withOpacity(0.15)
                                      : AppTheme.primary.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isLast ? AppTheme.statusSuccess : AppTheme.primary,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    isLast ? LucideIcons.check : LucideIcons.circle,
                                    size: 14,
                                    color: isLast ? AppTheme.statusSuccess : AppTheme.primary,
                                  ),
                                ),
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: AppTheme.primary.withOpacity(0.25),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 18.0),
                              child: GlassContainer(
                                borderRadius: 16,
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            step.processus,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xFF0F172A),
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        if (step.status != null) ...[
                                          const SizedBox(width: 8),
                                          StatusBadge(status: step.status!, fontSize: 10),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    if (step.dateAction != null)
                                      Row(
                                        children: [
                                          const Icon(LucideIcons.clock, size: 12, color: Color(0xFF94A3B8)),
                                          const SizedBox(width: 4),
                                          Text(
                                            step.dateAction!,
                                            style: const TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (step.faitA != null || step.faitPar != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Lieu: ${step.faitA ?? "—"} • Agent: ${step.faitPar ?? "—"}',
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                    if (step.livreurChauffeur != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Chauffeur: ${step.livreurChauffeur}',
                                        style: const TextStyle(
                                          color: AppTheme.primary,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 16),

              // ─── DOCUMENTS GED (PDF / IMAGES) ──────────────────────────────
              if (detail.gedDocuments.isNotEmpty) ...[
                const Row(
                  children: [
                    Icon(LucideIcons.fileText, color: AppTheme.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Documents GED (Preuves / Facturation)',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...detail.gedDocuments.map((doc) => GlassContainer(
                      margin: const EdgeInsets.only(bottom: 10),
                      borderRadius: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.fileCode, color: AppTheme.primary, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.typeDocument.isNotEmpty ? doc.typeDocument : 'Document GED',
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  doc.lien,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.externalLink, color: AppTheme.primary, size: 18),
                            onPressed: () {
                              Get.snackbar(
                                'Lien GED',
                                doc.lien,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.white,
                                colorText: const Color(0xFF0F172A),
                              );
                            },
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 18),
              ],

              // ─── RETOURS DE FONDS / CC / CT ────────────────────────────────
              if (detail.retourCcCt.isNotEmpty) ...[
                const Row(
                  children: [
                    Icon(LucideIcons.badgePercent, color: AppTheme.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Retours Chèques / Traites',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...detail.retourCcCt.map((item) => GlassContainer(
                      margin: const EdgeInsets.only(bottom: 10),
                      borderRadius: 16,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item["nature"] ?? "CC/CT"} • BL/Fact: ${item["num_bl_fact"] ?? "—"}',
                                style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700, fontSize: 13.5),
                              ),
                              Text(
                                _formatCurrency(item["fond"] as num?),
                                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 13.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Banque: ${item["banque"] ?? "—"} • Encaissement: ${item["date_encaissement"] ?? "—"} • Remise: ${item["date_remise"] ?? "—"}',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 18),
              ],

              // ─── COMMENTAIRES ──────────────────────────────────────────────
              if (detail.commentaires.isNotEmpty) ...[
                const Row(
                  children: [
                    Icon(LucideIcons.messageSquare, color: AppTheme.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Commentaires & Réserves',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...detail.commentaires.map((c) => GlassContainer(
                      margin: const EdgeInsets.only(bottom: 10),
                      borderRadius: 16,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                c.typeComment ?? 'Note',
                                style: const TextStyle(
                                  color: AppTheme.statusWarning,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                c.dateComment ?? '',
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c.libelleComment ?? '',
                            style: const TextStyle(color: Color(0xFF334155), fontSize: 12.5),
                          ),
                          if (c.agentComment != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Par: ${c.agentComment}',
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    )),
              ],

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRoutePill(IconData icon, String label, String city) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
        ),
        Text(
          city,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCol(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildActorRow(IconData icon, String title, String name, String? address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
              Text(
                name,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              if (address != null && address.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  address,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
