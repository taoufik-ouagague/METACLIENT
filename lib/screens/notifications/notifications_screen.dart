import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../theme/app_theme.dart';
import '../../widgets/carte_liste.dart';
import '../../widgets/scroll_reveal.dart';

/// Les notifications du client.
///
/// L'API n'en expose pas encore : l'ecran existe pour que le point d'entree
/// soit en place et affiche un etat vide plutot que rien.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Meme mise en page que les autres ecrans : bandeau degrade, contenu pose
    // dessous.
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.paddingOf(context).top + 60,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1B7A94),
                  AppTheme.primary,
                  Color(0xFF3FC1D8),
                ],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: SafeArea(
              bottom: false,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(6, 0, 18, 0),
                child: Row(
                  children: [
                    // Place reservee au bouton de retour, pose au-dessus.
                    SizedBox(width: 48, height: 48),
                    Expanded(
                      child: Text(
                        'Notifications',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 78, 18, 24),
              child: Center(
                child: ScrollReveal.grille(
                  index: 0,
                  child: CarteListe(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 32,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.bellOff,
                          size: 34,
                          color: AppTheme.primary.withValues(alpha: 0.45),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Aucune notification',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
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
}
