import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

/// Carte de localisation GPS d'une expedition avec apercu visuel,
/// badge de zone (geofence), coordonnees exactes et actions d'ouverture
/// dans Google Maps et calcul d'itineraire.
class CarteGps extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String? geofence;
  final String? capturedAt;
  final String? titre;
  final String? numDeclaration;
  final double? height;

  const CarteGps({
    super.key,
    required this.latitude,
    required this.longitude,
    this.geofence,
    this.capturedAt,
    this.titre,
    this.numDeclaration,
    this.height,
  });

  @override
  State<CarteGps> createState() => _CarteGpsState();
}

class _CarteGpsState extends State<CarteGps>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _ouvrirGoogleMaps() async {
    final lat = widget.latitude;
    final lng = widget.longitude;
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    try {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ouvrir l\'application de cartographie.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.85),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _ouvrirItineraire() async {
    final lat = widget.latitude;
    final lng = widget.longitude;
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    try {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      Get.snackbar(
        'Erreur',
        'Impossible de lancer l\'itinéraire.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.85),
        colorText: Colors.white,
      );
    }
  }

  void _copierCoordonnees() {
    final coords = '${widget.latitude}, ${widget.longitude}';
    Clipboard.setData(ClipboardData(text: coords));
    HapticFeedback.lightImpact();
    Get.snackbar(
      'Coordonnées copiées',
      coords,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(
        LucideIcons.checkCheck,
        color: Color(0xFF10B981),
        size: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lat = widget.latitude;
    final lng = widget.longitude;
    final coordsStr = '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';

    // URL OpenStreetMap static map
    final staticMapUrl =
        'https://staticmap.openstreetmap.de/staticmap.php?center=$lat,$lng&zoom=15&size=650x320&maptype=mapnik';

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── ENTÊTE CARTE GPS ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Row(
              children: [
                // Icone GPS ronde compacte
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      LucideIcons.mapPin,
                      color: AppTheme.primary,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.titre ?? 'Position GPS',
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.1,
                            ),
                          ),
                          if (widget.geofence != null &&
                              widget.geofence!.trim().isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  widget.geofence!.trim(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF047857),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        widget.capturedAt != null &&
                                widget.capturedAt!.trim().isNotEmpty
                            ? 'Relevé le ${widget.capturedAt}'
                            : coordsStr,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bouton copier
                IconButton(
                  tooltip: 'Copier les coordonnées',
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    LucideIcons.copy,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  onPressed: _copierCoordonnees,
                ),
              ],
            ),
          ),

          // ─── APERÇU DE LA CARTE VISUELLE ──────────────────────────────────
          if (widget.height != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _buildCarteStack(staticMapUrl, coordsStr),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(
                height: 190,
                width: double.infinity,
                child: _buildCarteStack(staticMapUrl, coordsStr),
              ),
            ),

          // ─── BOUTONS D'ACTION (GOOGLE MAPS & ITINÉRAIRE) ──────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              children: [
                // Bouton Google Maps
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: _ouvrirGoogleMaps,
                    icon: const Icon(LucideIcons.map, size: 16),
                    label: const Text(
                      'Google Maps',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Bouton Itinéraire
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: _ouvrirItineraire,
                    icon: const Icon(LucideIcons.navigation, size: 15),
                    label: const Text(
                      'Itinéraire',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(
                        color: Color(0xFFCBD5E1),
                        width: 1.2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarteStack(String staticMapUrl, String coordsStr) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Image de carte OSM ou Canvas stylisé
          SizedBox.expand(
            child: Image.network(
              staticMapUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return _buildMapPlaceholder();
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildMapPlaceholder();
              },
            ),
          ),

          // Pin central animé
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Onde pulsante
                          Container(
                            width: 44 * _pulseAnimation.value,
                            height: 44 * _pulseAnimation.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFEF4444).withValues(
                                alpha:
                                    0.25 * (1.3 - _pulseAnimation.value + 0.85),
                              ),
                            ),
                          ),
                          // Marqueur Pin
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                LucideIcons.navigation,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  // Ombre sous le pin
                  Container(
                    width: 14,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Overlay Badge Coordonnées (Bas Gauche)
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.crosshair,
                    size: 12,
                    color: Color(0xFF38BDF8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    coordsStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Overlay Bouton Agrandir (Haut Droit)
          Positioned(
            right: 10,
            top: 10,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _ouvrirGoogleMaps,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.externalLink,
                        size: 12,
                        color: Color(0xFF0F172A),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Agrandir',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Zone cliquable sur toute la carte
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(onTap: _ouvrirGoogleMaps),
            ),
          ),
        ],
      ),
    );
  }

  /// Placeholder stylisé élégant avec motif de grille routière
  Widget _buildMapPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1), Color(0xFFE2E8F0)],
        ),
      ),
      child: CustomPaint(painter: _RoadGridPainter()),
    );
  }
}

/// Peintre de grille et routes stylisées en arrière-plan de carte
class _RoadGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final secondaryRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final waterPaint = Paint()
      ..color = const Color(0xFF93C5FD).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Tracé de rivière / lac stylisé
    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.6,
        size.width * 0.6,
        size.height * 0.9,
        size.width,
        size.height * 0.8,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, waterPaint);

    // Routes principales
    canvas.drawLine(
      Offset(0, size.height * 0.45),
      Offset(size.width, size.height * 0.52),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.48, 0),
      Offset(size.width * 0.52, size.height),
      roadPaint,
    );

    // Routes secondaires
    canvas.drawLine(
      Offset(0, size.height * 0.2),
      Offset(size.width, size.height * 0.25),
      secondaryRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.25, size.height),
      secondaryRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.8, 0),
      Offset(size.width * 0.75, size.height),
      secondaryRoadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
