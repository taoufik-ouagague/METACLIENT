import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

/// Couleur de voile du dialogue : assez claire pour que la page reste lisible
/// derriere le verre, sinon le flou n'a rien a montrer.
const Color voileFiltres = Color(0x470F172A);

/// Libelle en petites capitales pose au-dessus d'un champ ou d'un groupe.
class LibelleFiltre extends StatelessWidget {
  const LibelleFiltre(this.texte, {super.key});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Text(
      texte,
      style: const TextStyle(
        color: Color(0xFF4A5A6E),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
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
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: couleur, width: epaisseur),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LibelleFiltre(libelle),
        const SizedBox(height: 5),
        TextField(
          controller: controleur,
          keyboardType: clavier,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: exemple,
            hintStyle: const TextStyle(
              color: Color(0xFF8FA3B8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(icone, size: 16, color: AppTheme.primary),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            isDense: true,
            filled: true,
            // Translucide : le fond de la page transparait a travers le champ.
            fillColor: Colors.white.withValues(alpha: 0.42),
            contentPadding: const EdgeInsets.fromLTRB(0, 11, 12, 11),
            enabledBorder: bordure(Colors.white.withValues(alpha: 0.75), 1.2),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          gradient: actif ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(11),
          boxShadow: actif
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            libelle,
            style: TextStyle(
              color: actif ? Colors.white : const Color(0xFF42526A),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// Le rail qui porte les ChoixSegment, repartis a parts egales.
class RailSegments extends StatelessWidget {
  const RailSegments({super.key, required this.choix});

  final List<Widget> choix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
      ),
      child: Row(children: [for (final c in choix) Expanded(child: c)]),
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.74),
                  Colors.white.withValues(alpha: 0.52),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
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
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _enTete(),
                  const SizedBox(height: 14),
                  ...contenu,
                  const SizedBox(height: 20),
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
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.32),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(LucideIcons.filter, color: Colors.white, size: 17),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            titre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(LucideIcons.x, size: 18, color: Color(0xFF6B7C91)),
          onPressed: () => Get.back<void>(),
        ),
      ],
    );
  }

  Widget _boutons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              backgroundColor: Colors.white.withValues(alpha: 0.42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.8)),
              ),
            ),
            onPressed: onReinitialiser,
            child: const Text(
              'Réinitialiser',
              style: TextStyle(
                color: Color(0xFF42526A),
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: onAppliquer,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.34),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Appliquer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
