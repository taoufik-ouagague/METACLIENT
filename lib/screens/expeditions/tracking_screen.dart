import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/expedition_controller.dart';
import '../../models/expedition_detail_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/scroll_reveal.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/vagues_background.dart';
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

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    final btn = Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
          width: 1.1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Icon(icon, color: Colors.white, size: 17),
        ),
      ),
    );

    return tooltip != null ? Tooltip(message: tooltip, child: btn) : btn;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final headerHeight = topPadding + 64;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFD),
        body: Stack(
          children: [
            // ─── FOND AVEC VAGUES AMBIANTES CYANS (STYLE METACLIENT) ────────
            const Positioned.fill(child: VaguesBackground()),

            // ─── CONTENU DÉFILABLE ──────────────────────────────────────────
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(18, headerHeight + 16, 18, 28),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScrollReveal.grille(
                      index: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              Color(0xFFF2F8FC),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F2B48).withValues(alpha: 0.07),
                              blurRadius: 22,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.06),
                              blurRadius: 30,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.iconGradient,
                                          borderRadius: BorderRadius.circular(13),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.primaryIcons.withValues(alpha: 0.35),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            LucideIcons.packageSearch,
                                            color: Colors.white,
                                            size: 21,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 13),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Suivre une expédition',
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF0F172A),
                                                fontSize: 15.5,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.1,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Numéro de déclaration ou code-barres',
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF64748B),
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      controller: _saisie,
                                      focusNode: _focus,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.search,
                                      autocorrect: false,
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF0F172A),
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                                      ],
                                      onSubmitted: (_) => _lancerRecherche(),
                                      onChanged: (_) => setState(() {}),
                                      decoration: InputDecoration(
                                        hintText: 'N° de déclaration',
                                        hintStyle: GoogleFonts.poppins(
                                          color: const Color(0xFF94A3B8),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0,
                                        ),
                                        prefixIcon: const Icon(
                                          LucideIcons.search,
                                          size: 19,
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
                                        fillColor: Colors.white,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Container(
                                    width: double.infinity,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color(0xFF2193B0),
                                          Color(0xFF38BDF8),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF2193B0).withValues(alpha: 0.36),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(15),
                                        onTap: _recherche ? null : _lancerRecherche,
                                        child: Center(
                                          child: _recherche
                                              ? const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      LucideIcons.search,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Suivre',
                                                      style: GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontSize: 15.5,
                                                        fontWeight: FontWeight.w700,
                                                        letterSpacing: 0.3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Resultats : une ligne par expedition. Un meme numero peut
                    // en porter deux (l'aller et le retour), d'ou la liste
                    // plutot qu'une ouverture directe.
                    Obx(() {
                      final resultats = _controleur.resultatsTracking;
                      if (resultats.isNotEmpty) {
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
                      }

                      if (_introuvable != null) {
                        return const SizedBox.shrink();
                      }

                      // État vide initial avec illustration 3D
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 24),
                          child: Image.asset(
                            'assets/img/tracking_3d_box.png',
                            width: 320,
                            fit: BoxFit.contain,
                          ),
                        ),
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

            // ─── BANDEAU SUPÉRIEUR DÉGRADÉ (STYLE METACLIENT) ────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: headerHeight,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF29B7D9),
                      AppTheme.primary,
                      Color(0xFF3FC1D8),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.20),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
                    child: Row(
                      children: [
                        _buildNavButton(
                          icon: LucideIcons.arrowLeft,
                          onTap: () => Get.back<void>(),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Tracking',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
