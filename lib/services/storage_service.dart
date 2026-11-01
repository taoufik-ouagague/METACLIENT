import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String keyToken = 'auth_token';
  static const String keyCode = 'user_code';
  static const String keyLibelle = 'user_libelle';
  static const String keyLogin = 'user_login';
  static const String keyServerUrl = 'server_base_url';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() in main().');
    }
    return _prefs!;
  }

  static String? getToken() => prefs.getString(keyToken);
  static Future<bool> setToken(String token) => prefs.setString(keyToken, token);

  static String? getUserCode() => prefs.getString(keyCode);
  static Future<bool> setUserCode(String code) => prefs.setString(keyCode, code);

  static String? getUserLibelle() => prefs.getString(keyLibelle);
  static Future<bool> setUserLibelle(String libelle) => prefs.setString(keyLibelle, libelle);

  static String? getLogin() => prefs.getString(keyLogin);
  static Future<bool> setLogin(String login) => prefs.setString(keyLogin, login);

  static String? getServerUrl() => prefs.getString(keyServerUrl);
  static Future<bool> setServerUrl(String url) => prefs.setString(keyServerUrl, url);

  static bool hasToken() {
    final t = getToken();
    return t != null && t.trim().isNotEmpty;
  }

  static Future<void> clearAll() async {
    final savedServer = getServerUrl();
    await prefs.clear();
    if (savedServer != null) {
      await setServerUrl(savedServer);
    }
  }
}
