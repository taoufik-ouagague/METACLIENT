import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/retour_fond_controller.dart';
import '../../models/retour_fond_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/status_badge.dart';

class RetoursScreen extends StatelessWidget {
  const RetoursScreen({super.key});

  String _formatCurrency(num? amount) {
    if (amount == null) return '0.00 DH';
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} DH';
  }

  void _showFilterDialog(BuildContext context, RetourFondController ctrl) {
    final duCtrl = TextEditingController(text: ctrl.filterDu.value);
    final auCtrl = TextEditingController(text: ctrl.filterAu.value);

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.slidersHorizontal, color: AppTheme.primaryIcons, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Filtrer les retours',
                    style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: duCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: InputDecoration(
                  labelText: 'Date début (JJ/MM/AAAA)',
                  labelStyle: const TextStyle(color: AppTheme.primaryIcons, fontSize: 12),
                  hintText: '01/01/2026',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: auCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: InputDecoration(
                  labelText: 'Date fin (JJ/MM/AAAA)',
                  labelStyle: const TextStyle(color: AppTheme.primaryIcons, fontSize: 12),
                  hintText: '31/12/2026',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      ctrl.filterDu.value = '';
                      ctrl.filterAu.value = '';
                      ctrl.fetchRetoursCCCT(resetPage: true);
                      ctrl.fetchRetoursBL(resetPage: true);
                      Get.back();
                    },
                    child: const Text('Réinitialiser', style: TextStyle(color: Colors.white60)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ctrl.filterDu.value = duCtrl.text.trim();
                      ctrl.filterAu.value = auCtrl.text.trim();
                      ctrl.fetchRetoursCCCT(resetPage: true);
                      ctrl.fetchRetoursBL(resetPage: true);
                      Get.back();
                    },
                    child: const Text('Appliquer', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
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
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSegmentButton(
                      title: 'Chèques / Traites (${retourCtrl.retoursCCCT.length})',
                      isSelected: retourCtrl.activeTab.value == 0,
                      onTap: () => retourCtrl.activeTab.value = 0,
                    ),
                  ),
                  Expanded(
                    child: _buildSegmentButton(
                      title: 'Retours BL / Factures (${retourCtrl.retoursBL.length})',
                      isSelected: retourCtrl.activeTab.value == 1,
                      onTap: () => retourCtrl.activeTab.value = 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ─── FILTER QUICK ROW ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() {
                final hasFilter = retourCtrl.filterDu.value.isNotEmpty;
                return Text(
                  hasFilter
                      ? 'Période : ${retourCtrl.filterDu.value} au ${retourCtrl.filterAu.value}'
                      : 'Tous les retours de documents',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                );
              }),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primaryIcons.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: AppTheme.primaryIcons.withOpacity(0.3)),
                  ),
                ),
                icon: const Icon(LucideIcons.calendar, color: AppTheme.primaryIcons, size: 18),
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
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryIcons));
            }

            final list = retourCtrl.activeTab.value == 0
                ? retourCtrl.retoursCCCT
                : retourCtrl.retoursBL;

            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.fileSearch, color: Colors.white.withOpacity(0.3), size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Aucun retour enregistré',
                      style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppTheme.primaryIcons,
              backgroundColor: AppTheme.bgSurface,
              onRefresh: () async {
                if (retourCtrl.activeTab.value == 0) {
                  await retourCtrl.fetchRetoursCCCT();
                } else {
                  await retourCtrl.fetchRetoursBL();
                }
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return _buildRetourCard(item);
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
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRetourCard(RetourFondModel item) {
    final isMoney = item.fond != null && item.fond! > 0;

    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryIcons.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isMoney ? LucideIcons.coins : LucideIcons.fileText,
                      color: AppTheme.primaryIcons,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Décl: ${item.numDeclaration ?? "—"}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (item.bordereau != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Bordereau: ${item.bordereau}',
                          style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11.5),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              StatusBadge(status: item.nature),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Destinataire',
                    style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.destinataire ?? "—"} (${item.destination ?? "—"})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (isMoney)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Montant Fond',
                      style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(item.fond),
                      style: const TextStyle(
                        color: AppTheme.primaryIcons,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          if (item.dateRemise != null || item.dateEncaissement != null || item.banque != null) ...[
            const SizedBox(height: 8),
            Text(
              '${item.banque != null ? "Banque: ${item.banque} • " : ""}'
              '${item.dateEncaissement != null ? "Encaissé: ${item.dateEncaissement} • " : ""}'
              '${item.dateRemise != null ? "Remis: ${item.dateRemise}" : ""}',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11.5),
            ),
          ],
        ],
      ),
    );
  }
}
