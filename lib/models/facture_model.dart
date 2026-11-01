class FactureModel {
  final int? idFacture;
  final String numFacture;
  final String? code;
  final String? dateFacture;
  final String? dateEcheance;
  final String? dateRemise;
  final String? libelle;
  final num? mntRegle;
  final num? remise;
  final num? tauxRemise;
  final num? mntAvoir;
  final num? mntTva;
  final num? solde;
  final num? mntHt;
  final num? mntTtc;
  final String? statut;

  FactureModel({
    this.idFacture,
    required this.numFacture,
    this.code,
    this.dateFacture,
    this.dateEcheance,
    this.dateRemise,
    this.libelle,
    this.mntRegle,
    this.remise,
    this.tauxRemise,
    this.mntAvoir,
    this.mntTva,
    this.solde,
    this.mntHt,
    this.mntTtc,
    this.statut,
  });

  factory FactureModel.fromJson(Map<String, dynamic> json) {
    return FactureModel(
      idFacture: json['id_facture'] as int?,
      numFacture: json['num_facture']?.toString() ?? '',
      code: json['code']?.toString(),
      dateFacture: json['date_facture']?.toString(),
      dateEcheance: json['date_echeance']?.toString(),
      dateRemise: json['date_remise']?.toString(),
      libelle: json['libelle']?.toString(),
      mntRegle: json['mnt_regle'] as num?,
      remise: json['remise'] as num?,
      tauxRemise: json['taux_remise'] as num?,
      mntAvoir: json['mnt_avoir'] as num?,
      mntTva: json['mnt_tva'] as num?,
      solde: json['solde'] as num?,
      mntHt: json['mnt_ht'] as num?,
      mntTtc: (json['mnt_ttc'] ?? json['mnt_Ʃc']) as num?,
      statut: json['statut']?.toString(),
    );
  }

  bool get isPayee =>
      (solde == null || solde == 0) &&
      (statut != null && statut!.toLowerCase().contains('cloture'));
}
