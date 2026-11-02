import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/config_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ambient_background.dart';
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
  final _cleScaffold = GlobalKey<ScaffoldState>();
  final TextEditingController _rechercheMenu = TextEditingController();
  String _filtreMenu = '';
  int _index = 0;
  int _previousIndex = 0;
  final AuthController _authController = Get.find<AuthController>();

  void _changerOnglet(int nouvelIndex) {
    if (nouvelIndex == _index) return;
    setState(() {
      _previousIndex = _index;
      _index = nouvelIndex;
    });
  }

  @override
  void dispose() {
    _rechercheMenu.dispose();
    super.dispose();
  }

  bool _correspond(String label) =>
      _filtreMenu.isEmpty || label.toLowerCase().contains(_filtreMenu);

  List<({IconData icone, String label, Widget page, bool barre})> _getOnglets() {
    return [
      (
        icone: LucideIcons.home,
        label: 'Accueil',
        page: DashboardTab(
          onNavigateTab: (target) => _changerOnglet(target),
        ),
        barre: true,
      ),
      (
        icone: LucideIcons.truck,
        label: 'Expéditions',
        page: const ExpeditionsScreen(),
        barre: true,
      ),
      (
        icone: LucideIcons.fileText,
        label: 'Factures',
        page: const FacturesScreen(),
        barre: true,
      ),
      (
        icone: LucideIcons.rotateCcw,
        label: 'Retours',
        page: const RetoursScreen(),
        barre: true,
      ),
      (
        icone: LucideIcons.banknote,
        label: 'CRBT',
        page: const CrbtScreen(),
        barre: true,
      ),
      (
        icone: LucideIcons.user,
        label: 'Profil',
        page: const ProfileScreen(),
        barre: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final onglets = _getOnglets();
    if (_index >= onglets.length) _index = 0;
    final pages = onglets.map((o) => o.page).toList();

    return Scaffold(
      key: _cleScaffold,
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      drawer: _menuLateral(onglets),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              transitionBuilder: (child, animation) {
                final isIncoming = (child.key is ValueKey<int>) &&
                    (child.key as ValueKey<int>).value == _index;

                final isForward = _index >= _previousIndex;
                final double startX = isIncoming
                    ? (isForward ? 0.08 : -0.08)
                    : (isForward ? -0.08 : 0.08);

                final slideAnim = Tween<Offset>(
                  begin: Offset(startX, 0.012),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                );

                final scaleAnim = Tween<double>(
                  begin: 0.94,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                );

                final fadeAnim = CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.0, 0.85, curve: Curves.easeOut),
                );

                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) {
                    final sigma = (1.0 - animation.value).clamp(0.0, 1.0) * 3.5;
                    return FadeTransition(
                      opacity: fadeAnim,
                      child: SlideTransition(
                        position: slideAnim,
                        child: ScaleTransition(
                          scale: scaleAnim,
                          child: sigma > 0.1
                              ? ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                    sigmaX: sigma,
                                    sigmaY: sigma,
                                  ),
                                  child: child,
                                )
                              : child,
                        ),
                      ),
                    );
                  },
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(_index),
                child: pages[_index],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(canvasColor: Colors.transparent),
        child: _pillBottomBar(onglets),
      ),
    );
  }

  // ==================== APP BAR STYLE DÉGRADÉ (STYLE META FLEET) ====================
  PreferredSizeWidget _buildAppBar() {
    final configCtrl = Get.isRegistered<ConfigController>()
        ? Get.find<ConfigController>()
        : null;

    return AppBar(
      toolbarHeight: 48,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.95),
              Colors.white.withOpacity(0.70),
              Colors.white.withOpacity(0.0),
            ],
            stops: const [0.0, 0.70, 1.0],
          ),
        ),
      ),
      automaticallyImplyLeading: false,
      titleSpacing: 4,
      title: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.menu, size: 22),
            color: configCtrl?.primaryColor ?? AppTheme.primary,
            onPressed: () => _cleScaffold.currentState?.openDrawer(),
          ),
          const SizedBox(width: 2),
          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: (configCtrl?.secondaryColor ?? AppTheme.primaryIcons).withOpacity(0.4),
              ),
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
              errorBuilder: (_, __, ___) => Icon(
                LucideIcons.truck,
                color: configCtrl?.secondaryColor ?? AppTheme.primaryIcons,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ShaderMask(
            shaderCallback: (bounds) =>
                (configCtrl?.brandGradient ?? AppTheme.iconGradient).createShader(bounds),
            child: Text(
              'METACLIENT',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Bouton Recherche rapide
        _appBarGlassButton(
          icon: LucideIcons.search,
          onTap: () => _changerOnglet(1),
        ),
        const SizedBox(width: 8),
        // Bouton Profil
        _boutonProfil(),
        const SizedBox(width: 14),
      ],
    );
  }

  Widget _boutonProfil() {
    return Obx(() {
      final client = _authController.clientInfo.value;
      final user = _authController.currentUser.value;
      final photoBase64 = _authController.profilePhoto.value;
      Uint8List? photoBytes;
      if (photoBase64 != null && photoBase64.trim().isNotEmpty) {
        try {
          String clean = photoBase64.trim();
          if (clean.contains(',')) clean = clean.split(',').last;
          photoBytes = base64Decode(clean);
        } catch (_) {}
      }

      final nom = client?.raisonSociale.isNotEmpty == true
          ? client!.raisonSociale
          : (user?.libelle ?? 'C');
      final lettre = nom.isNotEmpty ? nom[0].toUpperCase() : 'C';

      void ouvrir() => _changerOnglet(5);

      final isProfileActive = _index == 5;

      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isProfileActive ? AppTheme.primaryGradient : null,
          color: isProfileActive ? null : Colors.white.withOpacity(0.85),
          border: Border.all(
            color: isProfileActive ? Colors.white : const Color(0xFFE2E8F0),
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: ouvrir,
            child: photoBytes != null
                ? ClipOval(
                    child: Image.memory(
                      photoBytes,
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                    ),
                  )
                : Center(
                    child: Text(
                      lettre,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isProfileActive ? Colors.white : AppTheme.primary,
                      ),
                    ),
                  ),
          ),
        ),
      );
    });
  }

  Widget _appBarGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: Colors.white.withOpacity(0.85),
            shape: const CircleBorder(
              side: BorderSide(color: Colors.white, width: 1.2),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, color: AppTheme.primary, size: 18),
                  if (hasBadge)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryIcons,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== BARRE DE NAVIGATION FLOTTANTE (GLASSMORPHISM STYLE META FLEET) ====================
  Widget _pillBottomBar(
    List<({IconData icone, String label, Widget page, bool barre})> onglets,
  ) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        14,
        0,
        14,
        bottomPadding > 0 ? bottomPadding + 6 : 14,
      ),
      child: Container(
        height: 74,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.12),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppTheme.primaryIcons.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.92),
                    Colors.white.withOpacity(0.70),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.95),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < onglets.length; i++)
                    if (onglets[i].barre)
                      _navItem(i, onglets[i].icone, onglets[i].label),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, String label) {
    final active = _index == idx;
    final configCtrl = Get.isRegistered<ConfigController>()
        ? Get.find<ConfigController>()
        : null;

    return GestureDetector(
      onTap: () => _changerOnglet(idx),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: active ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: active ? 36 : 26,
                height: active ? 36 : 26,
                decoration: active
                    ? BoxDecoration(
                        gradient: configCtrl?.buttonGradient ?? AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (configCtrl?.primaryColor ?? AppTheme.primary).withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      )
                    : null,
                child: Icon(
                  icon,
                  color: active ? Colors.white : const Color(0xFF64748B),
                  size: active ? 18 : 19,
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                height: 1.15,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? AppTheme.primary : const Color(0xFF94A3B8),
              ),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== MENU VERTICAL LATÉRAL (DRAWER STYLE META FLEET) ====================
  Widget _menuLateral(
    List<({IconData icone, String label, Widget page, bool barre})> onglets,
  ) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              children: [
                _enteteMenu(),
                const SizedBox(height: 14),
                _champRechercheMenu(),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.only(left: 6, bottom: 8),
                  child: Text(
                    'Raccourcis',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
                for (var i = 0; i < onglets.length; i++)
                  if (_correspond(onglets[i].label))
                    _ligneMenu(
                      icone: onglets[i].icone,
                      label: onglets[i].label,
                      actif: _index == i,
                      onTap: () {
                        _changerOnglet(i);
                        Navigator.of(context).pop();
                      },
                    ),
                const SizedBox(height: 14),
                const Divider(color: Color(0xFFE2E8F0), height: 1),
                const SizedBox(height: 14),
                if (_correspond('Déconnexion'))
                  _ligneMenu(
                    icone: LucideIcons.logOut,
                    label: 'Déconnexion',
                    couleur: const Color(0xFFDC2626),
                    onTap: () {
                      Navigator.of(context).pop();
                      _authController.logout();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _enteteMenu() {
    return Obx(() {
      final client = _authController.clientInfo.value;
      final user = _authController.currentUser.value;
      final nom = client?.raisonSociale.isNotEmpty == true
          ? client!.raisonSociale
          : (user?.libelle ?? 'Client');
      final code = client?.code.isNotEmpty == true ? client!.code : (user?.code ?? '');
      final agence = client?.agenceAffectation ?? 'Réseau National';
      final lettre = nom.isNotEmpty ? nom[0].toUpperCase() : 'C';

      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            setState(() => _index = 5);
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.92),
                  Colors.white.withOpacity(0.70),
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.95)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: (Get.isRegistered<ConfigController>()
                        ? Get.find<ConfigController>().buttonGradient
                        : AppTheme.primaryGradient),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    lettre,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nom,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Code: $code • $agence',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  size: 17,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _champRechercheMenu() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.95),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: TextField(
          controller: _rechercheMenu,
          onChanged: (val) =>
              setState(() => _filtreMenu = val.trim().toLowerCase()),
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: 'Rechercher dans le menu…',
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF94A3B8),
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 14, right: 8),
              child: Icon(
                LucideIcons.search,
                size: 18,
                color: AppTheme.primary,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            suffixIcon: _filtreMenu.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(
                      LucideIcons.x,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                    onPressed: () {
                      _rechercheMenu.clear();
                      setState(() => _filtreMenu = '');
                    },
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _ligneMenu({
    required IconData icone,
    required String label,
    required VoidCallback onTap,
    bool actif = false,
    Color? couleur,
  }) {
    final configCtrl = Get.isRegistered<ConfigController>()
        ? Get.find<ConfigController>()
        : null;
    final teinte = couleur ?? (configCtrl?.primaryColor ?? AppTheme.primary);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: actif
            ? teinte.withOpacity(0.12)
            : Colors.white.withOpacity(0.60),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icone, size: 19, color: teinte),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: actif ? FontWeight.w700 : FontWeight.w600,
                      color: couleur ?? const Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (actif)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: teinte,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
