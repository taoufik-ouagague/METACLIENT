import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/expedition_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../expeditions/expedition_detail_screen.dart';
import '../../widgets/scroll_reveal.dart';

class DashboardTab extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const DashboardTab({super.key, this.onNavigateTab});

  String _formatCurrency(num? amount) {
    if (amount == null) return '0.00 DH';
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} DH';
  }

  Widget _badgeType(String label, bool isVir) {
    final Color bg = isVir
        ? const Color(0xFF0EA5E9).withValues(alpha: 0.12)
        : const Color(0xFFA855F7).withValues(alpha: 0.12);
    final Color fg = isVir ? const Color(0xFF0284C7) : const Color(0xFF9333EA);
    final Color border = isVir
        ? const Color(0xFF0EA5E9).withValues(alpha: 0.28)
        : const Color(0xFFA855F7).withValues(alpha: 0.28);
    final IconData icon = isVir ? LucideIcons.arrowRightLeft : LucideIcons.wallet;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9.5, color: fg),
          const SizedBox(width: 3.5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final dashCtrl = Get.find<DashboardController>();
    final expCtrl = Get.find<ExpeditionController>();
    final searchCtrl = TextEditingController();

    return RefreshIndicator(
      color: AppTheme.primary,
      backgroundColor: Colors.white,
      onRefresh: () async {
        await dashCtrl.loadDashboardData();
        await authCtrl.fetchClientInfo();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── QUICK DECLARATION SEARCH BAR ─────────────────────────────
            GlassContainer(
              borderRadius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.search,
                    color: AppTheme.primaryIcons,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: searchCtrl,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 13.5,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Rechercher N° déclaration (ex: F644759)...',
                        hintStyle: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (query) {
                        if (query.trim().isNotEmpty) {
                          expCtrl.searchQuery.value = query.trim();
                          expCtrl.fetchAllExpeditions(resetPage: true);
                          onNavigateTab?.call(1);
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.arrowRightCircle,
                      color: AppTheme.primaryIcons,
                      size: 22,
                    ),
                    onPressed: () {
                      if (searchCtrl.text.trim().isNotEmpty) {
                        expCtrl.searchQuery.value = searchCtrl.text.trim();
                        expCtrl.fetchAllExpeditions(resetPage: true);
                        onNavigateTab?.call(1);
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── 3. STATS KPI GRID ───────────────────────────────────────────
            Obx(
              () => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'En cours de livraison',
                          value: '${dashCtrl.expeditionsEncoursCount.value}',
                          icon: LucideIcons.truck,
                          subtitle: 'En temps réel',
                          color: const Color(0xFF0284C7),
                          onTap: () => onNavigateTab?.call(1),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          title: 'Total Expéditions',
                          value: '${dashCtrl.totalExpeditionsCount.value}',
                          icon: LucideIcons.packageCheck,
                          subtitle: 'Historique',
                          color: const Color(0xFF6366F1),
                          onTap: () => onNavigateTab?.call(1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Factures en instances',
                          value: '${dashCtrl.facturesInstancesCount.value}',
                          icon: LucideIcons.fileWarning,
                          subtitle: 'À régler',
                          color: const Color(0xFFD97706),
                          onTap: () => onNavigateTab?.call(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          title: 'Solde dû total',
                          value: _formatCurrency(dashCtrl.totalSoldeDu.value),
                          icon: LucideIcons.wallet,
                          subtitle: 'Impayé',
                          color: const Color(0xFFE11D48),
                          onTap: () => onNavigateTab?.call(2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── 4. RECENT EXPEDITIONS SECTION ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      LucideIcons.activity,
                      color: AppTheme.primaryIcons,
                      size: 19,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Dernières Expéditions',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => onNavigateTab?.call(1),
                  child: const Row(
                    children: [
                      Text(
                        'Voir tout',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        LucideIcons.chevronRight,
                        color: AppTheme.primary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Obx(() {
              if (dashCtrl.isLoading.value &&
                  dashCtrl.recentExpeditions.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                );
              }

              if (dashCtrl.recentExpeditions.isEmpty) {
                return GlassContainer(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(24),
                  child: const Center(
                    child: Text(
                      'Aucune expédition trouvée',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dashCtrl.recentExpeditions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = dashCtrl.recentExpeditions[index];
                  return ScrollReveal(
                    index: index,
                    child: GlassContainer(
                      borderRadius: 18,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      onTap: () {
                        if (item.idExpedition != null) {
                          Get.to(
                            () => ExpeditionDetailScreen(
                              idExpedition: item.idExpedition!,
                            ),
                            transition: Transition.cupertino,
                            duration: const Duration(milliseconds: 360),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryIcons.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              LucideIcons.package,
                              color: AppTheme.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              item.numDeclaration,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Color(0xFF0F172A),
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          if (item.typeRemboursementLibelle != null) ...[
                                            const SizedBox(width: 6),
                                            _badgeType(
                                              item.typeRemboursementLibelle!,
                                              item.isVirement,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    StatusBadge(
                                      status:
                                          item.statut ??
                                          (item.isLivree
                                              ? 'Livré'
                                              : 'En cours'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      LucideIcons.mapPin,
                                      size: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${item.origine ?? "—"} → ${item.destination ?? "—"}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatCurrency(item.mntTtc),
                                      style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
