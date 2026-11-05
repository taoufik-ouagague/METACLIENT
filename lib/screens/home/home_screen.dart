import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/auth_controller.dart';
import '../notifications/notifications_screen.dart';
import '../expeditions/tracking_screen.dart';
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

  List<
    ({IconData icone, String label, String labelMenu, Widget page, bool barre})
  >
  _getOnglets() {
    return [
      (
        icone: LucideIcons.home,
        label: 'Accueil',
        labelMenu: 'Accueil',
        page: DashboardTab(onNavigateTab: (target) => _changerOnglet(target)),
        barre: true,
      ),
      (
        icone: LucideIcons.truck,
        label: 'Expéditions',
        labelMenu: 'Expéditions',
        page: const ExpeditionsScreen(),
        barre: true,
      ),
      (
        icone: LucideIcons.fileText,
        label: 'Factures',
        labelMenu: 'Factures',
        page: const FacturesScreen(),
        barre: true,
      ),
      (
        icone: LucideIcons.rotateCcw,
        label: 'CT/BL',
        labelMenu: 'R/FOND/DOC',
        page: const RetoursScreen(),
        barre: true,
      ),
      (
        icone: LucideIcons.banknote,
        label: 'CRBT',
        labelMenu: 'CRBT',
        page: const CrbtScreen(),
        barre: true,
      ),
      (
        icone: LucideIcons.user,
        label: 'Profil',
        labelMenu: 'Profil',
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
          // Le degrade appartient a la page, pas au bandeau : il traverse la
          // barre (transparente) et s'eteint doucement plus bas, si bien que
          // l'en-tete ne se lit plus comme un bloc rapporte.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 330,
            child: IgnorePointer(
              child: RepaintBoundary(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF1B7A94),
                        AppTheme.primary,
                        const Color(0xFF3FC1D8),
                        AppTheme.accentCyan.withValues(alpha: 0),
                      ],
                      stops: const [0.0, 0.20, 0.40, 1.0],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: -60,
                        top: -70,
                        child: _halo(220, Colors.white.withValues(alpha: 0.18)),
                      ),
                      Positioned(
                        right: -80,
                        top: 10,
                        child: _halo(
                          240,
                          AppTheme.accentCyan.withValues(alpha: 0.30),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 340),
              // Les courbes sont appliquees une seule fois, dans le builder.
              switchInCurve: Curves.linear,
              switchOutCurve: Curves.linear,
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[...previousChildren, ?currentChild],
                );
              },
              transitionBuilder: (child, animation) {
                final isIncoming =
                    (child.key is ValueKey<int>) &&
                    (child.key as ValueKey<int>).value == _index;

                final isForward = _index >= _previousIndex;

                // Glissement pleine largeur : la page sortante quitte d'un
                // cote, l'entrante arrive de l'autre. Pas de fondu ni de flou :
                // les deux pages resteraient visibles l'une sur l'autre.
                final double departX = isIncoming
                    ? (isForward ? 1.0 : -1.0)
                    : (isForward ? -1.0 : 1.0);

                return SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: Offset(departX, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOutCubic,
                        ),
                      ),
                  child: child,
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
    return AppBar(
      toolbarHeight: 48,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      // Sur fond teinte, les icones systeme passent en clair.
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      automaticallyImplyLeading: false,
      titleSpacing: 4,
      title: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.menu, size: 22),
            color: Colors.white,
            onPressed: () => _cleScaffold.currentState?.openDrawer(),
          ),
          const SizedBox(width: 2),
          // Le degrade du logo (bleu nuit -> cyan) disparaitrait sur le
          // bandeau teinte : le mot passe en blanc plein.
          Text(
            'METACLIENT',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        // Bouton Recherche rapide
        _appBarGlassButton(
          icon: LucideIcons.search,
          onTap: () => Get.to<void>(
            () => const TrackingScreen(),
            transition: Transition.cupertino,
            duration: const Duration(milliseconds: 360),
          ),
        ),
        const SizedBox(width: 8),
        // Bouton Notifications
        _appBarGlassButton(
          icon: LucideIcons.bell,
          onTap: () => Get.to<void>(
            () => const NotificationsScreen(),
            transition: Transition.cupertino,
            duration: const Duration(milliseconds: 360),
          ),
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
          : (user?.libelle ?? '');

      void ouvrir() => _changerOnglet(5);

      final isProfileActive = _index == 5;

      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: isProfileActive ? 0.92 : 0.24),
          border: Border.all(
            color: Colors.white.withValues(alpha: isProfileActive ? 1 : 0.50),
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.15),
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
                    child: Icon(
                      LucideIcons.user,
                      size: 19,
                      semanticLabel: nom.isNotEmpty ? nom : 'Profil',
                      color: isProfileActive ? AppTheme.primary : Colors.white,
                    ),
                  ),
          ),
        ),
      );
    });
  }

  /// Tache de lumiere diffuse posee dans le bandeau.
  Widget _halo(double taille, Color couleur) {
    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [couleur, couleur.withValues(alpha: 0)],
        ),
      ),
    );
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
            color: AppTheme.primary.withValues(alpha: 0.08),
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
            color: Colors.white.withValues(alpha: 0.24),
            shape: CircleBorder(
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.50),
                width: 1.3,
              ),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 18),
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
    List<
      ({
        IconData icone,
        String label,
        String labelMenu,
        Widget page,
        bool barre,
      })
    >
    onglets,
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
              color: AppTheme.primary.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppTheme.primaryIcons.withValues(alpha: 0.08),
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
                    Colors.white.withValues(alpha: 0.92),
                    Colors.white.withValues(alpha: 0.70),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.95),
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
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.35),
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
    List<
      ({
        IconData icone,
        String label,
        String labelMenu,
        Widget page,
        bool barre,
      })
    >
    onglets,
  ) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Le tiroir prolonge la page : le meme bandeau degrade qu'en haut
          // de l'accueil, qui s'eteint dans le fond clair du corps. Un bleu
          // nuit plein se lisait comme une autre application.
          const AmbientBackground(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: IgnorePointer(
              child: RepaintBoundary(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF1B7A94),
                        AppTheme.primary,
                        const Color(0xFF3FC1D8),
                        AppTheme.accentCyan.withValues(alpha: 0),
                      ],
                      stops: const [0.0, 0.22, 0.45, 1.0],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: -70,
                        top: -60,
                        child: _halo(200, Colors.white.withValues(alpha: 0.16)),
                      ),
                      Positioned(
                        right: -70,
                        top: 20,
                        child: _halo(
                          210,
                          AppTheme.accentCyan.withValues(alpha: 0.28),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            // La deconnexion ne defile plus avec les raccourcis : elle est
            // ancree en bas, ou on la cherche, quel que soit le nombre
            // d'entrees ou le filtre de recherche.
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                  child: Column(
                    children: [
                      _enteteMenu(),
                      const SizedBox(height: 14),
                      _champRechercheMenu(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 6, bottom: 8),
                        child: Text(
                          'Raccourcis',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            color: const Color(0xFF8CA0B6),
                          ),
                        ),
                      ),
                      for (var i = 0; i < onglets.length; i++)
                        if (_correspond(onglets[i].labelMenu))
                          _ligneMenu(
                            icone: onglets[i].icone,
                            label: onglets[i].labelMenu,
                            actif: _index == i,
                            onTap: () {
                              _changerOnglet(i);
                              Navigator.of(context).pop();
                            },
                          ),
                    ],
                  ),
                ),
                if (_correspond('Déconnexion'))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
                    child: _ligneDeconnexion(),
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
      final code = client?.code.isNotEmpty == true
          ? client!.code
          : (user?.code ?? '');
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
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.80),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.95),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryIcons.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: AppTheme.iconGradient,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
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
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.95),
          width: 1.2,
        ),
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
                color: AppTheme.primaryIcons,
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: DecoratedBox(
        decoration: BoxDecoration(
          // Entree courante : le cyan du logo, comme sur l'ecran de connexion.
          gradient: actif ? AppTheme.iconGradient : null,
          color: actif ? null : Colors.white.withValues(alpha: 0.80),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: actif ? 0.55 : 0.95),
            width: 1.2,
          ),
          boxShadow: actif
              ? [
                  BoxShadow(
                    color: AppTheme.primaryIcons.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    icone,
                    size: 19,
                    color: actif ? Colors.white : AppTheme.primaryIcons,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: actif ? FontWeight.w700 : FontWeight.w600,
                        color: actif ? Colors.white : const Color(0xFF28394D),
                      ),
                    ),
                  ),
                  if (actif)
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: Colors.white,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Deconnexion : meme dessin que les raccourcis, en rouge assume.
  Widget _ligneDeconnexion() {
    const rouge = Color(0xFFDC2626);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFBD5D5), width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
            _authController.logout();
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            child: Row(
              children: [
                const Icon(LucideIcons.logOut, size: 19, color: rouge),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    'Déconnexion',
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: rouge,
                    ),
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
