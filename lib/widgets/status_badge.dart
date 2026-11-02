import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({super.key, required this.status, this.fontSize = 11.5});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    final s = status.toLowerCase().trim();

    if (s.contains('cloture') ||
        s.contains('livr') ||
        s.contains('notifie') ||
        s.contains('pay')) {
      bg = AppTheme.statusSuccess.withValues(alpha: 0.18);
      fg = AppTheme.statusSuccess;
    } else if (s.contains('cours') || s.contains('attente')) {
      bg = AppTheme.statusWarning.withValues(alpha: 0.18);
      fg = AppTheme.statusWarning;
    } else if (s.contains('rejet') ||
        s.contains('annul') ||
        s.contains('instance')) {
      bg = AppTheme.statusDanger.withValues(alpha: 0.18);
      fg = AppTheme.statusDanger;
    } else {
      bg = AppTheme.primaryIcons.withValues(alpha: 0.18);
      fg = AppTheme.primaryIcons;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
