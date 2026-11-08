import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/notification_model.dart';
import '../screens/expeditions/expedition_detail_screen.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.find<NotificationController>();

  final Logger _logger = Logger();

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final isMarkingAll = false.obs;

  /// Filtre d'affichage : vrai = seulement les non lues
  final nonLuesSeulement = false.obs;

  /// Nombre de notifications non lues (status_notification == "1")
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// Liste filtrée selon le toggle "Non lues"
  List<NotificationModel> get listeAffichee => nonLuesSeulement.value
      ? notifications.where((n) => !n.isRead).toList()
      : notifications;

  @override
  void onInit() {
    super.onInit();
    // Si l'utilisateur est connecté, on charge immédiatement les notifications
    if (StorageService.hasToken()) {
      fetchNotifications(showLoading: true);
    }
  }

  /// Récupère la liste des notifications depuis le serveur
  Future<void> fetchNotifications({bool showLoading = false}) async {
    if (!StorageService.hasToken()) return;
    if (showLoading) isLoading.value = true;

    try {
      final response = await ApiService.getNotifications();
      final List<NotificationModel> chargees = [];

      dynamic rawList;
      if (response['data'] is List) {
        rawList = response['data'];
      } else if (response['notifications'] is List) {
        rawList = response['notifications'];
      } else if (response is List) {
        rawList = response;
      }

      if (rawList is List) {
        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            chargees.add(NotificationModel.fromJson(item));
          } else if (item is Map) {
            chargees.add(
              NotificationModel.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        }
      }

      notifications.value = chargees;
      _logger.i('🔔 [NOTIF] ${chargees.length} notifications chargées ($unreadCount non lues)');
    } catch (e) {
      _logger.w('⚠️ [NOTIF] Erreur lors du chargement des notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Marque une notification comme lue (status_notification: "2")
  Future<void> markAsRead(int idNotification) async {
    final index = notifications.indexWhere(
      (n) => n.idNotification == idNotification,
    );
    if (index == -1) return;

    final notif = notifications[index];
    if (notif.isRead) return;

    // Mise à jour optimiste dans l'interface
    notifications[index] = notif.copyWith(
      isRead: true,
      statusNotification: '2',
    );
    notifications.refresh();

    try {
      await ApiService.markNotificationAsRead(idNotification);
      _logger.d('✅ [NOTIF] Notification $idNotification marquée comme lue.');
    } catch (e) {
      _logger.w('⚠️ [NOTIF] Échec marquage comme lue pour $idNotification: $e');
    }
  }

  /// Marque toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    final unread = notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;

    isMarkingAll.value = true;

    // Mise à jour optimiste
    for (int i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = notifications[i].copyWith(
          isRead: true,
          statusNotification: '2',
        );
      }
    }
    notifications.refresh();

    try {
      await Future.wait(
        unread.map((n) => ApiService.markNotificationAsRead(n.idNotification)),
      );
      _logger.i('✅ [NOTIF] Toutes les notifications marquées comme lues.');
    } catch (e) {
      _logger.w('⚠️ [NOTIF] Erreur lors du marquage groupé: $e');
    } finally {
      isMarkingAll.value = false;
    }
  }

  /// Ouvre l'élément ciblé par la notification et la marque comme lue
  void handleNotificationClick(NotificationModel item) {
    markAsRead(item.idNotification);

    final root = item.root.trim();
    if (root.isEmpty) {
      _showDetailBottomSheet(item);
      return;
    }

    // Gestion du deep link / root (ex: /expedition/54656)
    if (root.toLowerCase().contains('/expedition/')) {
      final parts = root.split('/');
      final idStr = parts.lastWhere((p) => p.isNotEmpty, orElse: () => '');
      final expId = int.tryParse(idStr);
      if (expId != null) {
        Get.to<void>(
          () => ExpeditionDetailScreen(idExpedition: expId),
          transition: Transition.cupertino,
        );
        return;
      }
    }

    // Fallback : afficher la boîte de détail
    _showDetailBottomSheet(item);
  }

  /// Boîte de détail élégante si aucun écran spécifique n'est relié
  void _showDetailBottomSheet(NotificationModel item) {
    Get.bottomSheet<void>(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF29B7D9).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: Color(0xFF29B7D9),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title.isNotEmpty ? item.title : 'Notification',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              item.message,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF29B7D9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Get.back<void>(),
                child: const Text(
                  'Fermer',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
