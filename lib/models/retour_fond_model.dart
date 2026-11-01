class RetourFondModel {
  final String nature;
  final String? dateAffectation;
  final String? destination;
  final String? bordereau;
  final String? destinataire;
  final String? dateReception;
  final int? idExpedition;
  final String? dateEnvoi;
  final num? fond;
  final String? dateRemise;
  final String? dateEncaissement;
  final dynamic cfkBrd;
  final String? numDeclaration;
  final String? port;
  final String? typeExpedition;
  final String? modereglement;
  final String? banque;
  final String? numPiece;
  final num? mntHt;
  final num? mntTtc;

  RetourFondModel({
    required this.nature,
    this.dateAffectation,
    this.destination,
    this.bordereau,
    this.destinataire,
    this.dateReception,
    this.idExpedition,
    this.dateEnvoi,
    this.fond,
    this.dateRemise,
    this.dateEncaissement,
    this.cfkBrd,
    this.numDeclaration,
    this.port,
    this.typeExpedition,
    this.modereglement,
    this.banque,
    this.numPiece,
    this.mntHt,
    this.mntTtc,
  });

  factory RetourFondModel.fromJson(Map<String, dynamic> json) {
    return RetourFondModel(
      nature: json['nature']?.toString() ?? '',
      dateAffectation: json['date_affectation']?.toString(),
      destination: json['destination']?.toString(),
      bordereau: json['bordereau']?.toString(),
      destinataire: json['destinataire']?.toString(),
      dateReception: json['date_reception']?.toString(),
      idExpedition: json['id_expedition'] as int?,
      dateEnvoi: json['date_envoi']?.toString(),
      fond: json['fond'] as num?,
      dateRemise: json['date_remise']?.toString(),
      dateEncaissement: json['date_encaissement']?.toString(),
      cfkBrd: json['cfkBrd'] ?? json['cŅBrd'],
      numDeclaration: json['num_declaration']?.toString(),
      port: json['port']?.toString(),
      typeExpedition: json['type_expedition']?.toString(),
      modereglement: json['modereglement']?.toString(),
      banque: json['banque']?.toString(),
      numPiece: json['numPiece']?.toString() ?? json['num_bl_fact']?.toString(),
      mntHt: json['mnt_ht'] as num?,
      mntTtc: (json['mnt_ttc'] ?? json['mnt_Ʃc']) as num?,
    );
  }
}
