import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const Duration _storageTimeout = Duration(seconds: 30);
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String notesKey = 'encrypted_notes';
  static const String pinHashKey = 'pin_hash';
  static const String encryptionKeyKey = 'encryption_key';
  static const String themeModeKey = 'theme_mode';

  static Future<void> saveNotes(String encryptedJson) async {
    await _storage
        .write(key: notesKey, value: encryptedJson)
        .timeout(_storageTimeout);
  }

  static Future<String?> loadNotes() {
    return _storage.read(key: notesKey).timeout(_storageTimeout);
  }

  static Future<void> savePinHash(String hash) async {
    await _storage.write(key: pinHashKey, value: hash).timeout(_storageTimeout);
  }

  static Future<String?> loadPinHash() {
    return _storage.read(key: pinHashKey).timeout(_storageTimeout);
  }

  static Future<void> saveEncryptionKey(String key) async {
    await _storage
        .write(key: encryptionKeyKey, value: key)
        .timeout(_storageTimeout);
  }

  static Future<String?> loadEncryptionKey() {
    return _storage.read(key: encryptionKeyKey).timeout(_storageTimeout);
  }

  static Future<void> saveThemeMode(String themeMode) async {
    await _storage
        .write(key: themeModeKey, value: themeMode)
        .timeout(_storageTimeout);
  }

  static Future<String?> loadThemeMode() {
    return _storage.read(key: themeModeKey).timeout(_storageTimeout);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll().timeout(_storageTimeout);
  }
}
