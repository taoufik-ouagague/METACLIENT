import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String keyToken = 'auth_token';
  static const String keyCode = 'user_code';
  static const String keyLibelle = 'user_libelle';
  static const String keyLogin = 'user_login';
  static const String keyServerUrl = 'server_base_url';
  static const String keyProfilePhoto = 'user_profile_photo';
  static const String keyClientConfig = 'client_config';
  static const String keyRememberMe = 'remember_me';
  static const String keyRememberedLogin = 'remembered_login';

  /// Le mot de passe memorise ne passe pas par SharedPreferences : la
  /// Keychain (iOS) et EncryptedSharedPreferences (Android) le chiffrent et le
  /// tiennent hors des sauvegardes en clair.
  static const String keyRememberedPassword = 'remembered_password';

  static const FlutterSecureStorage _coffre = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

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

  static String? getProfilePhoto() => prefs.getString(keyProfilePhoto);
  static Future<bool> setProfilePhoto(String photo) => prefs.setString(keyProfilePhoto, photo);

  static String? getClientConfigRaw() => prefs.getString(keyClientConfig);
  static Future<bool> setClientConfigRaw(String jsonStr) => prefs.setString(keyClientConfig, jsonStr);

  static bool hasToken() {
    final t = getToken();
    return t != null && t.trim().isNotEmpty;
  }

  // ── « Se souvenir de moi » ──────────────────────────────────────────────
  static bool getRememberMe() => prefs.getBool(keyRememberMe) ?? false;

  static String? getRememberedLogin() => prefs.getString(keyRememberedLogin);

  static Future<String?> getRememberedPassword() =>
      _coffre.read(key: keyRememberedPassword);

  static Future<void> saveCredentials(String login, String password) async {
    await prefs.setBool(keyRememberMe, true);
    await prefs.setString(keyRememberedLogin, login);
    await _coffre.write(key: keyRememberedPassword, value: password);
  }

  static Future<void> forgetCredentials() async {
    await prefs.setBool(keyRememberMe, false);
    await prefs.remove(keyRememberedLogin);
    await _coffre.delete(key: keyRememberedPassword);
  }

  static Future<void> clearAll() async {
    final savedServer = getServerUrl();
    final savedConfig = getClientConfigRaw();
    final seSouvenir = getRememberMe();
    final loginMemorise = getRememberedLogin();
    await prefs.clear();
    if (seSouvenir) {
      await prefs.setBool(keyRememberMe, true);
      if (loginMemorise != null) {
        await prefs.setString(keyRememberedLogin, loginMemorise);
      }
    }
    if (savedServer != null) {
      await setServerUrl(savedServer);
    }
    if (savedConfig != null) {
      await setClientConfigRaw(savedConfig);
    }
  }
}
