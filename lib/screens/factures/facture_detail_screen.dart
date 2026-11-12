import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/facture_controller.dart';
import '../../models/facture_detail_model.dart';
import '../../models/facture_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/info_rows_card.dart';
import '../../widgets/carte_liste.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/scroll_reveal.dart';
import '../../widgets/vagues_background.dart';

class FactureDetailScreen extends StatefulWidget {
  final FactureModel facture;

  const FactureDetailScreen({super.key, required this.facture});

  @override
  State<FactureDetailScreen> createState() => _FactureDetailScreenState();
}

class _FactureDetailScreenState extends State<FactureDetailScreen> {
  final FactureController _controller = Get.find<FactureController>();

  /// Volet affiche : 0 = avoirs, 1 = reglements.
  final PageController _voletController = PageController();
  int _volet = 0;

  @override
  void dispose() {
    _voletController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.facture.idFacture != null) {
      _controller.fetchDetail(
        widget.facture.idFacture!,
        base: widget.facture,
      );
    }
  }

  String _formatCurrency(num? amount) {
    if (amount == null) return '0.00 DH';
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} DH';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFD),
      body: Stack(
        children: [
          const Positioned.fill(child: VaguesBackground()),
          Obx(() {
            final f = _controller.selectedFacture.value ?? widget.facture;
            final detail = _controller.selectedDetail.value;
            final avoirs = detail?.avoirs ?? [];
            final reglements = detail?.reglements ?? [];

            return Column(
              children: [
                // Bandeau et carte de synthese fixes : meme logique que VirementDetailScreen
                Stack(
                  children: [
                    _entete(f),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        18,
                        MediaQuery.paddingOf(context).top + 102,
                        18,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ─── HERO INVOICE CARD ──────────────────────────────────────────
                          GlassContainer(
                            borderRadius: 20,
                            blur: 12,
                            color: Colors.white.withValues(alpha: 0.76),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildAmountCol(
                                      'Montant HT',
                                      _formatCurrency(f.mntHt),
                                    ),
                                    _buildAmountCol(
                                      'TVA',
                                      _formatCurrency(f.mntTva),
                                    ),
                                    _buildAmountCol(
                                      'Montant TTC',
                                      _formatCurrency(f.mntTtc),
                                      isBold: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 9),
                                const Divider(
                                  color: Color(0xFFEDF2F7),
                                  height: 1,
                                ),
                                const SizedBox(height: 9),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _buildAmountCol(
                                      'Montant réglé',
                                      _formatCurrency(f.mntRegle),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Échéance',
                                          style: TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 10.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          f.dateEcheance ?? '—',
                                          style: const TextStyle(
                                            color: Color(0xFFEA580C),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Solde restant dû',
                                          style: TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 10.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatCurrency(f.solde),
                                          style: TextStyle(
                                            color: f.isPayee
                                                ? AppTheme.statusSuccess
                                                : (f.isEnCours
                                                    ? const Color(0xFFEA580C)
                                                    : AppTheme.statusDanger),
                                            fontSize: 14.5,
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
                          const SizedBox(height: 10),
                          // ─── SELECTEUR VOLET (Avoirs / Reglements) ───
                          _selecteurVolet(avoirs.length, reglements.length),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // ─── AVOIRS & RÈGLEMENTS (remplit le reste de l'écran avec vagues visibles au fond) ───
                Expanded(
                  child: PageView(
                    controller: _voletController,
                    onPageChanged: (i) => setState(() => _volet = i),
                    children: [
                      _voletAvoirs(avoirs),
                      _voletReglements(reglements),
                    ],
                  ),
                ),
              ],
            );
          }),
          // Pose au-dessus du scroll : dans le bandeau il serait inaccessible.
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        LucideIcons.arrowLeft,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Get.back<void>(),
                    ),
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
      height: MediaQuery.paddingOf(context).top + 152,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B7A94), AppTheme.primary, Color(0xFF3FC1D8)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
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
                  SizedBox(width: 44, height: 42),
                  Text(
                    'Détail Facture',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.fileText,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
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
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Date facture : ${f.dateFacture ?? "—"}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        f.isPayee
                            ? 'Payée'
                            : (f.isEnCours
                                ? 'En cours'
                                : (f.statut ?? 'En retard')),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
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

  Widget _voletAvoirs(List<FactureAvoir> avoirs) {
    if (avoirs.isEmpty) {
      return _voletVide('Aucun avoir déduit de cette facture');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 20),
      itemCount: avoirs.length,
      itemBuilder: (context, i) {
        final av = avoirs[i];

        return ScrollReveal(
          index: i,
          child: CarteListe(
            margin: const EdgeInsets.only(bottom: 8),
            borderRadius: 14,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Avoir N° ${av.numAvoir}',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Créé le : ${av.dateCreation ?? "—"}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                      if (valeurRenseignee(av.remarque)) ...[
                        const SizedBox(height: 2),
                        Text(
                          av.remarque!,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 11,
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
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _voletReglements(List<FactureReglement> reglements) {
    if (_controller.isLoadingDetail.value) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryIcons),
      );
    }
    if (reglements.isEmpty) {
      return _voletVide('Aucun règlement rattaché à cette facture');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 20),
      itemCount: reglements.length,
      itemBuilder: (context, i) {
        final reg = reglements[i];

        return ScrollReveal(
          index: i,
          child: CarteListe(
            margin: const EdgeInsets.only(bottom: 8),
            borderRadius: 14,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.statusSuccess.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.badgeCheck,
                          color: AppTheme.statusSuccess,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reg.modeReglement,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Réf: ${reg.refReglement} • Date: ${reg.dateCreation ?? "—"}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _formatCurrency(reg.montant),
                  style: const TextStyle(
                    color: AppTheme.statusSuccess,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Bascule entre les deux volets, du meme dessin que l'onglet du profil.
  Widget _selecteurVolet(int nbAvoirs, int nbReglements) {
    return Container(
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _ongletVolet(0, 'Avoirs', nbAvoirs)),
          Expanded(child: _ongletVolet(1, 'Règlements', nbReglements)),
        ],
      ),
    );
  }

  Widget _ongletVolet(int index, String libelle, int nombre) {
    final actif = _volet == index;

    return GestureDetector(
      onTap: () => _voletController.animateToPage(
        index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          gradient: actif ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            '$libelle ($nombre)',
            style: TextStyle(
              color: actif ? Colors.white : const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _voletVide(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.inbox,
                size: 22,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
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
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: isBold ? const Color(0xFF0F172A) : const Color(0xFF334155),
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            fontSize: isBold ? 13 : 12,
          ),
        ),
      ],
    );
  }
}
