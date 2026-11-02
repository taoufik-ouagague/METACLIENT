import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Une valeur « . », « 0 », « - » ou vide revient regulierement de l'API a la
/// place d'un null : elle n'apporte rien a l'ecran.
bool valeurRenseignee(Object? v) {
  final t = v?.toString().trim() ?? '';

  return t.isNotEmpty && t != '.' && t != '-' && t != 'null';
}

/// `date_encaissement` -> `Date encaissement`.
String libelleDepuisCle(String cle) {
  final mots = cle.replaceAll('_', ' ').trim();

  return mots.isEmpty ? cle : mots[0].toUpperCase() + mots.substring(1);
}

/// Carte « libelle / valeur » : sert a exposer les champs renvoyes par l'API
/// qui n'ont pas de place dediee dans l'ecran. Les lignes vides sont retirees,
/// et la carte disparait si tout est vide.
class InfoRowsCard extends StatelessWidget {
  const InfoRowsCard({
    super.key,
    required this.titre,
    required this.icone,
    required this.lignes,
    this.isLight = true,
  });

  final String titre;
  final IconData icone;
  final List<MapEntry<String, String?>> lignes;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final visibles = lignes.where((e) => valeurRenseignee(e.value)).toList();
    if (visibles.isEmpty) return const SizedBox.shrink();

    final couleurTitre = isLight ? const Color(0xFF0F172A) : Colors.white;
    final couleurLabel = isLight
        ? const Color(0xFF64748B)
        : Colors.white.withValues(alpha: 0.6);
    final couleurValeur = isLight
        ? const Color(0xFF0F172A)
        : Colors.white.withValues(alpha: 0.95);
    final couleurTrait = isLight
        ? const Color(0xFFE2E8F0)
        : Colors.white.withValues(alpha: 0.10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icone, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              titre,
              style: TextStyle(
                color: couleurTitre,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLight
                ? Colors.white
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: couleurTrait),
          ),
          child: Column(
            children: [
              for (var i = 0; i < visibles.length; i++) ...[
                if (i > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: couleurTrait, height: 1),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        visibles[i].key,
                        style: TextStyle(color: couleurLabel, fontSize: 12.5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        visibles[i].value!,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: couleurValeur,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
