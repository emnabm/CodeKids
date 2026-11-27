import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the main session JWT in secure storage and keeps the short-lived
/// parent-area token strictly in memory.
class TokenStorage {
  TokenStorage({
    FlutterSecureStorage? secureStorage,
    required this._prefs,
    bool inMemoryOnly = false,
  })  : _secureStorage =
            inMemoryOnly ? null : (secureStorage ?? const FlutterSecureStorage());

  static const String _jwtKey = 'codekids_auth_jwt';
  static const String _activeChildIdKey = 'codekids_active_child_id';
  static const String _parentEmailKey = 'codekids_parent_email';
  static const String _parentLanguageKey = 'codekids_parent_language';

  final FlutterSecureStorage? _secureStorage;
  final SharedPreferences _prefs;

  String? _inMemoryJwt;
  String? _parentAreaToken;
  DateTime? _parentAreaExpiresAt;

  Future<String?> readToken() async {
    if (_secureStorage == null) return _inMemoryJwt;
    _inMemoryJwt ??= await _secureStorage.read(key: _jwtKey);
    return _inMemoryJwt;
  }

  Future<void> saveToken(String token) async {
    _inMemoryJwt = token;
    await _secureStorage?.write(key: _jwtKey, value: token);
  }

  Future<void> clearSession() async {
    _inMemoryJwt = null;
    clearParentAreaToken();
    await _secureStorage?.delete(key: _jwtKey);
    await _prefs.remove(_activeChildIdKey);
    await _prefs.remove(_parentEmailKey);
    await _prefs.remove(_parentLanguageKey);
  }

  /// Stores the 15-minute parent-area JWT in memory only.
  void saveParentAreaToken(String token, int expiresInSeconds) {
    _parentAreaToken = token;
    _parentAreaExpiresAt = DateTime.now().add(
      Duration(seconds: expiresInSeconds > 0 ? expiresInSeconds : 900),
    );
  }

  String? get parentAreaToken {
    if (_parentAreaToken == null || _parentAreaExpiresAt == null) {
      return null;
    }
    if (DateTime.now().isAfter(_parentAreaExpiresAt!)) {
      clearParentAreaToken();
      return null;
    }
    return _parentAreaToken;
  }

  bool get hasValidParentAreaToken => parentAreaToken != null;

  void clearParentAreaToken() {
    _parentAreaToken = null;
    _parentAreaExpiresAt = null;
  }

  String? get activeChildId => _prefs.getString(_activeChildIdKey);

  Future<void> saveActiveChildId(String? childId) async {
    if (childId == null || childId.isEmpty) {
      await _prefs.remove(_activeChildIdKey);
    } else {
      await _prefs.setString(_activeChildIdKey, childId);
    }
  }

  String? get parentEmail => _prefs.getString(_parentEmailKey);
  String? get parentLanguage => _prefs.getString(_parentLanguageKey);

  Future<void> saveParentInfo({String? email, String? language}) async {
    if (email != null) {
      await _prefs.setString(_parentEmailKey, email);
    }
    if (language != null) {
      await _prefs.setString(_parentLanguageKey, language);
    }
  }
}
