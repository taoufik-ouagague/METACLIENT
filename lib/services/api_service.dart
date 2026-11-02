import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'storage_service.dart';

class ApiService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, printTime: false),
  );

  static const String defaultDevUrl = 'https://metaphore.kaytechnology.com:6799/CLIENTMOBILE';
  static const String defaultAndroidEmulatorUrl = 'https://metaphore.kaytechnology.com:6799/CLIENTMOBILE';

  static String baseUrl = _resolveDefaultUrl();

  static String _resolveDefaultUrl() {
    if (kIsWeb) return defaultDevUrl;
    if (Platform.isAndroid) return defaultAndroidEmulatorUrl;
    return defaultDevUrl;
  }

  static void init() {
    final saved = StorageService.getServerUrl();
    if (saved != null && saved.trim().isNotEmpty) {
      baseUrl = saved.trim();
    }
    // Remove trailing slash if present
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
  }

  static Future<void> updateBaseUrl(String url) async {
    var clean = url.trim();
    if (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    baseUrl = clean;
    await StorageService.setServerUrl(clean);
  }

  static Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['token'] = token;
    }
    return headers;
  }

  // ─── AUTHENTIFICATION ────────────────────────────────────────────────────────
  // API Post: /api/AuthentificationClient
  static Future<Map<String, dynamic>> login(String login, String pwd) async {
    final url = Uri.parse('$baseUrl/api/AuthentificationClient');
    final body = jsonEncode({
      'login': login.trim(),
      'pwd': pwd.trim(),
    });

    _logger.i('POST $url\nBody: $body');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    return _handleResponse(response);
  }

  // ─── INFOS CLIENT ────────────────────────────────────────────────────────────
  // API GET : /api/clientmobile/infosClientByCode
  static Future<Map<String, dynamic>> getInfosClient() async {
    final url = Uri.parse('$baseUrl/api/clientmobile/infosClientByCode');
    final response = await http.get(url, headers: _buildHeaders());
    return _handleResponse(response);
  }

  // ─── MES EXPÉDITIONS ─────────────────────────────────────────────────────────
  // API Post: /api/clientmobile/expeditions?page=1&pageSize=20
  static Future<Map<String, dynamic>> getExpeditions({
    int page = 1,
    int pageSize = 20,
    String? du,
    String? au,
    String? numDeclaration,
    String? livre,
    String? numeroClient,
  }) async {
    final url = Uri.parse('$baseUrl/api/clientmobile/expeditions?page=$page&pageSize=$pageSize');
    final currentYear = DateTime.now().year;
    final body = jsonEncode({
      'du': (du != null && du.trim().isNotEmpty) ? du.trim() : '01/01/$currentYear',
      'au': (au != null && au.trim().isNotEmpty) ? au.trim() : '31/12/$currentYear',
      'numDeclaration': (numDeclaration != null && numDeclaration.trim().isNotEmpty) ? numDeclaration.trim() : null,
      'numeroClient': (numeroClient != null && numeroClient.trim().isNotEmpty) ? numeroClient.trim() : null,
      'livre': (livre != null && livre.trim().isNotEmpty) ? livre.trim() : null,
      'colis': null,
      'mntFond': null,
    });

    final response = await http.post(url, headers: _buildHeaders(), body: body);
    return _handleResponse(response);
  }

  // ─── EXPÉDITION EN COURS ─────────────────────────────────────────────────────
  // API Get : /api/clientmobile/expeditionsEncours
  static Future<Map<String, dynamic>> getExpeditionsEncours() async {
    final url = Uri.parse('$baseUrl/api/clientmobile/expeditionsEncours');
    final response = await http.get(url, headers: _buildHeaders());
    return _handleResponse(response);
  }

  // ─── DÉTAIL D'UNE EXPÉDITION ─────────────────────────────────────────────────
  // API Get : /api/clientmobile/expeditionsDetail?idExpedition=...
  static Future<Map<String, dynamic>> getExpeditionDetail(int idExpedition) async {
    final url = Uri.parse('$baseUrl/api/clientmobile/expeditionsDetail?idExpedition=$idExpedition');
    final response = await http.get(url, headers: _buildHeaders());
    return _handleResponse(response);
  }

  // ─── FACTURES ────────────────────────────────────────────────────────────────
  // API Post : /api/clientmobile/factures?page=1&pageSize=20
  static Future<Map<String, dynamic>> getFactures({
    int page = 1,
    int pageSize = 20,
    String? regle, // null = Tous, "en cours", "cloture"
  }) async {
    final url = Uri.parse('$baseUrl/api/clientmobile/factures?page=$page&pageSize=$pageSize');
    final body = jsonEncode({'regle': regle});
    final response = await http.post(url, headers: _buildHeaders(), body: body);
    return _handleResponse(response);
  }

  // ─── FACTURES EN INSTANCES ───────────────────────────────────────────────────
  // API Get : /api/clientmobile/facturesInstances
  static Future<dynamic> getFacturesInstances() async {
    final url = Uri.parse('$baseUrl/api/clientmobile/facturesInstances');
    final response = await http.get(url, headers: _buildHeaders());
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw ApiException(response.statusCode, response.body);
  }

  // ─── DÉTAIL D'UNE FACTURE (RÈGLEMENTS / AVOIRS) ──────────────────────────────
  // API Get : /api/clientmobile/facturesReglements?idFacture=...
  static Future<Map<String, dynamic>> getFactureReglements(int idFacture) async {
    final url = Uri.parse('$baseUrl/api/clientmobile/facturesReglements?idFacture=$idFacture');
    final response = await http.get(url, headers: _buildHeaders());
    return _handleResponse(response);
  }

  // ─── RETOUR DE FONDS / CC, CT (CHÈQUES & TRAITES) ───────────────────────────
  // API Post : /api/clientmobile/retourFondCCCT?page=1&pageSize=20
  static Future<Map<String, dynamic>> getRetourFondCCCT({
    int page = 1,
    int pageSize = 20,
    String? du,
    String? au,
    String? numDeclaration,
    String? numPiece,
    String? libelleClient,
    String? remis,
  }) async {
    final url = Uri.parse('$baseUrl/api/clientmobile/retourFondCCCT?page=$page&pageSize=$pageSize');
    final currentYear = DateTime.now().year;
    final body = jsonEncode({
      'du': (du != null && du.trim().isNotEmpty) ? du.trim() : '01/01/$currentYear',
      'au': (au != null && au.trim().isNotEmpty) ? au.trim() : '31/12/$currentYear',
      'numDeclaration': (numDeclaration != null && numDeclaration.trim().isNotEmpty) ? numDeclaration.trim() : null,
      'numPiece': (numPiece != null && numPiece.trim().isNotEmpty) ? numPiece.trim() : null,
      'libelleClient': (libelleClient != null && libelleClient.trim().isNotEmpty) ? libelleClient.trim() : null,
      'remis': (remis != null && remis.trim().isNotEmpty) ? remis.trim() : null,
    });
    final response = await http.post(url, headers: _buildHeaders(), body: body);
    return _handleResponse(response);
  }

  // ─── RETOUR BL, FACTURES ─────────────────────────────────────────────────────
  // API Post : /api/clientmobile/retourFondBL?page=1&pageSize=20
  static Future<Map<String, dynamic>> getRetourFondBL({
    int page = 1,
    int pageSize = 20,
    String? du,
    String? au,
    String? numDeclaration,
    String? numPiece,
    String? libelleClient,
    String? remis,
  }) async {
    final url = Uri.parse('$baseUrl/api/clientmobile/retourFondBL?page=$page&pageSize=$pageSize');
    final currentYear = DateTime.now().year;
    final body = jsonEncode({
      'du': (du != null && du.trim().isNotEmpty) ? du.trim() : '01/01/$currentYear',
      'au': (au != null && au.trim().isNotEmpty) ? au.trim() : '31/12/$currentYear',
      'numDeclaration': (numDeclaration != null && numDeclaration.trim().isNotEmpty) ? numDeclaration.trim() : null,
      'numPiece': (numPiece != null && numPiece.trim().isNotEmpty) ? numPiece.trim() : null,
      'libelleClient': (libelleClient != null && libelleClient.trim().isNotEmpty) ? libelleClient.trim() : null,
      'remis': (remis != null && remis.trim().isNotEmpty) ? remis.trim() : null,
    });
    final response = await http.post(url, headers: _buildHeaders(), body: body);
    return _handleResponse(response);
  }

  // ─── EXPÉDITIONS CRBT ────────────────────────────────────────────────────────
  // API Post : /api/clientmobile/expeditionsCrbt?page=1&pageSize=20
  static Future<Map<String, dynamic>> getExpeditionsCrbt({
    int page = 1,
    int pageSize = 20,
    String? du,
    String? au,
    String? numDeclaration,
    String? numPiece,
    String? libelleClient,
    String? remis,
  }) async {
    final url = Uri.parse('$baseUrl/api/clientmobile/expeditionsCrbt?page=$page&pageSize=$pageSize');
    final currentYear = DateTime.now().year;
    final body = jsonEncode({
      'du': (du != null && du.trim().isNotEmpty) ? du.trim() : '01/01/2020',
      'au': (au != null && au.trim().isNotEmpty) ? au.trim() : '31/12/$currentYear',
      'num_declaration': numDeclaration ?? '',
      'num_piece': numPiece ?? '',
      'libelle_client': libelleClient ?? '',
      'remis': remis ?? '',
    });
    final response = await http.post(url, headers: _buildHeaders(), body: body);
    return _handleResponse(response);
  }

  // ─── CHÈQUES CRBT ────────────────────────────────────────────────────────────
  // API Post : /api/clientmobile/chequesCrbt?page=1&pageSize=20
  static Future<Map<String, dynamic>> getChequesCrbt({
    int page = 1,
    int pageSize = 20,
    String? du,
    String? au,
    String? numDeclaration,
    String? numPiece,
    String? libelleClient,
    String? remis,
  }) async {
    final url = Uri.parse('$baseUrl/api/clientmobile/chequesCrbt?page=$page&pageSize=$pageSize');
    final currentYear = DateTime.now().year;
    final body = jsonEncode({
      'du': (du != null && du.trim().isNotEmpty) ? du.trim() : '01/01/2000',
      'au': (au != null && au.trim().isNotEmpty) ? au.trim() : '31/12/$currentYear',
      'num_declaration': numDeclaration ?? '',
      'num_piece': numPiece ?? '',
      'libelle_client': libelleClient ?? '',
      'remis': remis ?? '',
    });
    final response = await http.post(url, headers: _buildHeaders(), body: body);
    return _handleResponse(response);
  }

  // ─── DÉTAIL D'UN CHÈQUE CRBT ─────────────────────────────────────────────────
  // API Get : /api/clientmobile/detailChequeCrbt?idCheque=...
  static Future<Map<String, dynamic>> getDetailChequeCrbt(int idCheque) async {
    final url = Uri.parse('$baseUrl/api/clientmobile/detailChequeCrbt?idCheque=$idCheque');
    final response = await http.get(url, headers: _buildHeaders());
    return _handleResponse(response);
  }

  // ─── ORDRES DE VIREMENTS & MANDATS ───────────────────────────────────────────
  // API Post : /api/clientmobile/virementCrbt?page=1&pageSize=20
  static Future<Map<String, dynamic>> getVirementCrbt({
    int page = 1,
    int pageSize = 20,
    String? du,
    String? au,
  }) async {
    final url = Uri.parse('$baseUrl/api/clientmobile/virementCrbt?page=$page&pageSize=$pageSize');
    final currentYear = DateTime.now().year;
    final body = jsonEncode({
      'du': (du != null && du.trim().isNotEmpty) ? du.trim() : '01/01/2000',
      'au': (au != null && au.trim().isNotEmpty) ? au.trim() : '31/12/$currentYear',
    });
    final response = await http.post(url, headers: _buildHeaders(), body: body);
    return _handleResponse(response);
  }

  // ─── DÉTAIL D'UN ORDRE DE VIREMENT ───────────────────────────────────────────
  // API Get : /api/clientmobile/detailVirementCrbt?idVirement=...
  static Future<Map<String, dynamic>> getDetailVirementCrbt(int idVirement) async {
    final url = Uri.parse('$baseUrl/api/clientmobile/detailVirementCrbt?idVirement=$idVirement');
    final response = await http.get(url, headers: _buildHeaders());
    return _handleResponse(response);
  }

  // Helper response handler
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final bodyString = utf8.decode(response.bodyBytes);
    _logger.d('Status ${response.statusCode}: $bodyString');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (bodyString.isEmpty) return {};
      final dynamic decoded = jsonDecode(bodyString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is List) {
        return {'data': decoded};
      }
      return {'result': decoded};
    } else {
      throw ApiException(response.statusCode, bodyString);
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException ($statusCode): $message';
}
