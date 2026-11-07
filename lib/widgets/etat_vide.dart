import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Etat vide d'une liste, tirable vers le bas. Un Center nu laisserait la page
/// bloquee sur zero : sans zone defilante le geste de rafraichissement ne part
/// pas, et l'ecran n'offre plus aucun moyen de recharger.
class EtatVideRafraichissable extends StatelessWidget {
  const EtatVideRafraichissable({
    super.key,
    required this.icone,
    required this.message,
    required this.onRefresh,
  });

  final IconData icone;
  final String message;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.primary,
      backgroundColor: Colors.white,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.55,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icone, color: const Color(0xFFCBD5E1), size: 48),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
