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

/// Élément de remboursement de l'expédition (chèque ou virement)
class ChequeCrItem {
  final String? typeRemboursement;
  final String? numPiece;
  final num? montant;
  final String? dateRemise;
  final String? dateEncaissement;
  final String? banque;
  final Map<String, dynamic> raw;

  ChequeCrItem({
    this.typeRemboursement,
    this.numPiece,
    this.montant,
    this.dateRemise,
    this.dateEncaissement,
    this.banque,
    required this.raw,
  });

  bool get isVirement {
    final t = typeRemboursement?.toLowerCase() ?? '';
    return t.contains('vir');
  }

  bool get isCheque {
    final t = typeRemboursement?.toLowerCase() ?? '';
    return t.contains('ch') || (!isVirement && t.isNotEmpty);
  }

  String get typeLibelle {
    if (isVirement) return 'Virement';
    if (isCheque) return 'Chèque';
    if (typeRemboursement != null && typeRemboursement!.trim().isNotEmpty) {
      final s = typeRemboursement!.trim();
      return s[0].toUpperCase() + s.substring(1);
    }
    return 'C/REMB';
  }

  factory ChequeCrItem.fromJson(Map<String, dynamic> json) {
    final type =
        (json['typeRemboursement'] ??
                json['type_remboursement'] ??
                json['typeRemb'] ??
                json['type_remb'] ??
                json['type'] ??
                json['mode_reglement'])
            ?.toString();
    return ChequeCrItem(
      typeRemboursement: type,
      numPiece:
          (json['num_piece'] ??
                  json['num_cheque'] ??
                  json['piece'] ??
                  json['ref_reglement'] ??
                  json['num'])
              ?.toString(),
      montant: json['montant'] as num? ?? json['fond'] as num?,
      dateRemise:
          json['date_remise']?.toString() ?? json['dateremise']?.toString(),
      dateEncaissement: json['date_encaissement']?.toString(),
      banque: json['banque']?.toString(),
      raw: json,
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
  final String? coordoneesGps;

  bool get aGps =>
      (gpsLatitude != null && gpsLongitude != null) ||
      (coordoneesGps != null && coordoneesGps!.trim().isNotEmpty);

  double? get latitudeEffective {
    if (gpsLatitude != null) return gpsLatitude;
    if (coordoneesGps != null) {
      final parts = coordoneesGps!.split(RegExp(r'[,;]'));
      if (parts.length >= 2) return double.tryParse(parts[0].trim());
    }
    return null;
  }

  double? get longitudeEffective {
    if (gpsLongitude != null) return gpsLongitude;
    if (coordoneesGps != null) {
      final parts = coordoneesGps!.split(RegExp(r'[,;]'));
      if (parts.length >= 2) return double.tryParse(parts[1].trim());
    }
    return null;
  }

  String get positionGpsTexte {
    final lat = latitudeEffective;
    final lng = longitudeEffective;
    if (lat != null && lng != null) {
      return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    }
    return coordoneesGps ?? '';
  }

  /// Remboursements structurés (chèques et virements)
  List<ChequeCrItem> get chequeCrItems =>
      chequeCr.map((e) => ChequeCrItem.fromJson(e)).toList();

  /// Vrai si au moins un remboursement est par virement
  bool get aVirementCr =>
      chequeCrItems.any((e) => e.isVirement) ||
      (nature ?? '').toLowerCase().contains('vir') ||
      (nature ?? '').toLowerCase() == 'c.rmb';

  /// Vrai si au moins un remboursement est par chèque
  bool get aChequeSeulCr =>
      chequeCrItems.any((e) => e.isCheque) ||
      (nature ?? '').toLowerCase().contains('ch');

  String? get typeRemboursementLibelle {
    if (aVirementCr) return 'Virement';
    if (aChequeSeulCr) return 'Chèque';
    if (chequeCrItems.isNotEmpty) return chequeCrItems.first.typeLibelle;
    final n = (nature ?? '').trim();
    if (n.toLowerCase().contains('ch')) return 'Chèque';
    if (n.toLowerCase().contains('rmb')) return 'Virement';
    if (n.isNotEmpty && n.toLowerCase() != 'smpl') return n;
    return null;
  }

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
    this.coordoneesGps,
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

    final geoMap = _geo(json);
    double? lat =
        _nombre(geoMap['gpsLatitude']) ??
        _nombre(json['latitude']) ??
        _nombre(json['gps_latitude']) ??
        _nombre(json['lat']);
    double? lng =
        _nombre(geoMap['gpsLongitude']) ??
        _nombre(json['longitude']) ??
        _nombre(json['gps_longitude']) ??
        _nombre(json['lng']);

    final rawCoord =
        json['coordonees_gps']?.toString() ??
        json['coordonnees_gps']?.toString() ??
        json['coordonee_gps']?.toString() ??
        json['coordonnee_gps']?.toString() ??
        geoMap['coordonees_gps']?.toString() ??
        geoMap['coordonnees_gps']?.toString();

    if ((lat == null || lng == null) &&
        rawCoord != null &&
        rawCoord.contains(',')) {
      final parts = rawCoord.split(RegExp(r'[,;]'));
      if (parts.length >= 2) {
        lat ??= double.tryParse(parts[0].trim());
        lng ??= double.tryParse(parts[1].trim());
      }
    }

    final geofence =
        geoMap['gpsGeofence']?.toString() ??
        json['gps_geofence']?.toString() ??
        (json['geofence'] is String ? json['geofence']?.toString() : null) ??
        json['zone_gps']?.toString();

    final capturedAt =
        geoMap['gpsCapturedAt']?.toString() ??
        json['gps_captured_at']?.toString() ??
        json['date_gps']?.toString();

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
      processus: rawProc
          .map((e) => ProcessusStep.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      gedDocuments: rawGed
          .map((e) => GedDocument.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      commentaires: rawComments
          .map(
            (e) => ExpeditionCommentaire.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
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
      gpsLatitude: lat,
      gpsLongitude: lng,
      gpsGeofence: geofence,
      gpsCapturedAt: capturedAt,
      coordoneesGps:
          rawCoord ?? (lat != null && lng != null ? '$lat, $lng' : null),
    );
  }
}
