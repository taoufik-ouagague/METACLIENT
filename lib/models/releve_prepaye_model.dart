/// Une ligne du releve prepaye : une alimentation (credit) ou une
/// consommation (debit) du compte.
class RelevePrepayeModel {
  final String? classe;
  final String? client;
  final String? dateDebut;
  final String? dateFin;
  final String? dateOperation;
  final num? debit;
  final num? credit;
  final String? operation;
  final String? etat;

  const RelevePrepayeModel({
    this.classe,
    this.client,
    this.dateDebut,
    this.dateFin,
    this.dateOperation,
    this.debit,
    this.credit,
    this.operation,
    this.etat,
  });

  /// Sens de la ligne, lu sur `operation` et non sur debit/credit.
  ///
  /// L'API place le montant dans `credit` meme pour une consommation (vu sur
  /// « Consommation » a 2500,50 avec `debit: 0`), donc les deux colonnes ne
  /// disent pas le sens. Le libelle, lui, le dit. Si un jour `debit` est
  /// correctement rempli, la regle reste juste.
  bool get estCredit {
    final op = (operation ?? '').toLowerCase();
    if (op.contains('consommation')) return false;
    if (op.contains('aliment')) return true;
    // Libelle inconnu : on retombe sur la colonne qui porte un montant.
    return (credit ?? 0) >= (debit ?? 0);
  }

  /// Montant de la ligne, quel que soit la colonne qui le porte.
  num get montant {
    final c = credit ?? 0;
    final d = debit ?? 0;
    return c != 0 ? c : d;
  }

  /// Ce que la ligne ajoute (positif) ou retire (negatif) au solde.
  num get mouvement => estCredit ? montant : -montant;

  factory RelevePrepayeModel.fromJson(Map<String, dynamic> json) {
    num? nombre(Object? valeur) {
      if (valeur == null) return null;
      if (valeur is num) return valeur;
      return num.tryParse(valeur.toString().replaceAll(',', '.'));
    }

    return RelevePrepayeModel(
      classe: json['classe']?.toString(),
      client: json['client']?.toString(),
      dateDebut: json['dateDebut']?.toString(),
      dateFin: json['dateFin']?.toString(),
      dateOperation: json['date_operation']?.toString(),
      debit: nombre(json['debit']),
      credit: nombre(json['credit']),
      operation: json['operation']?.toString(),
      etat: json['etat']?.toString(),
    );
  }
}
