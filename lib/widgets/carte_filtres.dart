import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

/// Couleur de voile du dialogue : assez claire pour que la page reste lisible
/// derriere le verre, sinon le flou n'a rien a montrer.
const Color voileFiltres = Color(0x470F172A);

/// Hauteur commune aux champs et aux boutons du bas : le dialogue garde un
/// rythme regulier quelle que soit la ligne.
const double _rayonCapsule = 24;

/// Libelle en petites capitales pose au-dessus d'un champ ou d'un groupe.
class LibelleFiltre extends StatelessWidget {
  const LibelleFiltre(this.texte, {super.key});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Text(
      texte.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF5A7086),
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.7,
      ),
    );
  }
}

/// Champ de saisie d'un dialogue de filtres : libelle au-dessus, icone en tete.
class ChampFiltre extends StatelessWidget {
  const ChampFiltre({
    super.key,
    required this.controleur,
    required this.libelle,
    required this.exemple,
    required this.icone,
    this.clavier,
  });

  final TextEditingController controleur;
  final String libelle;
  final String exemple;
  final IconData icone;
  final TextInputType? clavier;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder bordure(Color couleur, double epaisseur) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(_rayonCapsule),
          borderSide: BorderSide(color: couleur, width: epaisseur),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LibelleFiltre(libelle),
        const SizedBox(height: 9),
        TextField(
          controller: controleur,
          keyboardType: clavier,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: exemple,
            hintStyle: const TextStyle(
              color: Color(0xFF8FA3B8),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(icone, size: 19, color: AppTheme.primary),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 42,
              minHeight: 44,
            ),
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.fromLTRB(0, 15, 10, 15),
            enabledBorder: bordure(Colors.white, 1.2),
            focusedBorder: bordure(AppTheme.primary, 1.4),
          ),
        ),
      ],
    );
  }
}

/// Un choix d'un rail segmente (« Tous / Remis / Non remis »).
class ChoixSegment extends StatelessWidget {
  const ChoixSegment({
    super.key,
    required this.actif,
    required this.libelle,
    required this.onTap,
  });

  final bool actif;
  final String libelle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          gradient: actif ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: actif
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.30),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            libelle,
            style: TextStyle(
              color: actif ? Colors.white : const Color(0xFF42526A),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// Le rail qui porte les ChoixSegment, repartis a parts egales. Un mince filet
/// separe deux positions inactives voisines ; la capsule active s'en passe.
class RailSegments extends StatelessWidget {
  const RailSegments({super.key, required this.choix});

  final List<ChoixSegment> choix;

  @override
  Widget build(BuildContext context) {
    final enfants = <Widget>[];
    for (var i = 0; i < choix.length; i++) {
      if (i > 0) {
        final visible = !choix[i - 1].actif && !choix[i].actif;
        enfants.add(
          Container(
            width: 1,
            height: 22,
            color: visible ? const Color(0xFFC3D5E4) : Colors.transparent,
          ),
        );
      }
      enfants.add(Expanded(child: choix[i]));
    }

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(_rayonCapsule),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
      ),
      child: Row(children: enfants),
    );
  }
}

/// Coque en verre depoli d'un dialogue de filtres : en-tete, contenu, et les
/// deux boutons du bas. Partagee par les ecrans de liste pour qu'ils se
/// filtrent tous de la meme maniere.
class CarteFiltres extends StatelessWidget {
  const CarteFiltres({
    super.key,
    required this.titre,
    required this.contenu,
    required this.onReinitialiser,
    required this.onAppliquer,
  });

  final String titre;
  final List<Widget> contenu;
  final VoidCallback onReinitialiser;
  final VoidCallback onAppliquer;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFEAF6FE).withValues(alpha: 0.88),
                  const Color(0xFFD6ECFB).withValues(alpha: 0.72),
                ],
              ),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B3A5B).withValues(alpha: 0.22),
                  blurRadius: 34,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _enTete(),
                  const SizedBox(height: 22),
                  ...contenu,
                  const SizedBox(height: 24),
                  _boutons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _enTete() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.32),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(LucideIcons.filter, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          // Un titre long retrecit au lieu d'etre coupe : « Filtrer les
          // expeditions » ne tient pas a 22pt la ou « les retours » passe.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              titre,
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => Get.back<void>(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.x,
              size: 20,
              color: Color(0xFF33455C),
            ),
          ),
        ),
      ],
    );
  }

  Widget _boutons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: onReinitialiser,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_rayonCapsule),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.rotateCcw,
                    size: 18,
                    color: Color(0xFF42526A),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Réinitialiser',
                    style: TextStyle(
                      color: Color(0xFF42526A),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: onAppliquer,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(_rayonCapsule),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.34),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.checkCircle2,
                    size: 19,
                    color: Colors.white,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'Appliquer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
