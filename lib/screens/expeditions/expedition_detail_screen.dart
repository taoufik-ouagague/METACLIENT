import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/expedition_controller.dart';
import '../../models/expedition_detail_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/carte_liste.dart';
import '../../widgets/glass_container.dart';
import 'table_expedition_screen.dart';
import '../../widgets/visionneuse_document.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/scroll_reveal.dart';

class ExpeditionDetailScreen extends StatefulWidget {
  final int idExpedition;

  /// Le suivi par n° de declaration a deja rempli `selectedDetail` : on ne
  /// relance pas d'appel, le detail s'affiche tel quel.
  final bool dejaCharge;

  const ExpeditionDetailScreen({
    super.key,
    required this.idExpedition,
    this.dejaCharge = false,
  });

  @override
  State<ExpeditionDetailScreen> createState() => _ExpeditionDetailScreenState();
}

class _ExpeditionDetailScreenState extends State<ExpeditionDetailScreen> {
  final ExpeditionController _controller = Get.find<ExpeditionController>();

  bool _infosOuvertes = true;

  @override
  void initState() {
    super.initState();
    if (!widget.dejaCharge) _controller.fetchDetail(widget.idExpedition);
  }

  String _formatCurrency(num? amount) {
    if (amount == null) return '0.00 DH';
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} DH';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      body: Obx(() {
        if (_controller.isLoadingDetail.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        final detail = _controller.selectedDetail.value;
        if (detail == null) {
          return const Center(
            child: Text(
              'Aucune donnée disponible',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          );
        }

        // En-tete peint, cartes posees dessus : l'identite de l'expedition
        // tient dans le bandeau, les cartes n'ont plus a la repeter.
        return Stack(
          children: [
            _enteteExpedition(detail),
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 116, 18, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── IDENTITE DE L'EXPEDITION (carte a 2 panneaux) ─────────────
                    GlassContainer(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Route (Origine -> Destination)
                          Row(
                            children: [
                              _buildRoutePill(
                                LucideIcons.circleDot,
                                'Origine',
                                detail.origine ?? '—',
                                societe: detail.expediteur,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: _traitTrajet(detail.sens),
                                ),
                              ),
                              _buildRoutePill(
                                LucideIcons.mapPin,
                                'Destination',
                                detail.destination ?? '—',
                                societe: detail.destinataire,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Metrics Row (Colis, Poids, port, nature)
                          Row(
                            children: [
                              _tuileChiffre(
                                'Colis',
                                '${detail.colis ?? 0}',
                                const Color(0xFF6366F1),
                              ),
                              const SizedBox(width: 8),
                              _tuileChiffre(
                                'Poids',
                                '${detail.poids ?? 0} kg',
                                AppTheme.primary,
                              ),
                              const SizedBox(width: 8),
                              // Sous le montant : le type de port (PPE, PD...) et la
                              // nature de l'expedition, plutot que des libelles fixes.
                              _tuileChiffre(
                                _libelleOuDefaut(detail.port, 'TTC'),
                                _formatCurrency(detail.mntTtc),
                                AppTheme.statusSuccess,
                              ),
                              const SizedBox(width: 8),
                              _tuileChiffre(
                                _libelleOuDefaut(detail.nature, 'Fond'),
                                _formatCurrency(detail.fond),
                                AppTheme.statusWarning,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── TABLES DE L'EXPEDITION ────────────────────────────────────
                    // Chaque tableau du contrat API a son bouton ; la liste s'ouvre
                    // en feuille plutot que d'empiler six sections dans la page.
                    _grilleTables(detail),

                    const SizedBox(height: 22),

                    // ─── DETAILS & PIECES (carte a 2 panneaux) ─────────────────────
                    // Panneau 1 : les champs du contrat API qui n'ont pas leur place
                    // ailleurs. Panneau 2 : les documents GED, toujours affiche —
                    // vide, il dit qu'il est vide plutot que de disparaitre.
                    Builder(
                      builder: (context) {
                        final lignes =
                            <MapEntry<String, String>>[
                                  MapEntry('Activité', detail.activite ?? ''),
                                  MapEntry(
                                    'Type de livraison',
                                    detail.livraison ?? '',
                                  ),
                                  MapEntry('BL / Facture', detail.blFact ?? ''),
                                  MapEntry(
                                    'Valeur déclarée',
                                    detail.valeurDeclaree == null
                                        ? ''
                                        : _formatCurrency(
                                            detail.valeurDeclaree,
                                          ),
                                  ),
                                  MapEntry(
                                    'Montant HT',
                                    detail.mntHt == null
                                        ? ''
                                        : _formatCurrency(detail.mntHt),
                                  ),
                                  MapEntry(
                                    'Facture en compte',
                                    detail.factureEncompte ?? '',
                                  ),
                                  MapEntry(
                                    'Date livraison mobile',
                                    detail.dateLivMobile ?? '',
                                  ),
                                  MapEntry(
                                    'Date encaissement',
                                    detail.dateEncaissement ?? '',
                                  ),
                                  // Renvoye par /trackingExpedition uniquement.
                                  MapEntry(
                                    'Zone GPS',
                                    detail.gpsGeofence ?? '',
                                  ),
                                  MapEntry(
                                    'Position GPS',
                                    detail.gpsLatitude == null ||
                                            detail.gpsLongitude == null
                                        ? ''
                                        : '${detail.gpsLatitude}, ${detail.gpsLongitude}',
                                  ),
                                  MapEntry(
                                    'Relevé GPS le',
                                    detail.gpsCapturedAt ?? '',
                                  ),
                                ]
                                .where(
                                  (e) =>
                                      e.key == 'Date livraison mobile' ||
                                      _renseigne(e.value),
                                )
                                .toList();

                        if (lignes.isEmpty) return const SizedBox.shrink();

                        return Container(
                          padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
                          decoration: BoxDecoration(
                            // Un blanc parfaitement plat durcit la carte : le
                            // degrade lui donne du relief sans la colorer.
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.white, Color(0xFFF7FAFD)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE8EDF3)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF0F172A,
                                ).withValues(alpha: 0.05),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () => setState(
                                  () => _infosOuvertes = !_infosOuvertes,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withValues(
                                            alpha: 0.10,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          LucideIcons.info,
                                          color: AppTheme.primary,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Expanded(
                                        child: Text(
                                          'Informations complémentaires',
                                          style: TextStyle(
                                            color: Color(0xFF0F172A),
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.1,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF1F5F9),
                                          shape: BoxShape.circle,
                                        ),
                                        child: AnimatedRotation(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          turns: _infosOuvertes ? 0.5 : 0,
                                          child: const Icon(
                                            LucideIcons.chevronDown,
                                            size: 15,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Depliee a l'ouverture : ce sont les champs que
                              // l'on vient lire. Le repli reste disponible.
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 220),
                                sizeCurve: Curves.easeOut,
                                crossFadeState: _infosOuvertes
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                firstChild: const SizedBox(
                                  width: double.infinity,
                                  height: 0,
                                ),
                                secondChild: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    children: [
                                      const Divider(
                                        color: Color(0xFFE8EDF3),
                                        height: 1,
                                      ),
                                      const SizedBox(height: 8),
                                      // Une ligne sur deux est teintee : plus
                                      // lisible qu'un filet entre chaque, et
                                      // l'oeil suit la ligne jusqu'a sa valeur.
                                      for (var i = 0; i < lignes.length; i++)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 9,
                                          ),
                                          decoration: BoxDecoration(
                                            color: i.isEven
                                                ? const Color(0xFFF6F9FC)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              9,
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 5,
                                                child: Text(
                                                  lignes[i].key,
                                                  style: const TextStyle(
                                                    color: Color(0xFF64748B),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                flex: 6,
                                                child: Text(
                                                  lignes[i].value,
                                                  textAlign: TextAlign.end,
                                                  style: const TextStyle(
                                                    color: Color(0xFF0F172A),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                  onPressed: () => Get.back<void>(),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Bandeau degrade : retour, titre, numero de declaration et nature du port.
  Widget _enteteExpedition(ExpeditionDetailModel detail) {
    return Container(
      height: 196,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B7A94), AppTheme.primary, Color(0xFF3FC1D8)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Le vrai bouton est pose au-dessus du scroll ; ici on ne
                  // reserve que sa place pour aligner le titre.
                  const SizedBox(width: 48, height: 48),
                  const Text(
                    'Détail Expédition',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.package,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'N° ${detail.numDeclaration}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Taxée le ${detail.dateTaxation ?? "—"}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.80),
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        detail.port ?? 'Standard',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Contenu de la feuille « Suivi & etapes ».
  /// Un attribut d'etape : icone et texte de la meme teinte, pour que le
  /// lieu, l'agent, la tournee et le chauffeur se distinguent d'un regard.
  Widget _attributEtape(IconData icone, String texte, Color couleur) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1.5),
          child: Icon(icone, size: 12.5, color: couleur),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texte,
            style: TextStyle(
              color: couleur,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _contenuProcessus(ExpeditionDetailModel detail) => [
    // ─── SUIVI PROCESSUS (TIMELINE DE LIVRAISON) ───────────────────
    const Row(
      children: [
        Icon(LucideIcons.gitCommit, color: AppTheme.primary, size: 20),
        SizedBox(width: 8),
        Text(
          'Suivi & Étapes de Livraison',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
    const SizedBox(height: 12),

    if (detail.processus.isEmpty)
      const GlassContainer(
        borderRadius: 18,
        padding: EdgeInsets.all(18),
        child: Center(
          child: Text(
            'Aucune étape de transport enregistrée',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ),
      )
    else
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: detail.processus.length,
        itemBuilder: (context, idx) {
          final step = detail.processus[idx];
          final isLast = idx == detail.processus.length - 1;

          return ScrollReveal(
            index: idx,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      if (idx > 0)
                        Container(
                          width: 2,
                          height: 8,
                          color: AppTheme.primary.withValues(alpha: 0.25),
                        )
                      else
                        const SizedBox(height: 8),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isLast
                              ? AppTheme.statusSuccess.withValues(alpha: 0.15)
                              : AppTheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isLast
                                ? AppTheme.statusSuccess
                                : AppTheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            isLast ? LucideIcons.check : LucideIcons.circle,
                            size: 14,
                            color: isLast
                                ? AppTheme.statusSuccess
                                : AppTheme.primary,
                          ),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: AppTheme.primary.withValues(alpha: 0.25),
                          ),
                        )
                      else
                        const Spacer(),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 18.0),
                      child: CarteListe(
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    step.processus,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (step.status != null) ...[
                                  const SizedBox(width: 8),
                                  StatusBadge(
                                    status: step.status!,
                                    fontSize: 10,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (step.dateAction != null)
                              Row(
                                children: [
                                  const Icon(
                                    LucideIcons.clock,
                                    size: 12,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    step.dateAction!,
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            if (_renseigne(step.faitA)) ...[
                              const SizedBox(height: 5),
                              _attributEtape(
                                LucideIcons.mapPin,
                                step.faitA!,
                                const Color(0xFFF59E0B),
                              ),
                            ],
                            if (_renseigne(step.faitPar)) ...[
                              const SizedBox(height: 5),
                              _attributEtape(
                                LucideIcons.user,
                                step.faitPar!,
                                const Color(0xFF6366F1),
                              ),
                            ],
                            if (_renseigne(step.tourneeVoyage)) ...[
                              const SizedBox(height: 5),
                              _attributEtape(
                                LucideIcons.navigation,
                                step.tourneeVoyage!,
                                const Color(0xFFA855F7),
                              ),
                            ],
                            if (_renseigne(step.livreurChauffeur)) ...[
                              const SizedBox(height: 5),
                              _attributEtape(
                                LucideIcons.truck,
                                step.livreurChauffeur!,
                                AppTheme.primary,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
  ];

  /// Contenu de la feuille « Commentaires ».
  List<Widget> _contenuCommentaires(ExpeditionDetailModel detail) => [
    // ─── COMMENTAIRES ──────────────────────────────────────────────
    if (detail.commentaires.isNotEmpty) ...[
      const Row(
        children: [
          Icon(LucideIcons.messageSquare, color: AppTheme.primary, size: 20),
          SizedBox(width: 8),
          Text(
            'Commentaires & Réserves',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      ...detail.commentaires.map(
        (c) => CarteListe(
          margin: const EdgeInsets.only(bottom: 10),
          borderRadius: 16,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    c.typeComment ?? 'Note',
                    style: const TextStyle(
                      color: AppTheme.statusWarning,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    c.dateComment ?? '',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                c.libelleComment ?? '',
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 12.5,
                ),
              ),
              if (_renseigne(c.sourceComment)) ...[
                const SizedBox(height: 4),
                Text(
                  'Source: ${c.sourceComment}',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ],
              if (c.agentComment != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Par: ${c.agentComment}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ],
  ];

  /// Contenu de la feuille « Documents GED ».
  List<Widget> _contenuGed(ExpeditionDetailModel detail) => [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(LucideIcons.fileText, color: AppTheme.primary, size: 20),
            SizedBox(width: 8),
            Text(
              'Documents GED (Preuves / Facturation)',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (detail.gedDocuments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              children: [
                Icon(LucideIcons.fileX, size: 26, color: Color(0xFFCBD5E1)),
                SizedBox(height: 8),
                Text(
                  'Aucun document disponible',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Les preuves de livraison et les pièces de\nfacturation apparaîtront ici.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
                ),
              ],
            ),
          ),
        ...detail.gedDocuments.map(
          (doc) => CarteListe(
            onTap: () => ouvrirDocument(context, doc.lien),
            margin: const EdgeInsets.only(bottom: 10),
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.fileCode,
                  color: AppTheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.typeDocument.isNotEmpty
                            ? doc.typeDocument
                            : 'Document GED',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        Uri.tryParse(doc.lien)?.pathSegments.last ?? doc.lien,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    LucideIcons.externalLink,
                    color: AppTheme.primary,
                    size: 18,
                  ),
                  onPressed: () => ouvrirDocument(context, doc.lien),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ];

  Widget _grilleTables(ExpeditionDetailModel detail) {
    final tables = <_TableExpedition>[
      _TableExpedition(
        'Étapes',
        LucideIcons.gitCommit,
        AppTheme.primary,
        detail.processus.length,
        () => _contenuProcessus(detail),
      ),
      _TableExpedition(
        'Commentaires',
        LucideIcons.messageSquare,
        const Color(0xFFEC4899),
        detail.commentaires.length,
        () => _contenuCommentaires(detail),
      ),
      _TableExpedition(
        'BL / Factures',
        LucideIcons.receipt,
        AppTheme.statusSuccess,
        detail.retourBlFacture.length,
        () => const <Widget>[],
        items: detail.retourBlFacture,
        naturesAttendues: const ['BL', 'FACTURE'],
      ),
      _TableExpedition(
        'Chèques / Traites',
        LucideIcons.badgePercent,
        AppTheme.statusWarning,
        detail.retourCcCt.length,
        () => const <Widget>[],
        items: detail.retourCcCt,
      ),
      _TableExpedition(
        'C/REMB',
        LucideIcons.wallet,
        const Color(0xFFA855F7),
        detail.chequeCr.length,
        () => const <Widget>[],
        items: detail.chequeCr,
      ),
      _TableExpedition(
        'Documents',
        LucideIcons.fileText,
        const Color(0xFF6366F1),
        detail.gedDocuments.length,
        () => _contenuGed(detail),
      ),
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: tables.length,
        separatorBuilder: (_, _) => const SizedBox(width: 9),
        itemBuilder: (_, i) => _boutonTable(tables[i]),
      ),
    );
  }

  Widget _boutonTable(_TableExpedition table) {
    // La teinte du tableau remplit tout le bouton ; la pastille du compteur
    // passe en blanc pour rester lisible dessus.
    return GlassContainer(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      // Verre teinte : la couleur laisse passer le fond que le BackdropFilter
      // floute, et le liserd blanc donne l'arete lumineuse du verre.
      color: table.couleur.withValues(alpha: 0.82),
      blur: 14,
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.40),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: table.couleur.withValues(alpha: 0.32),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
      // Un tableau vide n'ouvre rien : la page ne montrerait qu'un etat vide.
      // Le bouton garde sa teinte, seul le ripple disparait.
      onTap: table.nombre == 0 ? null : () => _ouvrirTable(table),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            table.libelle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 7),
          Container(
            constraints: const BoxConstraints(minWidth: 20),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              '${table.nombre}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: table.couleur,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _ouvrirTable(_TableExpedition table) {
    Get.to<void>(
      () => TableExpeditionScreen(
        titre: table.libelle,
        icone: table.icone,
        couleur: table.couleur,
        items: table.items,
        contenu: table.items == null ? table.contenu : null,
        naturesAttendues: table.naturesAttendues,
      ),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 360),
    );
  }

  Widget _buildRoutePill(
    IconData icon,
    String label,
    String city, {
    String? societe,
  }) {
    return Flexible(
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary, size: 18),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
          ),
          Text(
            city,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          if (_renseigne(societe))
            Text(
              societe!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11.5,
                height: 1.25,
              ),
            ),
        ],
      ),
    );
  }

  /// Trait de trajet en pointilles, avec le camion au milieu : un simple
  /// Divider ne disait rien du deplacement.
  /// Libelle d'une tuile : la valeur du champ, ou le libelle fixe si l'API ne
  /// la renseigne pas.
  String _libelleOuDefaut(String? valeur, String defaut) {
    final v = valeur?.trim();
    return (v == null || v.isEmpty) ? defaut : v;
  }

  /// [sens] : « E » (expedition) part vers la destination, « R » (retour)
  /// revient vers l'origine. Tout autre valeur n'affiche aucune fleche.
  Widget _traitTrajet(String? sens) {
    final code = sens?.trim().toUpperCase();
    final retour = code == 'R';
    final aller = code == 'E';
    final teinte = retour
        ? AppTheme.statusDanger
        : aller
        ? AppTheme.statusSuccess
        : AppTheme.primary;

    return SizedBox(
      height: 22,
      child: LayoutBuilder(
        builder: (context, contraintes) {
          const largeurTiret = 4.0;
          const espace = 4.0;
          final nombre = (contraintes.maxWidth / (largeurTiret + espace))
              .floor()
              .clamp(2, 60);

          return Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  nombre,
                  (_) => Container(
                    width: largeurTiret,
                    height: 1.5,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: teinte.withValues(alpha: 0.35)),
                ),
                // Le camion de Lucide roule vers la droite : au retour on le
                // retourne pour qu'il regarde la ville d'origine.
                child: Transform.scale(
                  scaleX: retour ? -1 : 1,
                  child: Icon(LucideIcons.truck, size: 11, color: teinte),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Un chiffre cle : plus de tuile ni d'icone, la couleur passe sur le texte.
  Widget _tuileChiffre(String libelle, String valeur, Color couleur) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valeur,
              maxLines: 1,
              style: TextStyle(
                color: couleur,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            libelle,
            style: TextStyle(
              color: couleur.withValues(alpha: 0.70),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Une valeur « . », « 0 » ou vide revient regulierement de l'API a la place
  /// d'un null : elle ne vaut pas la peine d'etre affichee.
  static bool _renseigne(String? v) {
    final t = v?.trim() ?? '';

    return t.isNotEmpty && t != '.' && t != '-' && t != '0' && t != 'null';
  }

  /// Rend une liste de retours en affichant **toutes** les cles renvoyees par
  /// l'API : un champ ajoute cote serveur apparait sans toucher a l'ecran.
}

/// Un tableau du contrat API : son libelle, son icone, son effectif et de quoi
/// construire sa liste a la demande.
class _TableExpedition {
  const _TableExpedition(
    this.libelle,
    this.icone,
    this.couleur,
    this.nombre,
    this.contenu, {
    this.items,
    this.naturesAttendues = const [],
  });

  final String libelle;
  final IconData icone;

  /// Chaque tableau garde sa teinte, plein ou vide : la couleur sert a le
  /// reconnaitre d'un coup d'oeil, pas a dire s'il contient quelque chose.
  final Color couleur;
  final int nombre;
  final List<Widget> Function() contenu;

  /// Lignes brutes de l'API, quand le tableau se prete au filtrage par nature.
  final List<Map<String, dynamic>>? items;

  /// Natures du contrat API a toujours proposer au filtre.
  final List<String> naturesAttendues;
}
