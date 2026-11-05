import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/expedition_controller.dart';
import '../../models/expedition_detail_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/scroll_reveal.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_scaffold.dart';
import 'expedition_detail_screen.dart';

/// Suivi d'une expedition a partir de son numero de declaration.
///
/// L'API renvoie exactement la meme fiche que le detail d'une expedition :
/// une fois trouvee, on reutilise l'ecran de detail au lieu d'en refaire un.
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final ExpeditionController _controleur = Get.find<ExpeditionController>();
  final TextEditingController _saisie = TextEditingController();
  final FocusNode _focus = FocusNode();

  bool _recherche = false;
  String? _introuvable;

  @override
  void initState() {
    super.initState();
    // Le clavier s'ouvre tout de suite : l'ecran n'a qu'un seul usage.
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _saisie.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _lancerRecherche() async {
    final numero = _saisie.text.trim();
    if (numero.isEmpty) {
      setState(() => _introuvable = 'Saisissez un numéro de déclaration.');

      return;
    }

    _focus.unfocus();
    setState(() {
      _recherche = true;
      _introuvable = null;
    });

    final nombre = await _controleur.fetchTracking(numero);
    if (!mounted) return;
    setState(() {
      _recherche = false;
      _introuvable = nombre > 0
          ? null
          : 'Aucune expédition pour le numéro « $numero ».\n'
                'Vérifiez le numéro de déclaration.';
    });
  }

  /// Une ligne choisie devient la fiche affichee par l'ecran de detail.
  Future<void> _ouvrirResultat(ExpeditionDetailModel exp) async {
    _controleur.selectedDetail.value = exp;
    await Get.to<void>(
      () => ExpeditionDetailScreen(
        idExpedition: exp.idExpedition ?? 0,
        dejaCharge: true,
      ),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 360),
    );
  }

  static OutlineInputBorder _bordure(Color couleur, [double epaisseur = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: couleur, width: epaisseur),
      );

  String _montant(num? v) =>
      '${NumberFormat('#,##0.00', 'fr_FR').format(v ?? 0)} DH';

  Widget _badgeTypeRemboursement(ExpeditionDetailModel exp) {
    final bool isVir = exp.aVirementCr;
    final String label =
        exp.typeRemboursementLibelle ?? (isVir ? 'Virement' : 'Chèque');

    final Color bg = isVir
        ? const Color(0xFF0EA5E9).withValues(alpha: 0.12)
        : const Color(0xFFA855F7).withValues(alpha: 0.12);
    final Color fg = isVir ? const Color(0xFF0284C7) : const Color(0xFF9333EA);
    final Color border = isVir
        ? const Color(0xFF0EA5E9).withValues(alpha: 0.28)
        : const Color(0xFFA855F7).withValues(alpha: 0.28);
    final IconData icon = isVir
        ? LucideIcons.arrowRightLeft
        : LucideIcons.wallet;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9.5, color: fg),
          const SizedBox(width: 3.5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _carteResultat(ExpeditionDetailModel exp) {
    // « E » = envoi, « R » = retour : c'est ce qui distingue les deux lignes
    // d'un meme numero, donc l'information passe en tete de carte.
    final estRetour = (exp.sens ?? '').toUpperCase().startsWith('R');

    return GlassContainer(
      onTap: () => _ouvrirResultat(exp),
      margin: const EdgeInsets.only(bottom: 10),
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (estRetour ? AppTheme.statusWarning : AppTheme.primary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  estRetour ? 'RETOUR' : 'ENVOI',
                  style: TextStyle(
                    color: estRetour
                        ? AppTheme.statusWarning
                        : AppTheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        exp.typeRemboursementLibelle ?? exp.nature ?? '—',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (exp.typeRemboursementLibelle != null) ...[
                      const SizedBox(width: 6),
                      _badgeTypeRemboursement(exp),
                    ],
                  ],
                ),
              ),
              const Icon(
                LucideIcons.chevronRight,
                size: 17,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                LucideIcons.mapPin,
                size: 13,
                color: AppTheme.primaryIcons,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${exp.origine ?? "—"} → ${exp.destination ?? "—"}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Dest. ${exp.destinataire ?? "—"}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                _montant(exp.mntTtc),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            [
              if ((exp.dateTaxation ?? '').isNotEmpty)
                'Taxée le ${exp.dateTaxation}',
              '${exp.colis ?? 0} colis',
              '${exp.poids ?? 0} kg',
              if ((exp.fond ?? 0) > 0) 'Fond ${_montant(exp.fond)}',
            ].join(' • '),
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 18, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.arrowLeft),
                  color: AppTheme.primary,
                  onPressed: () => Get.back<void>(),
                ),
                const Text(
                  'Tracking',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScrollReveal.grille(
                    index: 0,
                    child: GlassContainer(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.iconGradient,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: const Icon(
                                  LucideIcons.packageSearch,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 11),
                              const Expanded(
                                child: Text(
                                  'Suivre une expédition',
                                  style: TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 13),
                          TextField(
                            controller: _saisie,
                            focusNode: _focus,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.search,
                            autocorrect: false,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                            // Le numero est alphanumerique sans espaces : on evite
                            // les copier-coller qui trainent un espace et font
                            // repondre « introuvable » a un numero correct.
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'\s')),
                            ],
                            onSubmitted: (_) => _lancerRecherche(),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'N° de déclaration',
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0,
                              ),
                              prefixIcon: const Icon(
                                LucideIcons.search,
                                size: 18,
                                color: AppTheme.primary,
                              ),
                              suffixIcon: _saisie.text.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Effacer',
                                      icon: const Icon(
                                        LucideIcons.x,
                                        size: 16,
                                        color: Color(0xFF94A3B8),
                                      ),
                                      onPressed: () => setState(_saisie.clear),
                                    ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              border: _bordure(const Color(0xFFE2E8F0)),
                              enabledBorder: _bordure(const Color(0xFFE2E8F0)),
                              focusedBorder: _bordure(AppTheme.primary, 1.4),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GlassButton(
                            text: _recherche ? 'Recherche...' : 'Suivre',
                            icon: LucideIcons.search,
                            isLoading: _recherche,
                            height: 46,
                            onPressed: _recherche ? null : _lancerRecherche,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Resultats : une ligne par expedition. Un meme numero peut
                  // en porter deux (l'aller et le retour), d'ou la liste
                  // plutot qu'une ouverture directe.
                  Obx(() {
                    final resultats = _controleur.resultatsTracking;
                    if (resultats.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),
                        Text(
                          resultats.length > 1
                              ? '${resultats.length} expéditions trouvées'
                              : '1 expédition trouvée',
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Chaque resultat se revele a son tour.
                        ...resultats.indexed.map(
                          (e) => ScrollReveal(
                            index: e.$1,
                            child: _carteResultat(e.$2),
                          ),
                        ),
                      ],
                    );
                  }),
                  if (_introuvable != null) ...[
                    const SizedBox(height: 18),
                    GlassContainer(
                      borderRadius: 18,
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            LucideIcons.searchX,
                            color: Color(0xFFEF4444),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _introuvable!,
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
