import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/retour_fond_controller.dart';
import '../../models/retour_fond_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/scroll_reveal.dart';
import '../../widgets/info_rows_card.dart';

class RetoursScreen extends StatelessWidget {
  const RetoursScreen({super.key});

  String _formatCurrency(num? amount) {
    if (amount == null) return '0.00 DH';
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} DH';
  }

  /// Champ de saisie du dialogue : libelle au-dessus, icone en tete.
  Widget _champFiltre(
    TextEditingController controleur,
    String libelle,
    String exemple,
    IconData icone,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          libelle,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controleur,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: exemple,
            hintStyle: const TextStyle(
              color: Color(0xFFB4C0CF),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(icone, size: 16, color: AppTheme.primary),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFF4F8FB),
            contentPadding: const EdgeInsets.fromLTRB(0, 11, 12, 11),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE4EAF1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context, RetourFondController ctrl) {
    final duCtrl = TextEditingController(text: ctrl.filterDu.value);
    final auCtrl = TextEditingController(text: ctrl.filterAu.value);
    final declCtrl = TextEditingController(
      text: ctrl.filterNumDeclaration.value,
    );
    final clientCtrl = TextEditingController(text: ctrl.filterClient.value);
    final pieceCtrl = TextEditingController(text: ctrl.filterNumPiece.value);
    final remis = ctrl.filterRemis.value.obs;

    void relancer() {
      ctrl.fetchRetoursCCCT(resetPage: true);
      ctrl.fetchRetoursBL(resetPage: true);
      Get.back<void>();
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF4F9FC)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 1.4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B3A5B).withValues(alpha: 0.18),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        LucideIcons.filter,
                        color: Colors.white,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 11),
                    const Expanded(
                      child: Text(
                        'Filtrer les retours',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        LucideIcons.x,
                        size: 18,
                        color: Color(0xFF94A3B8),
                      ),
                      onPressed: () => Get.back<void>(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Les deux bornes de date tiennent sur une ligne.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _champFiltre(
                        duCtrl,
                        'DU',
                        '01/01/2026',
                        LucideIcons.calendar,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _champFiltre(
                        auCtrl,
                        'AU',
                        '31/12/2026',
                        LucideIcons.calendar,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _champFiltre(
                  declCtrl,
                  'N° DÉCLARATION',
                  '260029143',
                  LucideIcons.hash,
                ),
                const SizedBox(height: 12),
                _champFiltre(
                  clientCtrl,
                  'CLIENT',
                  'LUMINEA SANTE',
                  LucideIcons.building2,
                ),
                const SizedBox(height: 12),
                _champFiltre(
                  pieceCtrl,
                  'N° PIÈCE',
                  '2102282',
                  LucideIcons.fileText,
                ),
                const SizedBox(height: 16),
                const Text(
                  'REMISE',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 7),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F8FB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE4EAF1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _choixRemise(remis, '', 'Tous')),
                        Expanded(child: _choixRemise(remis, 'O', 'Remis')),
                        Expanded(child: _choixRemise(remis, 'N', 'Non remis')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                            side: const BorderSide(color: Color(0xFFE4EAF1)),
                          ),
                        ),
                        onPressed: () {
                          ctrl.filterDu.value = '';
                          ctrl.filterAu.value = '';
                          ctrl.filterNumDeclaration.value = '';
                          ctrl.filterClient.value = '';
                          ctrl.filterNumPiece.value = '';
                          ctrl.filterRemis.value = '';
                          relancer();
                        },
                        child: const Text(
                          'Réinitialiser',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ctrl.filterDu.value = duCtrl.text.trim();
                          ctrl.filterAu.value = auCtrl.text.trim();
                          ctrl.filterNumDeclaration.value = declCtrl.text
                              .trim();
                          ctrl.filterClient.value = clientCtrl.text.trim();
                          ctrl.filterNumPiece.value = pieceCtrl.text.trim();
                          ctrl.filterRemis.value = remis.value;
                          relancer();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.32),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Appliquer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Un des trois choix de la bascule « Remise ».
  Widget _choixRemise(RxString selection, String valeur, String libelle) {
    final actif = selection.value == valeur;

    return GestureDetector(
      onTap: () => selection.value = valeur,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          gradient: actif ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Center(
          child: Text(
            libelle,
            style: TextStyle(
              color: actif ? Colors.white : const Color(0xFF475569),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final retourCtrl = Get.find<RetourFondController>();

    return Column(
      children: [
        // ─── TOP TABS (CC/CT vs BL/FACTURES) ──────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
          child: Obx(
            () => Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSegmentButton(
                      title:
                          'Chèques / Traites (${retourCtrl.retoursCCCT.length})',
                      isSelected: retourCtrl.activeTab.value == 0,
                      onTap: () => retourCtrl.activeTab.value = 0,
                    ),
                  ),
                  Expanded(
                    child: _buildSegmentButton(
                      title:
                          'Retours BL / Factures (${retourCtrl.retoursBL.length})',
                      isSelected: retourCtrl.activeTab.value == 1,
                      onTap: () => retourCtrl.activeTab.value = 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ─── RECHERCHE RAPIDE PAR N° DE DÉCLARATION ───────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 2, 18, 2),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller:
                      TextEditingController(
                          text: retourCtrl.filterNumDeclaration.value,
                        )
                        ..selection = TextSelection.collapsed(
                          offset: retourCtrl.filterNumDeclaration.value.length,
                        ),
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13.5,
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (v) {
                    retourCtrl.filterNumDeclaration.value = v.trim();
                    retourCtrl.fetchRetoursCCCT(resetPage: true);
                    retourCtrl.fetchRetoursBL(resetPage: true);
                  },
                  decoration: InputDecoration(
                    hintText: 'N° déclaration...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13.5,
                    ),
                    prefixIcon: const Icon(
                      LucideIcons.search,
                      color: AppTheme.primary,
                      size: 18,
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.9),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppTheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                icon: const Icon(
                  LucideIcons.filter,
                  color: AppTheme.primary,
                  size: 18,
                ),
                onPressed: () => _showFilterDialog(context, retourCtrl),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // ─── LIST CONTENT ──────────────────────────────────────────────────
        Expanded(
          child: Obx(() {
            if (retourCtrl.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }

            final list = retourCtrl.activeTab.value == 0
                ? retourCtrl.retoursCCCTAffiches
                : retourCtrl.retoursBLAffiches;

            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.fileSearch,
                      color: const Color(0xFFCBD5E1),
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Aucun retour enregistré',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: Colors.white,
              onRefresh: () async {
                if (retourCtrl.activeTab.value == 0) {
                  await retourCtrl.fetchRetoursCCCT();
                } else {
                  await retourCtrl.fetchRetoursBL();
                }
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return ScrollReveal(
                    index: index,
                    child: _buildRetourCard(context, item),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : Colors.transparent,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _ouvrirFiche(BuildContext context, RetourFondModel item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controleur) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controleur,
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              InfoRowsCard(
                titre: 'Retour N° ${item.numDeclaration}',
                icone: LucideIcons.fileText,
                lignes: [
                  MapEntry('Nature', item.nature),
                  MapEntry('Type d\'expédition', item.typeExpedition),
                  MapEntry('N° déclaration', item.numDeclaration),
                  MapEntry('N° pièce', item.numPiece),
                  MapEntry('Bordereau', item.bordereau),
                  MapEntry('Réf. bordereau', item.cfkBrd?.toString()),
                  MapEntry('Destinataire', item.destinataire),
                  MapEntry('Destination', item.destination),
                  MapEntry('Port', item.port),
                  MapEntry('Mode de règlement', item.modereglement),
                  MapEntry('Banque', item.banque),
                  MapEntry('Date d\'envoi', item.dateEnvoi),
                  MapEntry('Date de réception', item.dateReception),
                  MapEntry('Date d\'affectation', item.dateAffectation),
                  MapEntry('Date d\'encaissement', item.dateEncaissement),
                  MapEntry('Date de remise', item.dateRemise),
                  MapEntry(
                    'Montant HT',
                    item.mntHt == null ? null : _formatCurrency(item.mntHt),
                  ),
                  MapEntry(
                    'Montant TTC',
                    item.mntTtc == null ? null : _formatCurrency(item.mntTtc),
                  ),
                  MapEntry(
                    'Fond',
                    item.fond == null ? null : _formatCurrency(item.fond),
                  ),
                  MapEntry('N° expédition', item.idExpedition?.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRetourCard(BuildContext context, RetourFondModel item) {
    final isMoney = item.fond != null && item.fond! > 0;

    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      onTap: () => _ouvrirFiche(context, item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isMoney ? LucideIcons.coins : LucideIcons.fileText,
                  color: AppTheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Décl: ${item.numDeclaration ?? "—"}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (valeurRenseignee(item.numPiece)) ...[
                      const SizedBox(height: 2),
                      Text(
                        'N° pièce: ${item.numPiece}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (item.bordereau != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Bordereau: ${item.bordereau}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: item.nature),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Destinataire',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.destinataire ?? "—"} (${item.destination ?? "—"})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isMoney) ...[
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Montant Fond',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(item.fond),
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          if (item.dateRemise != null ||
              item.dateEncaissement != null ||
              item.banque != null) ...[
            const SizedBox(height: 8),
            Text(
              '${item.banque != null ? "Banque: ${item.banque} • " : ""}'
              '${item.dateEncaissement != null ? "Encaissé: ${item.dateEncaissement} • " : ""}'
              '${item.dateRemise != null ? "Remis: ${item.dateRemise}" : ""}',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
            ),
          ],
        ],
      ),
    );
  }
}
