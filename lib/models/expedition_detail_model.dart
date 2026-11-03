class ProcessusStep {
  final String? livreurChauffeur;
  final String processus;
  final String? tourneeVoyage;
  final String? dateAction;
  final String? faitPar;
  final String? faitA;
  final String? status;

  ProcessusStep({
    this.livreurChauffeur,
    required this.processus,
    this.tourneeVoyage,
    this.dateAction,
    this.faitPar,
    this.faitA,
    this.status,
  });

  factory ProcessusStep.fromJson(Map<String, dynamic> json) {
    return ProcessusStep(
      livreurChauffeur: json['livreur_chauffeur']?.toString(),
      processus: json['processus']?.toString() ?? '',
      tourneeVoyage: json['tournee_voyage']?.toString(),
      dateAction: json['date_action']?.toString(),
      faitPar: json['fait_par']?.toString(),
      faitA: json['fait_a']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class GedDocument {
  final String lien;
  final String typeDocument;

  GedDocument({required this.lien, required this.typeDocument});

  factory GedDocument.fromJson(Map<String, dynamic> json) {
    return GedDocument(
      lien: json['lien']?.toString() ?? '',
      typeDocument: json['type_document']?.toString() ?? '',
    );
  }
}

class ExpeditionCommentaire {
  final String? typeComment;
  final String? agentComment;
  final String? libelleComment;
  final String? dateComment;
  final String? sourceComment;

  ExpeditionCommentaire({
    this.typeComment,
    this.agentComment,
    this.libelleComment,
    this.dateComment,
    this.sourceComment,
  });

  factory ExpeditionCommentaire.fromJson(Map<String, dynamic> json) {
    return ExpeditionCommentaire(
      typeComment: json['type_comment']?.toString(),
      agentComment: json['agent_comment']?.toString(),
      libelleComment: json['libelle_comment']?.toString(),
      dateComment: json['date_comment']?.toString(),
      sourceComment: json['source_comment']?.toString(),
    );
  }
}

class ExpeditionDetailModel {
  final int? idExpedition;
  final String numDeclaration;
  final String? factureEncompte;
  final num? poids;
  final num? colis;
  final num? fond;
  final num? mntHt;
  final num? mntTtc;
  final String? origine;
  final String? destination;
  final String? expediteur;
  final String? expediteurAdresse;
  final String? destinataire;
  final String? nature;
  final String? dateTaxation;
  final String? port;
  final String? livraison;
  final List<ProcessusStep> processus;
  final List<GedDocument> gedDocuments;
  final List<ExpeditionCommentaire> commentaires;
  final List<Map<String, dynamic>> retourCcCt;
  final List<Map<String, dynamic>> retourBlFacture;
  final List<Map<String, dynamic>> chequeCr;
  final String? sens;
  final String? activite;
  final String? blFact;
  final num? valeurDeclaree;
  final String? dateLivMobile;
  final String? dateEncaissement;
  final String? expediteurCode;
  final String? expediteurTel;
  final String? destinataireCode;
  final String? destinataireAdresse;
  final String? destinataireTel;
  final double? gpsLatitude;
  final double? gpsLongitude;
  final String? gpsGeofence;
  final String? gpsCapturedAt;

  ExpeditionDetailModel({
    this.idExpedition,
    required this.numDeclaration,
    this.factureEncompte,
    this.poids,
    this.colis,
    this.fond,
    this.mntHt,
    this.mntTtc,
    this.origine,
    this.destination,
    this.expediteur,
    this.expediteurAdresse,
    this.destinataire,
    this.nature,
    this.dateTaxation,
    this.port,
    this.livraison,
    required this.processus,
    required this.gedDocuments,
    required this.commentaires,
    required this.retourCcCt,
    required this.retourBlFacture,
    required this.chequeCr,
    this.sens,
    this.activite,
    this.blFact,
    this.valeurDeclaree,
    this.dateLivMobile,
    this.dateEncaissement,
    this.expediteurCode,
    this.expediteurTel,
    this.destinataireCode,
    this.destinataireAdresse,
    this.destinataireTel,
    this.gpsLatitude,
    this.gpsLongitude,
    this.gpsGeofence,
    this.gpsCapturedAt,
  });

  static Map<String, dynamic> _geo(Map<String, dynamic> json) =>
      json['geofence'] is Map
          ? Map<String, dynamic>.from(json['geofence'] as Map)
          : const {};

  static double? _nombre(Object? v) =>
      v == null ? null : double.tryParse(v.toString());

  factory ExpeditionDetailModel.fromJson(Map<String, dynamic> json) {
    final rawProc = json['processus'] as List? ?? [];
    final rawGed = json['ged_expedition'] as List? ?? [];
    final rawComments = json['commentaires'] as List? ?? [];
    final rawCcCt = json['retour_cc_ct'] as List? ?? [];
    final rawBl = json['retour_bl_facture'] as List? ?? [];
    final rawCheque = json['cheque_cr'] as List? ?? [];

    return ExpeditionDetailModel(
      idExpedition: json['id_expedition'] as int?,
      numDeclaration: json['num_declaration']?.toString() ?? '',
      factureEncompte: json['facture_encompte']?.toString(),
      poids: json['poids'] as num?,
      colis: json['colis'] as num?,
      fond: json['fond'] as num?,
      mntHt: json['mnt_ht'] as num?,
      mntTtc: (json['mnt_ttc'] ?? json['mnt_Ʃc']) as num?,
      origine: json['origine']?.toString(),
      destination: json['destination']?.toString(),
      expediteur: json['expediteur']?.toString(),
      expediteurAdresse: json['expediteur_adresse']?.toString(),
      destinataire: json['destinataire']?.toString(),
      nature: json['nature']?.toString(),
      dateTaxation: json['date_taxation']?.toString(),
      port: json['port']?.toString(),
      livraison: json['livraison']?.toString(),
      processus: rawProc.map((e) => ProcessusStep.fromJson(Map<String, dynamic>.from(e))).toList(),
      gedDocuments: rawGed.map((e) => GedDocument.fromJson(Map<String, dynamic>.from(e))).toList(),
      commentaires: rawComments.map((e) => ExpeditionCommentaire.fromJson(Map<String, dynamic>.from(e))).toList(),
      retourCcCt: rawCcCt.map((e) => Map<String, dynamic>.from(e)).toList(),
      retourBlFacture: rawBl.map((e) => Map<String, dynamic>.from(e)).toList(),
      chequeCr: rawCheque.map((e) => Map<String, dynamic>.from(e)).toList(),
      sens: json['sens']?.toString(),
      activite: json['activite']?.toString(),
      blFact: json['bl_fact']?.toString(),
      valeurDeclaree: json['valeur_declaree'] as num?,
      dateLivMobile: json['date_liv_mobile']?.toString(),
      dateEncaissement: json['date_encaissement']?.toString(),
      expediteurCode: json['expediteur_code']?.toString(),
      expediteurTel: json['expediteur_tel']?.toString(),
      destinataireCode: json['destinataire_code']?.toString(),
      destinataireAdresse: json['destinataire_adresse']?.toString(),
      destinataireTel: json['destinataire_tel']?.toString(),
      // Presente uniquement sur /trackingExpedition.
      gpsLatitude: _nombre(_geo(json)['gpsLatitude']),
      gpsLongitude: _nombre(_geo(json)['gpsLongitude']),
      gpsGeofence: _geo(json)['gpsGeofence']?.toString(),
      gpsCapturedAt: _geo(json)['gpsCapturedAt']?.toString(),
    );
  }
}
