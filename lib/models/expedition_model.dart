class ExpeditionModel {
  final int? idExpedition;
  final String numDeclaration;
  final String? dateTaxation;
  final String? dateLivraison;
  final String? destinataire;
  final String? origine;
  final String? destination;
  final String? expediteur;
  final num? colis;
  final num? poids;
  final num? mntHt;
  final num? mntTtc;
  final num? fond;
  final String? port;
  final String? statut;
  final String? livraison;
  final String? nature;
  final String? sens;
  final String? activite;
  final String? blFact;
  final num? valeurDeclaree;
  final String? dateLivPh;
  final String? processus;

  /// Present uniquement sur /expeditionsEncours.
  final String? notificationLivraison;

  ExpeditionModel({
    this.idExpedition,
    required this.numDeclaration,
    this.dateTaxation,
    this.dateLivraison,
    this.destinataire,
    this.origine,
    this.destination,
    this.expediteur,
    this.colis,
    this.poids,
    this.mntHt,
    this.mntTtc,
    this.fond,
    this.port,
    this.statut,
    this.livraison,
    this.nature,
    this.sens,
    this.activite,
    this.blFact,
    this.valeurDeclaree,
    this.dateLivPh,
    this.processus,
    this.notificationLivraison,
  });

  factory ExpeditionModel.fromJson(Map<String, dynamic> json) {
    return ExpeditionModel(
      idExpedition: json['id_expedition'] is num ? (json['id_expedition'] as num).toInt() : null,
      numDeclaration: json['num_declaration']?.toString() ?? '',
      dateTaxation: json['date_taxation']?.toString(),
      dateLivraison: json['date_livraison']?.toString(),
      destinataire: json['destinataire']?.toString(),
      origine: json['origine']?.toString(),
      destination: json['destination']?.toString(),
      expediteur: json['expediteur']?.toString(),
      colis: json['colis'] as num?,
      poids: json['poids'] as num?,
      mntHt: json['mnt_ht'] as num?,
      mntTtc: (json['mnt_ttc'] ?? json['mnt_Ʃc']) as num?,
      fond: json['fond'] as num?,
      port: json['port']?.toString(),
      statut: json['statut']?.toString(),
      livraison: json['livraison']?.toString(),
      nature: json['nature']?.toString(),
      sens: json['sens']?.toString(),
      activite: json['activite']?.toString(),
      blFact: json['bl_fact']?.toString(),
      valeurDeclaree: json['valeur_declaree'] as num?,
      dateLivPh: json['date_liv_ph']?.toString(),
      processus: json['processus']?.toString(),
      notificationLivraison: json['notification_livraison']?.toString(),
    );
  }

  bool get isLivree =>
      (statut != null && statut!.toLowerCase().contains('cloture')) ||
      (dateLivraison != null && dateLivraison!.isNotEmpty);
}
