class FactureAvoir {
  final String numAvoir;
  final num montant;
  final String? remarque;
  final String? dateCreation;

  FactureAvoir({
    required this.numAvoir,
    required this.montant,
    this.remarque,
    this.dateCreation,
  });

  factory FactureAvoir.fromJson(Map<String, dynamic> json) {
    return FactureAvoir(
      numAvoir: json['num_avoir']?.toString() ?? '',
      montant: (json['montant'] as num?) ?? 0,
      remarque: json['remarque']?.toString(),
      dateCreation: json['date_creation']?.toString(),
    );
  }
}

class FactureReglement {
  final String refReglement;
  final String modeReglement;
  final num montant;
  final String? dateCreation;

  FactureReglement({
    required this.refReglement,
    required this.modeReglement,
    required this.montant,
    this.dateCreation,
  });

  factory FactureReglement.fromJson(Map<String, dynamic> json) {
    return FactureReglement(
      refReglement: json['ref_reglement']?.toString() ?? '',
      modeReglement: json['mode_reglement']?.toString() ?? '',
      montant: (json['montant'] as num?) ?? 0,
      dateCreation: json['date_creation']?.toString(),
    );
  }
}

class FactureDetailModel {
  final List<FactureAvoir> avoirs;
  final List<FactureReglement> reglements;

  FactureDetailModel({
    required this.avoirs,
    required this.reglements,
  });

  factory FactureDetailModel.fromJson(Map<String, dynamic> json) {
    final rawAvoirs = json['avoirs'] as List? ?? [];
    final rawReglements = json['reglements'] as List? ?? [];

    return FactureDetailModel(
      avoirs: rawAvoirs.map((e) => FactureAvoir.fromJson(Map<String, dynamic>.from(e))).toList(),
      reglements: rawReglements
          .map((e) => FactureReglement.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
