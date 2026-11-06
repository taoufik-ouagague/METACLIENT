import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';
import 'squelette.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? color;

  /// Tant que la donnee n'est pas arrivee, la valeur et le libelle sont
  /// remplaces par des barres a reflet, a hauteur identique.
  final bool chargement;

  /// Carte de tete : pleine largeur, chiffre deux fois plus gros.
  ///
  /// Dix tuiles de meme taille ne hierarchisent rien ; celle-ci porte le
  /// chiffre que le client vient chercher en premier.
  final bool vedette;

  /// Complement pose a droite du chiffre, sur la carte de tete seulement.
  /// Il remplit la moitie restee vide et acheve la phrase que la carte
  /// commence (« ... DH dus, sur 7 factures »).
  final String? complement;

  /// Grise la tuile quand son compteur est a zero : elle reste lisible, mais
  /// l'oeil ne s'y arrete plus.
  final bool attenue;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.onTap,
    this.color,
    this.chargement = false,
    this.vedette = false,
    this.complement,
    this.attenue = false,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _presse = false;

  void _presser(bool actif) {
    if (widget.onTap == null || _presse == actif) return;
    setState(() => _presse = actif);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accent = widget.color ?? AppTheme.primaryIcons;
    final vedette = widget.vedette;

    final carte = GlassContainer(
      borderRadius: 16,
      // Teinte a peine posee : elle rattache la tuile a sa famille de couleur
      // sans que la grille vire au bariole.
      color: Color.alphaBlend(
        accent.withValues(alpha: 0.05),
        Colors.white.withValues(alpha: 0.88),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: vedette ? 17 : 13,
        vertical: vedette ? 15 : 10,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Icone fantome : un filigrane dans l'angle, pas un motif. Plus
          // grande, elle passait derriere le libelle et se lisait comme un
          // trait de plus ; on la rentre dans le coin pour n'en laisser qu'une
          // amorce, que le ClipRRect du GlassContainer recoupe.
          //
          // La vedette s'en passe : son chiffre suffit a accrocher l'oeil, et
          // le filigrane y restait assez grand pour se lire comme une forme.
          if (!vedette)
            Positioned(
              right: -10,
              bottom: -14,
              child: Icon(
                widget.icon,
                size: 46,
                color: accent.withValues(alpha: 0.055),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(vedette ? 8 : 6),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(vedette ? 12 : 10),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: accent,
                      size: vedette ? 20 : 16,
                    ),
                  ),
                  if (widget.subtitle != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.subtitle!,
                        style: TextStyle(
                          color: accent,
                          fontSize: vedette ? 11 : 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: vedette ? 12 : 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: widget.chargement
                          ? Squelette(
                              width: vedette ? 150 : 58,
                              height: vedette ? 31 : 19,
                              radius: 7,
                            )
                          : _valeurAnimee(
                              TextStyle(
                                color: isLight
                                    ? const Color(0xFF0F172A)
                                    : Colors.white,
                                fontSize: vedette ? 31 : 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                    ),
                  ),
                  if (vedette &&
                      widget.complement != null &&
                      !widget.chargement)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              widget.complement!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: accent,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 17,
                            color: accent,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: vedette ? 4 : 2),
              if (widget.chargement)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Squelette(height: 10, radius: 5),
                )
              else
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isLight
                        ? const Color(0xFF64748B)
                        : Colors.white.withValues(alpha: 0.7),
                    fontSize: vedette ? 13 : 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          // Filet d'accent au ras du bord bas : la couleur de la tuile se lit
          // enfin d'un coup d'oeil, l'icone seule etait trop petite pour ca.
          Positioned(
            left: vedette ? -17 : -13,
            right: vedette ? -17 : -13,
            bottom: vedette ? -15 : -10,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.35)],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Pendant le chargement la valeur vaut encore zero : attenuer la tuile a
    // ce moment-la ferait clignoter la grille.
    final rendu = widget.attenue && !widget.chargement
        ? Opacity(opacity: 0.55, child: carte)
        : carte;

    if (widget.onTap == null) return rendu;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _presser(true),
      onTapUp: (_) => _presser(false),
      onTapCancel: () => _presser(false),
      child: AnimatedScale(
        scale: _presse ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: rendu,
      ),
    );
  }

  /// Un compteur defile jusqu'a sa valeur ; les montants, deja formates en
  /// chaine, ne peuvent pas etre interpoles et arrivent donc en fondu.
  ///
  /// Les donnees du tableau de bord arrivent apres le premier rendu : la carte
  /// est construite a zero, puis l'animation part de la valeur affichee vers
  /// la nouvelle (TweenAnimationBuilder n'utilise `begin` qu'au premier build).
  Widget _valeurAnimee(TextStyle style) {
    final cible = int.tryParse(widget.value);

    if (cible == null) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        transitionBuilder: (enfant, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.35),
              end: Offset.zero,
            ).animate(animation),
            child: enfant,
          ),
        ),
        child: Text(
          widget.value,
          key: ValueKey<String>(widget.value),
          maxLines: 1,
          style: style,
        ),
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: cible.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, valeur, _) =>
          Text('${valeur.round()}', maxLines: 1, style: style),
    );
  }
}
