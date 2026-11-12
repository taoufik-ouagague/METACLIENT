class UserModel {
  final String code;
  final String libelle;
  final List<String> roles;
  final String token;
  final bool connexionOtp;

  UserModel({
    required this.code,
    required this.libelle,
    required this.roles,
    required this.token,
    this.connexionOtp = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedRoles = [];
    if (json['roles'] != null && json['roles'] is List) {
      for (var r in json['roles']) {
        if (r is Map && r['droit'] != null) {
          parsedRoles.add(r['droit'].toString());
        } else if (r is String) {
          parsedRoles.add(r);
        }
      }
    }

    final rawOtp = json['connexionOtp'];
    final isOtp =
        rawOtp == true ||
        rawOtp?.toString().toLowerCase() == 'true' ||
        rawOtp == 1 ||
        rawOtp?.toString() == '1';

    return UserModel(
      code: json['code']?.toString() ?? '',
      libelle: json['libelle']?.toString() ?? '',
      roles: parsedRoles,
      token: json['token']?.toString() ?? '',
      connexionOtp: isOtp,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'libelle': libelle,
    'roles': roles.map((r) => {'droit': r}).toList(),
    'token': token,
    'connexionOtp': connexionOtp,
  };
}
