import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// Ouverture d'un document GED.
///
/// Les images (le cas courant : preuves de livraison scannees) s'affichent
/// dans l'application, en plein ecran et zoomables — pas besoin de sortir vers
/// le navigateur pour regarder une photo. Les autres formats (PDF notamment)
/// partent vers la visionneuse du systeme.
Future<void> ouvrirDocument(BuildContext context, String lien) async {
  final uri = Uri.tryParse(lien.trim());
  if (uri == null || !uri.hasScheme) {
    _erreur(context, 'Lien du document invalide.');

    return;
  }

  const extensionsImage = {'.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'};
  final chemin = uri.path.toLowerCase();
  final estImage = extensionsImage.any(chemin.endsWith);

  if (estImage) {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _VisionneuseImage(lien: lien),
        fullscreenDialog: true,
      ),
    );

    return;
  }

  final ouvert = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ouvert && context.mounted) {
    _erreur(context, "Impossible d'ouvrir ce document.");
  }
}

void _erreur(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: const Color(0xFFEF4444)),
  );
}

class _VisionneuseImage extends StatelessWidget {
  const _VisionneuseImage({required this.lien});

  final String lien;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Document', style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            tooltip: 'Ouvrir dans le navigateur',
            icon: const Icon(LucideIcons.externalLink, size: 18),
            onPressed: () => launchUrl(
              Uri.parse(lien),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Image.network(
            lien,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progres) {
              if (progres == null) return child;

              return const CircularProgressIndicator(color: Colors.white);
            },
            errorBuilder: (_, _, _) => const Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.imageOff, color: Colors.white54, size: 40),
                  SizedBox(height: 12),
                  Text(
                    'Document illisible ou indisponible.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
