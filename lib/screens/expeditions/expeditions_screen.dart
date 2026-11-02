import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/expedition_controller.dart';
import '../../models/expedition_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/status_badge.dart';
import 'expedition_detail_screen.dart';

class ExpeditionsScreen extends StatelessWidget {
  const ExpeditionsScreen({super.key});

  String _formatCurrency(num? amount) {
    if (amount == null) return '0.00 DH';
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} DH';
  }

  void _showFilterDialog(BuildContext context, ExpeditionController ctrl) {
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
                  Icon(LucideIcons.slidersHorizontal, color: AppTheme.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Filtrer les expéditions',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Color(0xFF0F172A), fontSize: 16.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: duCtrl,
                style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13.5),
                decoration: InputDecoration(
                  labelText: 'Date début (JJ/MM/AAAA)',
                  labelStyle: const TextStyle(color: AppTheme.primary, fontSize: 12),
                  hintText: '01/01/2026',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: auCtrl,
                style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13.5),
                decoration: InputDecoration(
                  labelText: 'Date fin (JJ/MM/AAAA)',
                  labelStyle: const TextStyle(color: AppTheme.primary, fontSize: 12),
                  hintText: '31/12/2026',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                  ),
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
                      ctrl.fetchAllExpeditions(resetPage: true);
                      Get.back();
                    },
                    child: const Text('Réinitialiser', style: TextStyle(color: Color(0xFF64748B))),
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
                      ctrl.fetchAllExpeditions(resetPage: true);
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
    final expCtrl = Get.find<ExpeditionController>();
    final searchCtrl = TextEditingController(text: expCtrl.searchQuery.value);

    return Column(
      children: [
        // ─── TOP TABS (EN COURS vs TOUTES) ─────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
          child: Obx(
            () => Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSegmentButton(
                      title: 'En cours (${expCtrl.expeditionsEncours.length})',
                      isSelected: expCtrl.activeTab.value == 0,
                      onTap: () => expCtrl.activeTab.value = 0,
                    ),
                  ),
                  Expanded(
                    child: _buildSegmentButton(
                      title: 'Toutes (${expCtrl.totalElements.value})',
                      isSelected: expCtrl.activeTab.value == 1,
                      onTap: () => expCtrl.activeTab.value = 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ─── SEARCH & FILTER BAR ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: GlassContainer(
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.search, color: AppTheme.primaryIcons, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: searchCtrl,
                          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'N° déclaration...',
                            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (v) {
                            expCtrl.searchQuery.value = v.trim();
                            expCtrl.fetchAllExpeditions(resetPage: true);
                          },
                        ),
                      ),
                      if (expCtrl.searchQuery.value.isNotEmpty)
                        IconButton(
                          icon: const Icon(LucideIcons.x, color: Color(0xFF94A3B8), size: 16),
                          onPressed: () {
                            searchCtrl.clear();
                            expCtrl.searchQuery.value = '';
                            expCtrl.fetchAllExpeditions(resetPage: true);
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  shadowColor: const Color(0xFF0F172A).withOpacity(0.06),
                  elevation: 2,
                ),
                icon: const Icon(LucideIcons.slidersHorizontal, color: AppTheme.primary, size: 18),
                onPressed: () => _showFilterDialog(context, expCtrl),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ─── LIST CONTENT ──────────────────────────────────────────────────
        Expanded(
          child: Obx(() {
            if (expCtrl.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
            }

            final list = expCtrl.activeTab.value == 0
                ? expCtrl.expeditionsEncours
                : expCtrl.allExpeditions;

            if (list.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.packageOpen, color: Color(0xFFCBD5E1), size: 48),
                    SizedBox(height: 12),
                    Text(
                      'Aucune expédition trouvée',
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
                if (expCtrl.activeTab.value == 0) {
                  await expCtrl.fetchExpeditionsEncours();
                } else {
                  await expCtrl.fetchAllExpeditions();
                }
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return _buildExpeditionCard(item);
                },
              ),
            );
          }),
        ),

        // ─── PAGINATION BAR FOR ALL EXPEDITIONS ────────────────────────────
        Obx(() {
          if (expCtrl.activeTab.value == 1 && expCtrl.totalPages.value > 1) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: GlassContainer(
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.chevronLeft, color: AppTheme.primary),
                      onPressed: expCtrl.currentPage.value > 1 ? expCtrl.previousPage : null,
                    ),
                    Text(
                      'Page ${expCtrl.currentPage.value} / ${expCtrl.totalPages.value}',
                      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.chevronRight, color: AppTheme.primary),
                      onPressed:
                          expCtrl.currentPage.value < expCtrl.totalPages.value ? expCtrl.nextPage : null,
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
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
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpeditionCard(ExpeditionModel item) {
    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(15),
      onTap: () {
        if (item.idExpedition != null) {
          Get.to(
            () => ExpeditionDetailScreen(idExpedition: item.idExpedition!),
            transition: Transition.cupertino,
            duration: const Duration(milliseconds: 360),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.package, color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.numDeclaration,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: item.statut ?? (item.isLivree ? 'Livré' : 'En cours')),
            ],
          ),
          const SizedBox(height: 12),

          // Route: Origine -> Destination
          Row(
            children: [
              const Icon(LucideIcons.mapPin, size: 13, color: AppTheme.primaryIcons),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${item.origine ?? "—"} → ${item.destination ?? "—"}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatCurrency(item.mntTtc),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Destinataire & Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Dest: ${item.destinataire ?? "—"}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '${item.colis ?? 1} colis • ${item.poids ?? 0} kg',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
