import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/retour_fond_controller.dart';
import '../../models/retour_fond_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/carte_accent.dart';
import '../../widgets/carte_liste.dart';
import '../../widgets/etiquette_valeur.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/info_rows_card.dart';
import '../../widgets/scroll_reveal.dart';
import '../../widgets/vagues_background.dart';
import '../expeditions/expedition_detail_screen.dart';

class BordereauDetailScreen extends StatefulWidget {
  final String bordereau;
  final dynamic idBordereau;
  final String? dateAffectation;
  final String? dateRemise;

  const BordereauDetailScreen({
    super.key,
    required this.bordereau,
    required this.idBordereau,
    this.dateAffectation,
    this.dateRemise,
  });

  @override
  State<BordereauDetailScreen> createState() => _BordereauDetailScreenState();
}

class _BordereauDetailScreenState extends State<BordereauDetailScreen> {
  final RetourFondController _controller = Get.find<RetourFondController>();

  @override
  void initState() {
    super.initState();
    _controller.fetchDetailBordereau(widget.idBordereau);
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
          Column(
            children: [
              // ─── BANDEAU + CARTE DE SYNTHÈSE ─────────────────────────────
              Stack(
                children: [
                  _entete(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      18,
                      MediaQuery.paddingOf(context).top + 98,
                      18,
                      10,
                    ),
                    child: Obx(() {
                      final details = _controller.selectedBordereauDetails;
                      final num totalFond = details.fold<num>(
                        0,
                        (sum, e) => sum + (e.fond ?? 0),
                      );
                      final String? affectation =
                          details.isNotEmpty &&
                              valeurRenseignee(details.first.dateAffectation)
                          ? details.first.dateAffectation
                          : widget.dateAffectation;

                      return GlassContainer(
                        borderRadius: 18,
                        blur: 12,
                        color: Colors.white.withValues(alpha: 0.76),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Date d\'affectation',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  affectation ?? '—',
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 13,
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
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatCurrency(totalFond),
                                  style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),

              // ─── LISTE DES DÉCLARATIONS DU BORDEREAU ─────────────────────
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      _controller.fetchDetailBordereau(widget.idBordereau),
                  color: AppTheme.primary,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                LucideIcons.packageCheck,
                                color: AppTheme.primaryIcons,
                                size: 17,
                              ),
                              SizedBox(width: 7),
                              Text(
                                'Déclarations du bordereau',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Obx(
                            () => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
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
                                '${_controller.selectedBordereauDetails.length} colis',
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
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

                        final details = _controller.selectedBordereauDetails;
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
                                    'Aucune déclaration rattachée à ce bordereau',
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
                              const SizedBox(height: 8),
                          itemBuilder: (context, idx) {
                            final item = details[idx];
                            return ScrollReveal(
                              index: idx,
                              child: _buildDetailItemCard(item),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: SizedBox(
                  width: 48,
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
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItemCard(BordereauDetailItem item) {
    final isMoney = item.fond != null && item.fond! > 0;

    const bleu = Color(0xFF007EBE);
    const bleuVif = Color(0xFF1263BF);
    const gris = Color(0xFF637D9B);
    const vert = Color(0xFF00927A);

    const k = 0.62;
    const serre = 1.1;

    return CarteAccent(
      teinte: bleu,
      icone: isMoney ? LucideIcons.coins : LucideIcons.fileText,
      fondTeinte: false,
      fond: const Color(0xFFEFF8FE),
      rayon: 18,
      onTap: item.idExpedition == null
          ? null
          : () => Get.to(
              () => ExpeditionDetailScreen(idExpedition: item.idExpedition!),
              transition: Transition.cupertino,
              duration: const Duration(milliseconds: 360),
            ),
      ombres: [
        BoxShadow(
          color: const Color(0xFF269BC4).withValues(alpha: 0.20),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      couleurFiligrane: const Color(0xFFD9EAFB).withValues(alpha: 0.35),
      tailleFiligrane: 86 * k,
      basFiligrane: 52 * k,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8 * k, 11, 7 * k),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── En-tête : icône, N° décl, mode règlement & montant ───────
            Row(
              children: [
                Container(
                  width: 40 * k,
                  height: 40 * k,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9FDEF6),
                    borderRadius: BorderRadius.circular(10 * k),
                  ),
                  child: Icon(
                    isMoney ? LucideIcons.coins : LucideIcons.fileText,
                    color: const Color(0xFF0786B9),
                    size: 22 * k,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: EtiquetteValeur(
                      intitule: 'N° décl : ',
                      valeur: valeurRenseignee(item.numDeclaration)
                          ? '${item.numDeclaration}'
                          : '—',
                      couleur: bleuVif,
                      couleurIntitule: gris,
                      taille: 17 * k,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (valeurRenseignee(item.modeReglement))
                      _badgeNature(item.modeReglement!, k),
                    if (isMoney) ...[
                      SizedBox(height: 3 * k),
                      Text(
                        _formatCurrency(item.fond),
                        style: const TextStyle(
                          color: bleu,
                          fontSize: 18 * k,
                          height: serre,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            SizedBox(height: 5 * k),
            const Divider(color: Color(0xFFC9E3F4), height: 1),
            SizedBox(height: 5 * k),

            // ─── Destinataire ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Destinataire',
                    style: TextStyle(
                      color: Color(0xFF506B91),
                      fontSize: 15.5 * k,
                      height: serre,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 1.5 * k),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: item.destinataire?.trim() ?? '—',
                          style: const TextStyle(
                            color: bleuVif,
                            fontSize: 18.5 * k,
                            height: serre,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (valeurRenseignee(item.destination)) ...[
                          const TextSpan(
                            text: '  |  ',
                            style: TextStyle(
                              color: Color(0xFF9BB8D6),
                              fontSize: 16.5 * k,
                              height: serre,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: item.destination!,
                            style: const TextStyle(
                              color: Color(0xFF0082BF),
                              fontSize: 16.5 * k,
                              height: serre,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ─── Banque & Saisie ──────────────────────────────────────────
            if (valeurRenseignee(item.banque) ||
                valeurRenseignee(item.dateSaisie)) ...[
              SizedBox(height: 6 * k),
              Wrap(
                spacing: 12 * k,
                runSpacing: 4 * k,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (valeurRenseignee(item.banque))
                    _mentionJeton(
                      LucideIcons.landmark,
                      const Color(0xFFC2EDFC),
                      const Color(0xFF0086CA),
                      'Banque : ',
                      item.banque!,
                      const Color(0xFF0560D2),
                      const Color(0xFF6D809C),
                      k,
                    ),
                  if (valeurRenseignee(item.dateSaisie))
                    _mentionJeton(
                      LucideIcons.calendar,
                      const Color(0xFFC2EDFC),
                      const Color(0xFF0086CA),
                      'Saisie : ',
                      item.dateSaisie!,
                      bleuVif,
                      const Color(0xFF6D809C),
                      k,
                    ),
                ],
              ),
            ],

            // ─── Livré & Remis + Flèche ───────────────────────────────────
            if (valeurRenseignee(item.dateLivraison) ||
                valeurRenseignee(item.dateRemise) ||
                item.idExpedition != null) ...[
              SizedBox(height: 6 * k),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 12 * k,
                      runSpacing: 4 * k,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (valeurRenseignee(item.dateLivraison))
                          _mentionJeton(
                            LucideIcons.check,
                            const Color(0xFFC1F0E4),
                            const Color(0xFF00A486),
                            'Livré : ',
                            item.dateLivraison!,
                            vert,
                            const Color(0xFF415C7D),
                            k,
                          ),
                        if (valeurRenseignee(item.dateRemise))
                          _mentionJeton(
                            LucideIcons.check,
                            const Color(0xFFC1F0E4),
                            const Color(0xFF00A486),
                            'Remis : ',
                            item.dateRemise!,
                            vert,
                            const Color(0xFF415C7D),
                            k,
                          ),
                      ],
                    ),
                  ),
                  if (item.idExpedition != null)
                    Container(
                      width: 28 * k,
                      height: 28 * k,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9EFFC),
                        borderRadius: BorderRadius.circular(8 * k),
                        border: Border.all(
                          color: const Color(0xFF7FCDEE),
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.chevronRight,
                        size: 17 * k,
                        color: bleuVif,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _badgeNature(String nature, double k) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * k, vertical: 4.5 * k),
      decoration: BoxDecoration(
        color: const Color(0xFFBBE8FA),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFF7FCDEE)),
      ),
      child: Text(
        nature,
        style: TextStyle(
          color: const Color(0xFF0083BF),
          fontSize: 14 * k,
          height: 1.15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _mentionJeton(
    IconData icone,
    Color fondJeton,
    Color teinteJeton,
    String intitule,
    String valeur,
    Color couleur,
    Color couleurIntitule,
    double k,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 25 * k,
          height: 25 * k,
          decoration: BoxDecoration(
            color: fondJeton,
            borderRadius: BorderRadius.circular(8 * k),
          ),
          child: Icon(icone, color: teinteJeton, size: 14.5 * k),
        ),
        SizedBox(width: 6 * k),
        EtiquetteValeur(
          intitule: intitule,
          valeur: valeur,
          couleur: couleur,
          couleurIntitule: couleurIntitule,
          taille: 16.5 * k,
        ),
      ],
    );
  }

  Widget _entete() {
    final bool estRemis = valeurRenseignee(widget.dateRemise);
    return Container(
      height: MediaQuery.paddingOf(context).top + 132,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B7A94), AppTheme.primary, Color(0xFF3FC1D8)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
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
                  SizedBox(width: 48, height: 44),
                  Text(
                    'Détail Bordereau',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
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
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.fileSpreadsheet,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.bordereau,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
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
                        estRemis ? 'Remis' : 'Affecté',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
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
