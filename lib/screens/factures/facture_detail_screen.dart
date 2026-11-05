import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/facture_controller.dart';
import '../../models/facture_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/info_rows_card.dart';
import '../../widgets/carte_liste.dart';
import '../../widgets/scroll_reveal.dart';
import '../../widgets/colis_loader.dart';

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

    // Meme mise en page que le detail d'expedition : bandeau degrade, cartes
    // posees dessus.
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      body: Stack(
        children: [
          _entete(f),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 116, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── HERO INVOICE CARD ──────────────────────────────────────────
                  CarteListe(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Le numero, la date et le statut sont deja dans le bandeau.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildAmountCol(
                              'Montant HT',
                              _formatCurrency(f.mntHt),
                            ),
                            _buildAmountCol('TVA', _formatCurrency(f.mntTva)),
                            _buildAmountCol(
                              'Montant TTC',
                              _formatCurrency(f.mntTtc),
                              isBold: true,
                            ),
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
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                  ),
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
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                  ),
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

                  // ─── TOUT LE RESTE DE LA FACTURE ────────────────────────────────
                  // Champs renvoyes par /factures qui n'ont pas de place ci-dessus.
                  InfoRowsCard(
                    titre: 'Détail de la facture',
                    icone: LucideIcons.fileText,
                    lignes: [
                      // Le numero, les dates, le statut et les montants
                      // HT / TVA / TTC / solde sont deja portes par le bandeau
                      // et la carte d'en-tete : on ne garde ici que ce qui ne
                      // se voit nulle part ailleurs.
                      MapEntry('Client', f.libelle),
                      MapEntry('Date remise', f.dateRemise),
                      MapEntry(
                        'Remise',
                        f.remise == null || f.remise == 0
                            ? null
                            : _formatCurrency(f.remise),
                      ),
                      MapEntry(
                        'Taux de remise',
                        f.tauxRemise == null || f.tauxRemise == 0
                            ? null
                            : '${f.tauxRemise} %',
                      ),
                      MapEntry(
                        'Montant avoir',
                        f.mntAvoir == null || f.mntAvoir == 0
                            ? null
                            : _formatCurrency(f.mntAvoir),
                      ),
                      MapEntry(
                        'Montant réglé',
                        f.mntRegle == null ? null : _formatCurrency(f.mntRegle),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ─── RÈGLEMENTS SECTION ──────────────────────────────────────────
                  const Row(
                    children: [
                      Icon(
                        LucideIcons.checkCircle2,
                        color: AppTheme.primaryIcons,
                        size: 20,
                      ),
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
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 36),
                          child: ColisLoader(
                            size: 64,
                            message: 'Chargement des règlements...',
                          ),
                        ),
                      );
                    }

                    final detail = _controller.selectedDetail.value;
                    final reglements = detail?.reglements ?? [];

                    if (reglements.isEmpty) {
                      return const CarteListe(
                        borderRadius: 18,
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'Aucun règlement rattaché à cette facture',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reglements.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, idx) {
                        final reg = reglements[idx];
                        return ScrollReveal(
                          index: idx,
                          child: CarteListe(
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
                                        color: AppTheme.statusSuccess
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        LucideIcons.badgeCheck,
                                        color: AppTheme.statusSuccess,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                            Icon(
                              LucideIcons.receipt,
                              color: AppTheme.primaryIcons,
                              size: 20,
                            ),
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
                        ...avoirs.map(
                          (av) => CarteListe(
                            margin: const EdgeInsets.only(bottom: 10),
                            borderRadius: 16,
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 11.5,
                                        ),
                                      ),
                                      if (valeurRenseignee(av.remarque)) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          av.remarque!,
                                          style: const TextStyle(
                                            color: Color(0xFF475569),
                                            fontSize: 11.5,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
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
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 20),
                ],
              ),
            ),
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

  Widget _entete(FactureModel f) {
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
                    'Détail Facture',
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
                        LucideIcons.fileText,
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
                            'N° ${f.numFacture}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Émise le ${f.dateFacture ?? "—"}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.80),
                              fontSize: 12.5,
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
                        f.statut ?? (f.isPayee ? 'Payée' : 'En cours'),
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
