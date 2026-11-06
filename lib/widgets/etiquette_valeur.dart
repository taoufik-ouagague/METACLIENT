import 'package:flutter/material.dart';

/// « Intitule : valeur » sur une seule ligne de texte.
///
/// L'intitule reste neutre et la valeur porte la couleur de son champ : tout
/// en gris, les cartes de liste se lisaient comme un bloc.
class EtiquetteValeur extends StatelessWidget {
  const EtiquetteValeur({
    super.key,
    required this.intitule,
    required this.valeur,
    required this.couleur,
    this.taille = 11.5,
    this.lignes = 1,
    this.couleurIntitule = const Color(0xFF94A3B8),
  });

  final String intitule;
  final String valeur;
  final Color couleur;
  final double taille;

  /// Couleur de l'intitule. Le gris clair par defaut convient aux champs
  /// secondaires ; un en-tete de carte demande plus d'assise.
  final Color couleurIntitule;

  /// Nombre de lignes avant la coupe. Au-dela de 1, le texte se replie au
  /// lieu d'etre tronque.
  final int lignes;

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: lignes,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: intitule,
            style: TextStyle(color: couleurIntitule, fontSize: taille),
          ),
          TextSpan(
            text: valeur,
            style: TextStyle(
              color: couleur,
              fontSize: taille,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
