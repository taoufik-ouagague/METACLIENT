import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/crbt_controller.dart';
import '../../models/crbt_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/carte_accent.dart';
import '../../widgets/carte_liste.dart';
import '../../widgets/etiquette_valeur.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/info_rows_card.dart';
import '../../widgets/scroll_reveal.dart';
import '../../widgets/vagues_background.dart';
import '../expeditions/expedition_detail_screen.dart';

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

    // Meme mise en page que le detail de bordereau : bandeau degrade, cartes
    // posees dessus.
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFD),
      body: Stack(
        children: [
          const Positioned.fill(child: VaguesBackground()),
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
                      MediaQuery.paddingOf(context).top + 98,
                      18,
                      10,
                    ),
                    child: GlassContainer(
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
                                'Date du virement',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                v.dateVirement ?? v.dateMandat ?? '—',
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
                                _formatCurrency(v.fond),
                                style: const TextStyle(
                                  color: AppTheme.statusSuccess,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                ),
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
                                size: 17,
                              ),
                              SizedBox(width: 7),
                              Text(
                                'Expéditions créditées',
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
                                '${_controller.selectedVirementDetails.length} colis',
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
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, idx) {
                            final item = details[idx];
                            return ScrollReveal(
                              index: idx,
                              child: _buildDetailItemCard(item),
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

  Widget _buildDetailItemCard(VirementCrbtDetailItem item) {
    const bleu = Color(0xFF007EBE);
    const bleuVif = Color(0xFF1263BF);
    const gris = Color(0xFF637D9B);
    const vert = Color(0xFF00927A);

    const k = 0.62;
    const serre = 1.1;

    return CarteAccent(
      teinte: bleu,
      icone: LucideIcons.package,
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
                  child: const Icon(
                    LucideIcons.package,
                    color: Color(0xFF0786B9),
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
                          ? item.numDeclaration
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
                    SizedBox(height: 3 * k),
                    Text(
                      _formatCurrency(item.montant),
                      style: const TextStyle(
                        color: AppTheme.statusSuccess,
                        fontSize: 18 * k,
                        height: serre,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
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

            // ─── Pied : Émis, Validé, Réf ─────────────────────────────────
            if (valeurRenseignee(item.dateEmission) ||
                valeurRenseignee(item.dateValidation) ||
                valeurRenseignee(item.refReglement)) ...[
              SizedBox(height: 5 * k),
              const Divider(color: Color(0xFFC9E3F4), height: 1),
              SizedBox(height: 5 * k),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 16 * k,
                      runSpacing: 5 * k,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (valeurRenseignee(item.refReglement))
                          _mentionJeton(
                            LucideIcons.hash,
                            const Color(0xFFD5EFFC),
                            const Color(0xFF0B8AC0),
                            'Réf : ',
                            item.refReglement!,
                            const Color(0xFF0082BF),
                            gris,
                            k,
                          ),
                        if (valeurRenseignee(item.dateEmission))
                          _mentionJeton(
                            LucideIcons.calendar,
                            const Color(0xFFDCEAFB),
                            bleuVif,
                            'Émis : ',
                            item.dateEmission!,
                            bleuVif,
                            gris,
                            k,
                          ),
                        if (valeurRenseignee(item.dateValidation))
                          _mentionJeton(
                            LucideIcons.calendarCheck,
                            const Color(0xFFCAEEE3),
                            const Color(0xFF009B7A),
                            'Validé : ',
                            item.dateValidation!,
                            vert,
                            gris,
                            k,
                          ),
                      ],
                    ),
                  ),
                  if (item.idExpedition != null)
                    const Icon(
                      LucideIcons.chevronRight,
                      color: bleuVif,
                      size: 20 * k,
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
      padding: EdgeInsets.symmetric(horizontal: 11 * k, vertical: 4 * k),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF4FD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF66C2EC)),
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

  Widget _entete(VirementCrbtModel v) {
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
                  // Place reservee au bouton de retour, pour aligner le titre.
                  SizedBox(width: 48, height: 44),
                  Text(
                    'Ordre de Virement',
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
                        LucideIcons.arrowUpRight,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        v.numOv,
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
                        v.status ?? 'Exécuté',
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
