import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../widgets/carte_liste.dart';
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

    // Meme mise en page que le detail de l'expedition : bandeau degrade a
    // coins arrondis, contenu pose par-dessus. Les six tableaux partagent
    // cette identite plutot qu'une couleur chacun.
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      body: Stack(
        children: [
          _entete(lignes.length),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 64),
              child: Column(
                children: [
                  if (avecFiltres)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < natures.length; i++) ...[
                              if (i > 0) const SizedBox(width: 9),
                              _puceFiltre(natures[i], natures[i]),
                            ],
                          ],
                        ),
                      ),
                    ),
                  Expanded(child: _corps(lignes)),
                ],
              ),
            ),
          ),
          // Le bouton de retour est pose au-dessus du contenu : dans le
          // bandeau il passerait sous la zone defilante.
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: SizedBox(
                height: 60,
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

  Widget _entete(int nombre) {
    // Une seule rangee : retour, titre du tableau, compteur.
    return Container(
      height: MediaQuery.paddingOf(context).top + 60,
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
          child: Row(
            children: [
              // Place reservee au bouton de retour, pose au-dessus du contenu.
              const SizedBox(width: 48, height: 48),
              Expanded(
                child: Text(
                  widget.titre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
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
                  '$nombre',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: actif ? AppTheme.primaryGradient : null,
          color: actif ? null : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: actif ? Colors.transparent : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: actif
                  ? AppTheme.primary.withValues(alpha: 0.30)
                  : const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          libelle,
          style: GoogleFonts.poppins(
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

  /// Libelle lisible de chaque etape datee ; une cle inconnue retombe sur
  /// `<Champ> le`.
  static const Map<String, String> _libelleEtape = {
    'date_encaissement': 'Encaissé le',
    'date_affectation': 'Affecté le',
    'date_reception': 'Reçu le',
    'date_remise': 'Remis le',
    'date_livraison': 'Livré le',
    'date_depot': 'Déposé le',
  };

  /// Une teinte par etape : la couleur suffit a reperer la date cherchee.
  static const Map<String, Color> _couleurEtape = {
    'date_encaissement': Color(0xFF10B981),
    'date_affectation': Color(0xFF6366F1),
    'date_reception': Color(0xFFF59E0B),
    'date_remise': Color(0xFFA855F7),
    'date_livraison': Color(0xFF0EA5E9),
    'date_depot': Color(0xFFEC4899),
  };

  /// Une etape datee : pastille de couleur, libelle teinte, date en gras.
  Widget _celluleDate(MapEntry<String, dynamic> date) {
    final libelle = _libelleEtape[date.key] ?? '${_libelleCourt(date.key)} le';
    final couleur = _couleurEtape[date.key] ?? const Color(0xFF64748B);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: couleur, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                libelle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: couleur,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  height: 1.3,
                ),
              ),
              Text(
                date.value.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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

    return CarteListe(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titre == null ? (nature ?? '—') : 'N° $titre',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
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
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    nature!,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          if (dates.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 9),
              child: Divider(height: 1, color: Color(0xFFEDF2F7)),
            ),
            // Deux etapes par ligne : les dates se lisent en colonnes
            // plutot qu'en phrase qui repasse a la ligne.
            for (var i = 0; i < dates.length; i += 2)
              Padding(
                padding: EdgeInsets.only(bottom: i + 2 < dates.length ? 6 : 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _celluleDate(dates[i])),
                    const SizedBox(width: 10),
                    Expanded(
                      child: i + 1 < dates.length
                          ? _celluleDate(dates[i + 1])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
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
    );
  }
}
