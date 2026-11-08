import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../controllers/notification_controller.dart';
import '../../models/notification_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/barre_segments.dart';
import '../../widgets/carte_liste.dart';
import '../../widgets/scroll_reveal.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();

    // Rafraîchir à l'ouverture de l'écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchNotifications(showLoading: controller.notifications.isEmpty);
    });

    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFD),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ─── FOND AVEC VAGUES AMBIANTES CYANS (STYLE METACLIENT) ────────
          _buildBackground(context),

          // ─── BANDEAU SUPÉRIEUR DÉGRADÉ (STYLE METACLIENT) ────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPadding + 124,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF29B7D9),
                    AppTheme.primary,
                    Color(0xFF3FC1D8),
                  ],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
                  child: Column(
                    children: [
                      // Barre de navigation (Retour, Titre)
                      Row(
                        children: [
                          _buildNavButton(
                            icon: LucideIcons.arrowLeft,
                            onTap: () => Get.back<void>(),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Notifications',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Filtres : Toutes / Non lues
                      _buildFilterTabs(controller),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── LISTE DES NOTIFICATIONS ──────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(top: topPadding + 130),
            child: Obx(() {
              if (controller.isLoading.value && controller.notifications.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                );
              }

              final list = controller.listeAffichee;

              if (list.isEmpty) {
                return _buildEmptyState(controller);
              }

              return RefreshIndicator(
                color: AppTheme.primary,
                backgroundColor: Colors.white,
                onRefresh: () => controller.fetchNotifications(showLoading: false),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemCount: list.length,
                  separatorBuilder: (ctx, idx) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return ScrollReveal(
                      index: index,
                      child: _buildNotificationCard(context, controller, item),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── BOUTON DE NAVIGATION TRANSPARENT BLUR ─────────────────────────────────
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

    return tooltip != null
        ? Tooltip(message: tooltip, child: btn)
        : btn;
  }

  // ─── ONGLETS DE FILTRE (TOUTES / NON LUES - MÊME STYLE QUE EN COURS / TOUTES) ───
  Widget _buildFilterTabs(NotificationController controller) {
    return Obx(() {
      final total = controller.notifications.length;
      final unread = controller.unreadCount;

      return Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: BarreSegments(
          libelles: [
            'Toutes ($total)',
            'Non lues ($unread)',
          ],
          index: controller.nonLuesSeulement.value ? 1 : 0,
          onChange: (i) => controller.nonLuesSeulement.value = (i == 1),
          tailleTexte: 13,
        ),
      );
    });
  }

  // ─── CARTE DE NOTIFICATION ─────────────────────────────────────────────────
  Widget _buildNotificationCard(
    BuildContext context,
    NotificationController controller,
    NotificationModel item,
  ) {
    final isUnread = !item.isRead;
    final iconData = _resolveIcon(item);
    final accentColor = _resolveAccentColor(item);
    final hasRoot = item.root.trim().isNotEmpty;

    return CarteListe(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      onTap: () => controller.handleNotificationClick(item),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône stylisée avec halo doux
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withValues(alpha: isUnread ? 0.20 : 0.10),
                  accentColor.withValues(alpha: isUnread ? 0.10 : 0.04),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor.withValues(alpha: isUnread ? 0.40 : 0.20),
                width: 1.2,
              ),
            ),
            child: Icon(
              iconData,
              color: accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Contenu texte (Titre, Message, Date, Badge)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre + Indicateur de statut
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title.isNotEmpty ? item.title : 'Notification',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isUnread)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF29B7D9).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF29B7D9).withValues(alpha: 0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          'Non vue',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF0284C7),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      Icon(
                        LucideIcons.check,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                  ],
                ),
                const SizedBox(height: 5),

                // Corps du message
                Text(
                  item.message,
                  style: GoogleFonts.poppins(
                    color: isUnread ? const Color(0xFF334155) : const Color(0xFF64748B),
                    fontSize: 12.5,
                    height: 1.42,
                    fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 8),

                // Ligne du bas : Date & Lien d'accès
                Row(
                  children: [
                    if (item.date != null) ...[
                      Icon(
                        LucideIcons.clock,
                        size: 11,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(item.date!),
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                    ] else
                      const Spacer(),

                    if (hasRoot)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Consulter',
                            style: GoogleFonts.poppins(
                              color: AppTheme.primary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            LucideIcons.chevronRight,
                            size: 13,
                            color: AppTheme.primary,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── FOND AVEC LES VAGUES ORGANIQUES EXACTES DU MOCKUP ────────────────────
  Widget _buildBackground(BuildContext context) {
    return const RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFF7FAFD),
        ),
        child: CustomPaint(
          painter: _VaguesMockupPainter(),
        ),
      ),
    );
  }

  // ─── ÉTAT VIDE (IDENTIQUE AU MOCKUP) ───────────────────────────────────────
  Widget _buildEmptyState(NotificationController controller) {
    return RefreshIndicator(
      color: AppTheme.primary,
      backgroundColor: Colors.white,
      onRefresh: () => controller.fetchNotifications(showLoading: false),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/img/empty_notification_3d.png',
                        width: 200,
                        height: 195,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Vous n\'avez aucune notification\npour le moment.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF384964),
                          fontSize: 15,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── UTILS DE STYLING DES NOTIFICATIONS ────────────────────────────────────
  IconData _resolveIcon(NotificationModel item) {
    final title = item.title.toLowerCase();
    final body = item.message.toLowerCase();
    final root = item.root.toLowerCase();

    if (root.contains('/expedition') ||
        title.contains('livraison') ||
        body.contains('livrée') ||
        body.contains('expédition')) {
      return LucideIcons.package;
    }
    if (title.contains('facture') || body.contains('facture')) {
      return LucideIcons.receipt;
    }
    if (title.contains('crbt') ||
        title.contains('paiement') ||
        title.contains('virement') ||
        title.contains('chèque')) {
      return LucideIcons.banknote;
    }
    return LucideIcons.bell;
  }

  Color _resolveAccentColor(NotificationModel item) {
    final title = item.title.toLowerCase();
    final body = item.message.toLowerCase();
    final root = item.root.toLowerCase();

    if (root.contains('/expedition') ||
        title.contains('livraison') ||
        body.contains('expédition')) {
      return const Color(0xFF0284C7); // Cyan / Sky Blue
    }
    if (title.contains('facture')) {
      return const Color(0xFF6366F1); // Indigo
    }
    if (title.contains('crbt') || title.contains('paiement')) {
      return const Color(0xFF10B981); // Emerald
    }
    return const Color(0xFFF59E0B); // Amber / Orange
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24 && dt.day == now.day) {
      return 'Aujourd\'hui à ${DateFormat('HH:mm').format(dt)}';
    }
    if (diff.inDays == 1 || (diff.inHours < 48 && dt.day == now.day - 1)) {
      return 'Hier à ${DateFormat('HH:mm').format(dt)}';
    }
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }
}

/// Peintre personnalisé pour reproduire exactement les vagues organiques du mockup
class _VaguesMockupPainter extends CustomPainter {
  const _VaguesMockupPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final wavePaint1 = Paint()
      ..color = const Color(0xFFE2F3FD)
      ..style = PaintingStyle.fill;

    final wavePaint2 = Paint()
      ..color = const Color(0xFFD8EFFC)
      ..style = PaintingStyle.fill;

    // 1. Vague en haut à droite (Top-right wave)
    final pathTopRight = Path()
      ..moveTo(w, h * 0.19)
      ..cubicTo(w * 0.68, h * 0.22, w * 0.64, h * 0.29, w, h * 0.33)
      ..close();
    canvas.drawPath(pathTopRight, wavePaint1);

    // 2. Vague en bas à gauche (Bottom-left wave)
    final pathBottomLeft = Path()
      ..moveTo(0, h * 0.74)
      ..cubicTo(w * 0.34, h * 0.77, w * 0.38, h * 0.88, 0, h * 0.94)
      ..close();
    canvas.drawPath(pathBottomLeft, wavePaint1);

    // 3. Vague en bas à droite (Bottom-right wave)
    final pathBottomRight = Path()
      ..moveTo(w * 0.38, h)
      ..cubicTo(w * 0.58, h * 0.86, w * 0.80, h * 0.88, w, h * 0.81)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(pathBottomRight, wavePaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
