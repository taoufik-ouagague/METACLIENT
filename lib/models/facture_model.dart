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
  final String? couleur;
  final num? delaiReglement;

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
    this.couleur,
    this.delaiReglement,
  });

  factory FactureModel.fromJson(Map<String, dynamic> json) {
    return FactureModel(
      idFacture: json['id_facture'] as int?,
      numFacture: json['num_facture']?.toString() ?? '',
      code: json['code']?.toString(),
      dateFacture: json['date_facture']?.toString(),
      dateEcheance:
          (json['date_echeance'] ?? json['dateEcheance'])?.toString(),
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
      statut: json['statut']?.toString() ?? json['status']?.toString(),
      couleur: json['couleur']?.toString() ?? json['color']?.toString(),
      delaiReglement:
          (json['delai_reglement'] ?? json['delaiReglement']) as num?,
    );
  }

  bool get isPayee =>
      couleur?.toLowerCase() == 'green' ||
      ((solde == null || solde == 0) &&
          (statut != null && statut!.toLowerCase().contains('cloture')));

  bool get isEnCours => couleur?.toLowerCase() == 'orange';

  bool get isEnRetard =>
      couleur?.toLowerCase() == 'red' ||
      (couleur == null && solde != null && solde! > 0);

  FactureModel mergeWith(FactureModel other) {
    return FactureModel(
      idFacture: idFacture ?? other.idFacture,
      numFacture: numFacture.isNotEmpty ? numFacture : other.numFacture,
      code: (code != null && code!.isNotEmpty) ? code : other.code,
      dateFacture: (dateFacture != null && dateFacture!.isNotEmpty)
          ? dateFacture
          : other.dateFacture,
      dateEcheance: (dateEcheance != null && dateEcheance!.isNotEmpty)
          ? dateEcheance
          : other.dateEcheance,
      dateRemise: dateRemise ?? other.dateRemise,
      libelle:
          (libelle != null && libelle!.isNotEmpty) ? libelle : other.libelle,
      mntRegle: mntRegle ?? other.mntRegle,
      remise: remise ?? other.remise,
      tauxRemise: tauxRemise ?? other.tauxRemise,
      mntAvoir: mntAvoir ?? other.mntAvoir,
      mntTva: mntTva ?? other.mntTva,
      solde: solde ?? other.solde,
      mntHt: mntHt ?? other.mntHt,
      mntTtc: mntTtc ?? other.mntTtc,
      statut: (statut != null && statut!.isNotEmpty) ? statut : other.statut,
      couleur:
          (couleur != null && couleur!.isNotEmpty) ? couleur : other.couleur,
      delaiReglement: delaiReglement ?? other.delaiReglement,
    );
  }
}
