import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../controllers/notification_controller.dart';
import '../../models/notification_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/barre_segments.dart';
import '../../widgets/scroll_reveal.dart';
import '../../widgets/vagues_background.dart';

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
        children: [
          // ─── FOND AVEC VAGUES AMBIANTES CYANS (STYLE METACLIENT) ────────
          const Positioned.fill(child: VaguesBackground()),

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
    final style = _resolveNotifStyle(item);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEDF6FD),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2B48).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => controller.handleNotificationClick(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône squircle aux coins arrondis
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: style.iconBg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: style.isDelivery
                        ? _buildFastDeliveryIcon(style.iconColor)
                        : Icon(
                            style.icon ?? LucideIcons.bell,
                            color: style.iconColor,
                            size: 24,
                          ),
                  ),
                ),
                const SizedBox(width: 14),

                // Contenu texte (Titre, Message + Chevron, Horodatage)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre + Point bleu non-lu
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              item.title.isNotEmpty ? item.title : 'Notification',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF0A1E3F),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8.5,
                              height: 8.5,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2B82DE),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Corps du message + flèche chevron à droite
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              item.message,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF334A68),
                                fontSize: 13.5,
                                height: 1.38,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            LucideIcons.chevronRight,
                            size: 20,
                            color: Color(0xFF2B82DE),
                          ),
                        ],
                      ),

                      // Ligne du bas : Date avec icône horloge
                      if (item.displayDate != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.clock,
                              size: 14,
                              color: Color(0xFF2B82DE),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(item.displayDate!),
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF334A68),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
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
  Widget _buildFastDeliveryIcon(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 7,
              height: 2,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(height: 2.5),
            Container(
              width: 11,
              height: 2,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(height: 2.5),
            Container(
              width: 6,
              height: 2,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
        const SizedBox(width: 2.5),
        Icon(
          Icons.local_shipping_rounded,
          size: 26,
          color: color,
        ),
      ],
    );
  }

  ({IconData? icon, Color iconColor, Color iconBg, bool isDelivery}) _resolveNotifStyle(
    NotificationModel item,
  ) {
    final title = item.title.toLowerCase();
    final body = item.message.toLowerCase();
    final root = item.root.toLowerCase();

    // Livraison / Expédition (exactement comme le mockup image 1 : camion bleu)
    if (root.contains('/expedition') ||
        title.contains('livraison') ||
        body.contains('livraison') ||
        body.contains('livrée') ||
        body.contains('expédition')) {
      return (
        icon: null,
        iconColor: const Color(0xFF1B64A7),
        iconBg: const Color(0xFFD6EEFD),
        isDelivery: true,
      );
    }
    // Facture
    if (title.contains('facture') || body.contains('facture')) {
      return (
        icon: LucideIcons.receipt,
        iconColor: const Color(0xFF4F46E5),
        iconBg: const Color(0xFFE0E7FF),
        isDelivery: false,
      );
    }
    // CRBT / Paiement
    if (title.contains('crbt') ||
        title.contains('paiement') ||
        title.contains('virement') ||
        title.contains('chèque')) {
      return (
        icon: LucideIcons.banknote,
        iconColor: const Color(0xFF0D9488),
        iconBg: const Color(0xFFCCFBF1),
        isDelivery: false,
      );
    }
    // Défaut
    return (
      icon: LucideIcons.bell,
      iconColor: const Color(0xFF1B64A7),
      iconBg: const Color(0xFFD6EEFD),
      isDelivery: false,
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(dt);
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day;

    if (isToday) {
      return 'Aujourd\'hui • $timeStr';
    } else if (isYesterday) {
      return 'Hier • $timeStr';
    } else {
      return '${DateFormat('dd/MM/yyyy').format(dt)} • $timeStr';
    }
  }
}

