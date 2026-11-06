class ChequeCrbtModel {
  final int idCheque;
  final String numCheque;
  final String? dateImpression;
  final String? banque;
  final String? dateRemise;
  final num montant;
  final String? typeRemboursement;

  ChequeCrbtModel({
    required this.idCheque,
    required this.numCheque,
    this.dateImpression,
    this.banque,
    this.dateRemise,
    required this.montant,
    this.typeRemboursement,
  });

  factory ChequeCrbtModel.fromJson(Map<String, dynamic> json) {
    return ChequeCrbtModel(
      idCheque: (json['id_cheque'] as num?)?.toInt() ?? 0,
      numCheque: json['num_cheque']?.toString() ?? '',
      dateImpression: json['dateimpression']?.toString(),
      banque: json['banque']?.toString(),
      dateRemise: json['dateremise']?.toString(),
      montant: (json['montant'] as num?) ?? 0,
      typeRemboursement:
          (json['typeRemboursement'] ??
                  json['type_remboursement'] ??
                  json['typeRemb'] ??
                  json['type_remb'] ??
                  json['type'])
              ?.toString(),
    );
  }
}

class ChequeCrbtDetailItem {
  final String? refReglement;
  final String? modeReglement;
  final String numDeclaration;
  final String? dateValidation;
  final String? destination;
  final num montant;
  final String? destinataire;
  final String? dateEmission;
  final String? typeRemboursement;

  ChequeCrbtDetailItem({
    this.refReglement,
    this.modeReglement,
    required this.numDeclaration,
    this.dateValidation,
    this.destination,
    required this.montant,
    this.destinataire,
    this.dateEmission,
    this.typeRemboursement,
  });

  factory ChequeCrbtDetailItem.fromJson(Map<String, dynamic> json) {
    return ChequeCrbtDetailItem(
      refReglement: json['ref_reglement']?.toString(),
      modeReglement: json['mode_reglement']?.toString(),
      numDeclaration: json['num_declaration']?.toString() ?? '',
      dateValidation: json['date_validation']?.toString(),
      destination: json['destination']?.toString(),
      montant: (json['montant'] as num?) ?? 0,
      destinataire: json['destinataire']?.toString(),
      dateEmission: json['date_emission']?.toString(),
      typeRemboursement:
          (json['typeRemboursement'] ??
                  json['type_remboursement'] ??
                  json['typeRemb'] ??
                  json['type_remb'] ??
                  json['type'])
              ?.toString(),
    );
  }
}

class VirementCrbtModel {
  final int idVirement;
  final String? dateMandat;
  final String? codeClient;
  final String? dateVirement;
  final String numOv;
  final String? libelleClient;
  final String? numeroMandat;
  final String? status;
  final num fond;

  VirementCrbtModel({
    required this.idVirement,
    this.dateMandat,
    this.codeClient,
    this.dateVirement,
    required this.numOv,
    this.libelleClient,
    this.numeroMandat,
    this.status,
    required this.fond,
  });

  factory VirementCrbtModel.fromJson(Map<String, dynamic> json) {
    return VirementCrbtModel(
      idVirement: (json['id_virement'] as num?)?.toInt() ?? 0,
      dateMandat: json['date_mandat']?.toString(),
      codeClient: json['code_client']?.toString(),
      dateVirement: json['date_virement']?.toString(),
      numOv: json['num_ov']?.toString() ?? '',
      libelleClient: json['libelle_client']?.toString(),
      numeroMandat: json['numero_mandat']?.toString(),
      status: json['status']?.toString(),
      fond: (json['fond'] as num?) ?? 0,
    );
  }
}

class VirementCrbtDetailItem {
  final String? refReglement;
  final String? modeReglement;
  final String numDeclaration;
  final String? dateValidation;
  final String? destination;
  final num montant;
  final String? destinataire;
  final String? dateEmission;

  VirementCrbtDetailItem({
    this.refReglement,
    this.modeReglement,
    required this.numDeclaration,
    this.dateValidation,
    this.destination,
    required this.montant,
    this.destinataire,
    this.dateEmission,
  });

  factory VirementCrbtDetailItem.fromJson(Map<String, dynamic> json) {
    return VirementCrbtDetailItem(
      refReglement: json['ref_reglement']?.toString(),
      modeReglement: json['mode_reglement']?.toString(),
      numDeclaration: json['num_declaration']?.toString() ?? '',
      dateValidation: json['date_validation']?.toString(),
      destination: json['destination']?.toString(),
      montant: (json['montant'] as num?) ?? 0,
      destinataire: json['destinataire']?.toString(),
      dateEmission: json['date_emission']?.toString(),
    );
  }
}
