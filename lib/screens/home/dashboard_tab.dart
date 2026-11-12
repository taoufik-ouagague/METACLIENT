import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/agence_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/scroll_reveal.dart';
import '../../widgets/stat_card.dart';
import '../expeditions/tracking_screen.dart';

class DashboardTab extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const DashboardTab({super.key, this.onNavigateTab});

  String _formatCurrency(num? amount) {
    if (amount == null) return '0.00 DH';
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} DH';
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final dashCtrl = Get.find<DashboardController>();
    final agenceCtrl = Get.find<AgenceController>();

    return RefreshIndicator(
      color: AppTheme.primary,
      backgroundColor: Colors.white,
      onRefresh: () async {
        await dashCtrl.loadDashboardData();
        await authCtrl.fetchClientInfo();
        await agenceCtrl.fetchAgences();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        // Un padding explicite ecrase celui que le Scaffold reserve pour la
        // barre flottante : on le reprend, sinon la derniere rangee reste
        // cachee dessous.
        padding: EdgeInsets.fromLTRB(
          18,
          10,
          18,
          14 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. TITRE DE LA PAGE ──────────────────────────────────────
            ScrollReveal.grille(
              index: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.50),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.layoutDashboard,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tableau de bord',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                            height: 1.15,
                            shadows: [
                              Shadow(
                                color: const Color(
                                  0xFF0F172A,
                                ).withValues(alpha: 0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 44,
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withValues(alpha: 0.2),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ─── 2. CARTE DE TÊTE : CRÉANCES IMPAYÉES ─────────────────────
            Obx(
              () => ScrollReveal.grille(
                index: 1,
                child: StatCard(
                  vedette: true,
                  chargement: dashCtrl.isLoading.value,
                  title: 'Créances impayées',
                  value: _formatCurrency(dashCtrl.totalSoldeDu.value),
                  icon: LucideIcons.wallet,
                  subtitle: 'Impayé',
                  color: const Color(0xFFE11D48),
                  onTap: () => onNavigateTab?.call(2),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ─── 3. EN COURS DE LIVRAISON & AGENCES ───────────────────────
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => ScrollReveal.grille(
                      index: 2,
                      child: StatCard(
                        chargement: dashCtrl.isLoading.value,
                        attenue: dashCtrl.expeditionsEncoursCount.value == 0,
                        title: 'En cours',
                        value: '${dashCtrl.expeditionsEncoursCount.value}',
                        icon: LucideIcons.truck,
                        subtitle: 'Expéditions',
                        color: const Color(0xFF0284C7),
                        onTap: () => onNavigateTab?.call(1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(
                    () => ScrollReveal.grille(
                      index: 3,
                      child: StatCard(
                        chargement: agenceCtrl.isLoading.value,
                        attenue: agenceCtrl.agences.isEmpty,
                        title: 'Réseau des agences',
                        value: '${agenceCtrl.agences.length}',
                        icon: LucideIcons.building2,
                        subtitle: 'Réseau',
                        color: const Color(0xFF4F46E5),
                        onTap: () => onNavigateTab?.call(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ─── 4. BOUTON SUIVI EXPÉDITION EN TEMPS RÉEL ─────────────────
            ScrollReveal.grille(
              index: 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Get.to<void>(
                      () => const TrackingScreen(),
                      transition: Transition.cupertino,
                      duration: const Duration(milliseconds: 360),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              LucideIcons.locateFixed,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Suivez votre expédition en temps réel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const Icon(
                            LucideIcons.arrowRight,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ─── 5. ILLUSTRATION 3D LOGISTIQUE & SUIVI ────────────────────
            ScrollReveal.grille(
              index: 5,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Image.asset(
                    'assets/img/logistics_3d_hero.png',
                    height: 215,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
