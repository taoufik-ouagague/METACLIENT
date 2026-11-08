class NotificationModel {
  final int idNotification;
  final String statusNotification;
  final String root;
  final String title;
  final String message;
  final DateTime? date;
  final bool isRead;

  NotificationModel({
    required this.idNotification,
    required this.statusNotification,
    required this.root,
    required this.title,
    required this.message,
    this.date,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final status = (json['status_notification'] ?? '1').toString();
    final id = (json['id_notification'] is num)
        ? (json['id_notification'] as num).toInt()
        : int.tryParse(json['id_notification']?.toString() ?? '') ?? 0;

    DateTime? parsedDate;
    final dynamic rawDate =
        json['date'] ?? json['date_creation'] ?? json['created_at'];
    if (rawDate != null) {
      if (rawDate is String) {
        parsedDate = DateTime.tryParse(rawDate);
      } else if (rawDate is List && rawDate.length >= 3) {
        parsedDate = DateTime(
          rawDate[0] as int,
          rawDate[1] as int,
          rawDate[2] as int,
          rawDate.length > 3 ? rawDate[3] as int : 0,
          rawDate.length > 4 ? rawDate[4] as int : 0,
        );
      }
    }

    return NotificationModel(
      idNotification: id,
      statusNotification: status,
      root: (json['root'] ?? '').toString(),
      title: (json['title'] ?? json['titre'] ?? '').toString(),
      message: (json['message'] ?? json['corps'] ?? '').toString(),
      date: parsedDate,
      isRead: status == '2',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_notification': idNotification,
      'status_notification': statusNotification,
      'root': root,
      'title': title,
      'message': message,
      if (date != null) 'date': date!.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    int? idNotification,
    String? statusNotification,
    String? root,
    String? title,
    String? message,
    DateTime? date,
    bool? isRead,
  }) {
    return NotificationModel(
      idNotification: idNotification ?? this.idNotification,
      statusNotification: statusNotification ?? this.statusNotification,
      root: root ?? this.root,
      title: title ?? this.title,
      message: message ?? this.message,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
    );
  }
}
