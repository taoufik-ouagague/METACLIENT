/// Une agence du reseau.
///
/// Le referentiel est partiellement rempli : telephone et adresse valent
/// souvent « . » ou « N/A », et les coordonnees sont a zero. Les accesseurs
/// ci-dessous renvoient `null` dans ces cas, pour que l'ecran n'affiche pas
/// des lignes vides.
class AgenceModel {
  final String code;
  final String libelle;
  final String? telephoneBrut;
  final String? adresseBrute;
  final num? latitude;
  final num? longitude;
  final int? cpk;

  const AgenceModel({
    required this.code,
    required this.libelle,
    this.telephoneBrut,
    this.adresseBrute,
    this.latitude,
    this.longitude,
    this.cpk,
  });

  static const Set<String> _bouchons = {'.', '-', 'N/A', 'NA', 'NEANT'};

  static String? _utile(String? valeur) {
    final v = valeur?.trim();
    if (v == null || v.isEmpty) return null;
    return _bouchons.contains(v.toUpperCase()) ? null : v;
  }

  String? get telephone => _utile(telephoneBrut);
  String? get adresse => _utile(adresseBrute);

  /// Vrai seulement si l'agence est reellement geolocalisee.
  bool get estLocalisee => (latitude ?? 0) != 0 && (longitude ?? 0) != 0;

  factory AgenceModel.fromJson(Map<String, dynamic> json) {
    return AgenceModel(
      code: json['code']?.toString() ?? '',
      libelle: (json['libelle']?.toString() ?? '').trim(),
      telephoneBrut: json['telephone']?.toString(),
      adresseBrute: json['adresse1']?.toString(),
      latitude: json['latitude'] as num?,
      longitude: json['longitude'] as num?,
      cpk: (json['cpk'] as num?)?.toInt(),
    );
  }
}
