import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/agence_controller.dart';
import '../../models/agence_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/carte_accent.dart';
import '../../widgets/scroll_reveal.dart';

class AgencesScreen extends StatelessWidget {
  const AgencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AgenceController>();

    return Column(
      children: [
        // ─── RECHERCHE PAR NOM OU CODE ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
          child: Obx(
            () => Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 14, right: 8),
                    child: Icon(
                      LucideIcons.search,
                      color: AppTheme.primary,
                      size: 18,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      // Le controleur suit l'etat : la croix doit pouvoir vider
                      // le champ depuis l'exterieur.
                      controller:
                          TextEditingController(text: ctrl.recherche.value)
                            ..selection = TextSelection.collapsed(
                              offset: ctrl.recherche.value.length,
                            ),
                      onChanged: (v) => ctrl.recherche.value = v,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 13.5,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Nom ou code d\'agence…',
                        hintStyle: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  if (ctrl.recherche.value.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        LucideIcons.x,
                        color: Color(0xFF94A3B8),
                        size: 16,
                      ),
                      onPressed: () => ctrl.recherche.value = '',
                    ),
                ],
              ),
            ),
          ),
        ),

        // ─── NOMBRE D'AGENCES ──────────────────────────────────────────────
        Obx(
          () => Padding(
            padding: const EdgeInsets.fromLTRB(18, 2, 18, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.95),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.building2,
                      size: 13,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${ctrl.agencesAffichees.length}',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ctrl.agencesAffichees.length > 1 ? 'agences' : 'agence',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ─── LISTE ─────────────────────────────────────────────────────────
        Expanded(
          child: Obx(() {
            if (ctrl.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }

            final liste = ctrl.agencesAffichees;
            if (liste.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.mapPin,
                      color: Color(0xFFCBD5E1),
                      size: 48,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Aucune agence trouvée',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: Colors.white,
              onRefresh: ctrl.fetchAgences,
              child: ListView.separated(
                // Un padding explicite ecrase celui que le Scaffold reserve
                // pour la barre flottante : on le reprend ici, sinon la
                // derniere ligne reste cachee dessous.
                padding: EdgeInsets.fromLTRB(
                  18,
                  8,
                  18,
                  8 + MediaQuery.paddingOf(context).bottom,
                ),
                itemCount: liste.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) =>
                    ScrollReveal(index: i, child: _carteAgence(ctrl, liste[i])),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Teintes de la liste, dans l'ordre ou elles reviennent.
  static const List<Color> _palette = [
    Color(0xFF0284C7),
    Color(0xFF0D9488),
    Color(0xFF7C3AED),
    Color(0xFFD97706),
    Color(0xFFE11D48),
    Color(0xFF4F46E5),
  ];

  /// Couleur d'une agence, tiree de son code.
  ///
  /// Stable d'un lancement a l'autre (le code est numerique), contrairement a
  /// un hashCode de chaine : une agence garde sa couleur, et le client finit
  /// par la reconnaitre.
  static Color _teinte(String code) {
    final n =
        int.tryParse(code) ??
        code.codeUnits.fold<int>(0, (somme, c) => somme + c);
    return _palette[n.abs() % _palette.length];
  }

  Widget _carteAgence(AgenceController ctrl, AgenceModel agence) {
    return Obx(() {
      final ouvert = ctrl.deplies.contains(agence.code);
      final teinte = _teinte(agence.code);

      return CarteAccent(
        teinte: teinte,
        icone: LucideIcons.building2,
        onTap: () => ctrl.basculer(agence.code),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(19, 15, 15, 15),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: teinte.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: teinte.withValues(alpha: 0.22)),
                    ),
                    child: Icon(LucideIcons.building2, color: teinte, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      agence.libelle,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: teinte.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      agence.code,
                      style: TextStyle(
                        color: teinte,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: ouvert ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      LucideIcons.chevronDown,
                      size: 17,
                      color: teinte.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            // Repli par defaut : la liste se parcourt d'un coup d'oeil, le
            // detail ne s'ouvre que sur demande.
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 240),
              sizeCurve: Curves.easeOutCubic,
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(19, 0, 15, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(height: 1, color: teinte.withValues(alpha: 0.14)),
                    const SizedBox(height: 10),
                    _ligneInfo(
                      LucideIcons.mapPin,
                      'Adresse',
                      agence.adresseBrute,
                      const Color(0xFF0284C7),
                    ),
                    _ligneInfo(
                      LucideIcons.phone,
                      'Téléphone',
                      agence.telephoneBrut,
                      const Color(0xFF059669),
                    ),
                    _ligneInfo(
                      LucideIcons.hash,
                      'CPK',
                      agence.cpk?.toString(),
                      const Color(0xFF7C3AED),
                    ),
                    _ligneInfo(
                      LucideIcons.navigation,
                      'Coordonnées',
                      '${agence.latitude ?? 0} , ${agence.longitude ?? 0}',
                      const Color(0xFFD97706),
                    ),
                  ],
                ),
              ),
              crossFadeState: ouvert
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),
          ],
        ),
      );
    });
  }

  Widget _ligneInfo(
    IconData icone,
    String intitule,
    String? valeur,
    Color couleur,
  ) {
    final v = (valeur ?? '').trim();
    final vide = v.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: couleur.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icone, size: 12, color: couleur),
          ),
          const SizedBox(width: 9),
          SizedBox(
            // « Coordonnees » est le plus long des intitules : en dessous, la
            // valeur venait coller le libelle.
            width: 92,
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                intitule,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                vide ? '—' : v,
                style: TextStyle(
                  color: vide ? const Color(0xFFB4C0CF) : couleur,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
