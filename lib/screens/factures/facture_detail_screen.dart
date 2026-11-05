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
import '../../widgets/scroll_reveal.dart';

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

                        // Ce qui a deja ete paye, et la date limite.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildAmountCol(
                              'Montant réglé',
                              _formatCurrency(f.mntRegle),
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

                        const SizedBox(height: 14),

                        // Le solde reste le chiffre qu'on vient chercher.
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
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── AVOIRS & RÈGLEMENTS (deux volets d'une même carte) ─────────
                  Obx(() {
                    final detail = _controller.selectedDetail.value;
                    final avoirs = detail?.avoirs ?? [];
                    final reglements = detail?.reglements ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _selecteurVolet(avoirs.length, reglements.length),
                        const SizedBox(height: 12),
                        SizedBox(
                          // Hauteur fixe : un PageView ne peut pas se dimensionner
                          // sur son contenu. Chaque volet defile a l'interieur.
                          height: 300,
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
                            'Date ${f.dateFacture ?? "—"}',
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

  Widget _voletAvoirs(List<FactureAvoir> avoirs) {
    if (avoirs.isEmpty) {
      return _voletVide('Aucun avoir déduit de cette facture');
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: avoirs.length,
      itemBuilder: (context, i) {
        final av = avoirs[i];

        return ScrollReveal(
          index: i,
          child: CarteListe(
            margin: const EdgeInsets.only(bottom: 10),
            borderRadius: 16,
            padding: const EdgeInsets.all(14),
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
      padding: EdgeInsets.zero,
      itemCount: reglements.length,
      itemBuilder: (context, i) {
        final reg = reglements[i];

        return ScrollReveal(
          index: i,
          child: CarteListe(
            margin: const EdgeInsets.only(bottom: 10),
            borderRadius: 16,
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.statusSuccess.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          LucideIcons.badgeCheck,
                          color: AppTheme.statusSuccess,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11.5,
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
  }

  /// Bascule entre les deux volets, du meme dessin que l'onglet du profil.
  Widget _selecteurVolet(int nbAvoirs, int nbReglements) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(16),
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
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          gradient: actif ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            '$libelle ($nombre)',
            style: TextStyle(
              color: actif ? Colors.white : const Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  /// Etat vide d'un volet : il dit qu'il est vide plutot que de disparaitre.
  Widget _voletVide(String message) {
    return CarteListe(
      borderRadius: 18,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
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
