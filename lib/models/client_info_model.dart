class ClientInfoModel {
  final String code;
  final String raisonSociale;
  final String? agenceAffectation;
  final String? commercialLibelle;
  final String? adresse;
  final String? commercialTelephone;
  final String? telephone;
  final String? commercialEmail;
  final String? email;
  final String? secteurAffectation;

  ClientInfoModel({
    required this.code,
    required this.raisonSociale,
    this.agenceAffectation,
    this.commercialLibelle,
    this.adresse,
    this.commercialTelephone,
    this.telephone,
    this.commercialEmail,
    this.email,
    this.secteurAffectation,
  });

  factory ClientInfoModel.fromJson(Map<String, dynamic> json) {
    return ClientInfoModel(
      code: json['code']?.toString() ?? '',
      raisonSociale: json['raison_sociale']?.toString() ?? '',
      agenceAffectation: json['agence_affectation']?.toString(),
      commercialLibelle: json['commercial_libelle']?.toString(),
      adresse: json['adresse']?.toString(),
      commercialTelephone: json['commercial_telephone']?.toString(),
      telephone: json['telephone']?.toString(),
      commercialEmail: json['commercial_email']?.toString(),
      email: json['email']?.toString(),
      secteurAffectation: json['secteur_affectation']?.toString(),
    );
  }
}
