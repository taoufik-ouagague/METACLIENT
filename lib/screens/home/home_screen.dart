import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_scaffold.dart';
import '../crbt/crbt_screen.dart';
import '../expeditions/expeditions_screen.dart';
import '../factures/factures_screen.dart';
import '../profile/profile_screen.dart';
import '../retours/retours_screen.dart';
import 'dashboard_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<String> _titles = [
    'Tableau de bord',
    'Expéditions',
    'Factures',
    'Retours Fonds',
    'CRBT & Virements',
    'Mon Profil',
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardTab(onNavigateTab: (idx) => setState(() => _currentIndex = idx)),
      const ExpeditionsScreen(),
      const FacturesScreen(),
      const RetoursScreen(),
      const CrbtScreen(),
      const ProfileScreen(),
    ];

    return GlassScaffold(
      isLight: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primaryIcons.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.06),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/img/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  LucideIcons.truck,
                  color: AppTheme.primaryIcons,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _titles[_currentIndex],
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
                fontSize: 17.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Profil Client',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == 5
                    ? AppTheme.primary
                    : Colors.white,
                border: Border.all(
                  color: _currentIndex == 5
                      ? AppTheme.primary
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.06),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                LucideIcons.user,
                color: _currentIndex == 5 ? Colors.white : AppTheme.primary,
                size: 18,
              ),
            ),
            onPressed: () => setState(() => _currentIndex = 5),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildGlassBottomNavBar(),
    );
  }

  Widget _buildGlassBottomNavBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.90),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.08),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(LucideIcons.layoutDashboard, 'Accueil', 0),
                _buildNavItem(LucideIcons.truck, 'Expéditions', 1),
                _buildNavItem(LucideIcons.fileText, 'Factures', 2),
                _buildNavItem(LucideIcons.rotateCcw, 'Retours', 3),
                _buildNavItem(LucideIcons.banknote, 'CRBT', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primary : const Color(0xFF64748B),
              size: isSelected ? 23 : 20,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primary : const Color(0xFF64748B),
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
