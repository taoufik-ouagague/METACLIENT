import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/info_rows_card.dart';

/// Un tableau de l'expedition en pleine page.
///
/// `items` porte les lignes brutes renvoyees par l'API : quand elles ont
/// plusieurs `nature` differentes, la page propose les filtres correspondants.
/// `contenu` sert aux tableaux deja mis en forme ailleurs (timeline, GED,
/// commentaires), qui n'ont rien a filtrer.
class TableExpeditionScreen extends StatefulWidget {
  const TableExpeditionScreen({
    super.key,
    required this.titre,
    required this.icone,
    required this.couleur,
    this.items,
    this.contenu,
    this.naturesAttendues = const [],
  });

  final String titre;
  final IconData icone;
  final Color couleur;
  final List<Map<String, dynamic>>? items;
  final List<Widget> Function()? contenu;

  /// Natures prevues par le contrat API, meme absentes des donnees du moment :
  /// les filtres restent proposes, et un filtre sans resultat le dit.
  final List<String> naturesAttendues;

  @override
  State<TableExpeditionScreen> createState() => _TableExpeditionScreenState();
}

class _TableExpeditionScreenState extends State<TableExpeditionScreen> {
  static const String _sansNature = 'Autres';

  /// null = toutes les natures.
  String? _nature;

  @override
  void initState() {
    super.initState();
    // On ouvre sur la premiere nature du contrat plutot que sur « Tous » :
    // c'est celle qu'on vient consulter.
    final natures = _natures;
    if (natures.isNotEmpty) _nature = natures.first;
  }

  /// Natures proposees au filtre : celles annoncees par le contrat, puis
  /// celles reellement presentes que le contrat n'aurait pas prevues.
  List<String> get _natures {
    final vues = <String>[...widget.naturesAttendues];
    var sansNature = false;
    for (final item in widget.items ?? const <Map<String, dynamic>>[]) {
      final n = item['nature']?.toString().trim();
      if (n == null || n.isEmpty) {
        sansNature = true;
      } else if (!vues.contains(n)) {
        vues.add(n);
      }
    }
    // Il n'y a plus de « Tous » : sans cette puce, une ligne dont l'API
    // n'envoie pas la nature ne serait jamais affichee.
    if (sansNature) vues.add(_sansNature);

    return vues;
  }

  List<Map<String, dynamic>> get _lignes {
    final tous = widget.items ?? const <Map<String, dynamic>>[];
    if (_nature == null) return tous;

    if (_nature == _sansNature) {
      return tous
          .where((e) => (e['nature']?.toString().trim() ?? '').isEmpty)
          .toList();
    }

    return tous.where((e) => e['nature']?.toString() == _nature).toList();
  }

  String _montant(num? v) =>
      '${NumberFormat('#,##0.00', 'fr_FR').format(v ?? 0)} DH';

  @override
  Widget build(BuildContext context) {
    final natures = _natures;
    final avecFiltres = _avecFiltres;
    final lignes = _lignes;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        // Barre teintee : chaque tableau garde sa couleur jusque dans son
        // en-tete, et les icones systeme passent en clair pour rester lisibles.
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(widget.couleur, Colors.black, 0.22)!,
                widget.couleur,
                Color.lerp(widget.couleur, Colors.white, 0.18)!,
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Get.back<void>(),
        ),
        titleSpacing: 0,
        title: Text(
          widget.titre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.1,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  '${lignes.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (avecFiltres)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 2),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < natures.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      _puceFiltre(natures[i], natures[i]),
                    ],
                  ],
                ),
              ),
            ),
          Expanded(child: _corps(lignes)),
        ],
      ),
    );
  }

  /// Une seule nature : pas de barre de filtres, donc la fiche l'affiche.
  bool get _avecFiltres => _natures.length > 1;

  Widget _corps(List<Map<String, dynamic>> lignes) {
    if (widget.items == null) {
      final contenu = widget.contenu?.call() ?? const <Widget>[];

      return contenu.isEmpty
          ? _vide()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: contenu,
            );
    }

    if (lignes.isEmpty) return _vide();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      itemCount: lignes.length,
      itemBuilder: (_, i) => _fiche(lignes[i], montrerNature: !_avecFiltres),
    );
  }

  Widget _vide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icone,
              size: 32,
              color: widget.couleur.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 12),
            Text(
              _nature == null
                  ? 'Aucun élément'
                  : 'Aucun élément pour « $_nature »',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _puceFiltre(String libelle, String? valeur) {
    final actif = _nature == valeur;

    return GestureDetector(
      onTap: () => setState(() => _nature = valeur),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: actif ? widget.couleur : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: actif ? widget.couleur : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          libelle,
          style: TextStyle(
            color: actif ? Colors.white : const Color(0xFF475569),
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  /// Vrai pour « 11/09/2026 » : sert a regrouper les dates sans dependre du
  /// nom des champs, donc une date ajoutee cote serveur se range toute seule.
  static final RegExp _formatDate = RegExp(r'^\d{2}/\d{2}/\d{4}$');

  /// « Date encaissement » -> « Encaissement ».
  String _libelleCourt(String cle) {
    final l = libelleDepuisCle(cle).replaceFirst(RegExp('^Date '), '');

    return l.isEmpty ? cle : l[0].toUpperCase() + l.substring(1);
  }

  /// Carte de liste reprise de META FLEET mobile : verre blanc, bande de
  /// couleur de 4 px a gauche, rayon 18. Compacte — trois lignes au plus.
  Widget _fiche(Map<String, dynamic> item, {required bool montrerNature}) {
    const promus = {'nature', 'fond', 'montant'};
    final nature = montrerNature ? item['nature']?.toString() : null;
    final montant = item['fond'] ?? item['montant'];

    final restantes = item.entries
        .where((e) => !promus.contains(e.key) && valeurRenseignee(e.value))
        .toList();
    final dates = restantes
        .where((e) => _formatDate.hasMatch(e.value.toString().trim()))
        .toList();
    final autres = restantes
        .where((e) => !_formatDate.hasMatch(e.value.toString().trim()))
        .toList();

    // Le premier champ non date identifie la ligne (n° de piece, bordereau...).
    final titre = autres.isNotEmpty ? autres.first.value.toString() : null;
    final suite = autres.skip(1).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.couleur.withValues(alpha: 0.45),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F3A5F).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            titre ?? (nature ?? '—'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: widget.couleur,
                            ),
                          ),
                        ),
                        if (montant is num)
                          Text(
                            _montant(montant),
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          )
                        else if (valeurRenseignee(nature))
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: widget.couleur.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              nature!,
                              style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: widget.couleur,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (dates.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Icon(
                              LucideIcons.calendar,
                              size: 12,
                              color: widget.couleur.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              dates
                                  .map(
                                    (d) => '${_libelleCourt(d.key)} ${d.value}',
                                  )
                                  .join('  •  '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11.5,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (suite.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        suite
                            .map(
                              (e) =>
                                  '${_libelleCourt(e.key)} ${e.value is num ? _montant(e.value as num) : e.value}',
                            )
                            .join('  •  '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Bande laterale : posee dans le ClipRRect, un Border non uniforme
            // ne cohabite pas avec un borderRadius.
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: widget.couleur),
            ),
          ],
        ),
      ),
    );
  }
}
