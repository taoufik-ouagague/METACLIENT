class NotificationModel {
  final int idNotification;
  final String statusNotification;
  final String root;
  final String title;
  final String message;
  final DateTime? date;
  final DateTime? dateAction;
  final bool isRead;

  NotificationModel({
    required this.idNotification,
    required this.statusNotification,
    required this.root,
    required this.title,
    required this.message,
    this.date,
    this.dateAction,
    this.isRead = false,
  });

  /// Date d'affichage (priorité à dateAction, puis date)
  DateTime? get displayDate => dateAction ?? date;

  static DateTime? _parseDateTime(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;

    // Timestamp numérique (en millisecondes ou secondes)
    if (raw is num) {
      final intVal = raw.toInt();
      if (intVal > 100000000000) {
        return DateTime.fromMillisecondsSinceEpoch(intVal);
      } else if (intVal > 0) {
        return DateTime.fromMillisecondsSinceEpoch(intVal * 1000);
      }
      return null;
    }

    // Chaîne de caractères
    if (raw is String) {
      final str = raw.trim();
      if (str.isEmpty || str == 'null') return null;

      // Timestamp numérique sous forme de string (ex: "1731075600000")
      final numParsed = int.tryParse(str);
      if (numParsed != null && numParsed > 100000000) {
        return _parseDateTime(numParsed);
      }

      // Format ISO-8601 (ex: "2026-11-08T14:19:14.000Z")
      final iso = DateTime.tryParse(str);
      if (iso != null) {
        return iso.isUtc ? iso.toLocal() : iso;
      }

      // Format SQL classique (ex: "2026-11-08 14:19:14")
      final sqlTry = DateTime.tryParse(str.replaceAll(' ', 'T'));
      if (sqlTry != null) {
        return sqlTry.isUtc ? sqlTry.toLocal() : sqlTry;
      }

      // Format français (ex: "08/11/2026 14:19:14" ou "08/11/2026")
      try {
        if (str.contains('/')) {
          final parts = str.split(' ');
          final dateParts = parts[0].split('/');
          if (dateParts.length == 3) {
            final day = int.parse(dateParts[0]);
            final month = int.parse(dateParts[1]);
            final year = int.parse(dateParts[2]);
            int hour = 0, minute = 0, second = 0;
            if (parts.length > 1) {
              final timeParts = parts[1].split(':');
              if (timeParts.isNotEmpty) hour = int.parse(timeParts[0]);
              if (timeParts.length > 1) minute = int.parse(timeParts[1]);
              if (timeParts.length > 2) second = int.parse(timeParts[2].split('.')[0]);
            }
            return DateTime(year, month, day, hour, minute, second);
          }
        }
      } catch (_) {}
    }

    // Format tableau Java Jackson [year, month, day, hour, min, sec]
    if (raw is List && raw.length >= 3) {
      try {
        return DateTime(
          raw[0] as int,
          raw[1] as int,
          raw[2] as int,
          raw.length > 3 ? raw[3] as int : 0,
          raw.length > 4 ? raw[4] as int : 0,
          raw.length > 5 ? raw[5] as int : 0,
        );
      } catch (_) {}
    }

    return null;
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final status = (json['status_notification'] ?? '1').toString();
    final id = (json['id_notification'] is num)
        ? (json['id_notification'] as num).toInt()
        : int.tryParse(json['id_notification']?.toString() ?? '') ?? 0;

    final parsedDateAction = _parseDateTime(
      json['dateAction'] ??
          json['date_action'] ??
          json['dateActionTimestamp'] ??
          json['timestamp'],
    );

    final parsedDate = parsedDateAction ??
        _parseDateTime(
          json['date'] ?? json['date_creation'] ?? json['created_at'],
        );

    return NotificationModel(
      idNotification: id,
      statusNotification: status,
      root: (json['root'] ?? '').toString(),
      title: (json['title'] ?? json['titre'] ?? '').toString(),
      message: (json['message'] ?? json['corps'] ?? '').toString(),
      date: parsedDate,
      dateAction: parsedDateAction,
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
      if (dateAction != null) 'dateAction': dateAction!.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    int? idNotification,
    String? statusNotification,
    String? root,
    String? title,
    String? message,
    DateTime? date,
    DateTime? dateAction,
    bool? isRead,
  }) {
    return NotificationModel(
      idNotification: idNotification ?? this.idNotification,
      statusNotification: statusNotification ?? this.statusNotification,
      root: root ?? this.root,
      title: title ?? this.title,
      message: message ?? this.message,
      date: date ?? this.date,
      dateAction: dateAction ?? this.dateAction,
      isRead: isRead ?? this.isRead,
    );
  }
}
