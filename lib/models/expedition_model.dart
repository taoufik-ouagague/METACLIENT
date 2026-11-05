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
  final String? typeRemboursement;

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
    this.typeRemboursement,
  });

  factory ExpeditionModel.fromJson(Map<String, dynamic> json) {
    final rawType = (json['typeRemboursement'] ??
            json['type_remboursement'] ??
            json['typeRemb'] ??
            json['type_remb'] ??
            json['mode_reglement'] ??
            json['modereglement'] ??
            json['type_reglement'] ??
            json['type'])
        ?.toString();

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
      typeRemboursement: rawType,
    );
  }

  bool get isLivree =>
      (statut != null && statut!.toLowerCase().contains('cloture')) ||
      (dateLivraison != null && dateLivraison!.isNotEmpty);

  bool get isVirement {
    final t = (typeRemboursement ?? '').toLowerCase();
    if (t.contains('vir')) return true;
    final n = (nature ?? '').toLowerCase();
    if (n.contains('vir')) return true;
    if (n == 'c.rmb' || n.contains('c/remb') || n.contains('c-c/remb')) {
      return !t.contains('ch');
    }
    return false;
  }

  bool get isCheque {
    final t = (typeRemboursement ?? '').toLowerCase();
    if (t.contains('ch')) return true;
    final n = (nature ?? '').toLowerCase();
    if (n.contains('chq') || n.contains('cheq') || n.contains('chk') || n == 'c.chq') {
      return true;
    }
    return false;
  }

  String? get typeRemboursementLibelle {
    if (isVirement) return 'Virement';
    if (isCheque) return 'Chèque';
    if (typeRemboursement != null && typeRemboursement!.trim().isNotEmpty) {
      final s = typeRemboursement!.trim();
      return s[0].toUpperCase() + s.substring(1);
    }
    final n = (nature ?? '').trim();
    if (n.toLowerCase().contains('ch')) return 'Chèque';
    if (n.toLowerCase().contains('rmb')) return 'Virement';
    if (n.isNotEmpty && n.toLowerCase() != 'smpl') return n;
    return null;
  }
}
