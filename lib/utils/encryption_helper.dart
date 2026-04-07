import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionHelper {
  static final Random _random = Random.secure();

  static String encrypt({
    required String plainText,
    required String secret,
  }) {
    final key = _deriveKey(secret);
    final ivBytes = List<int>.generate(16, (_) => _random.nextInt(256));
    final iv = IV(Uint8List.fromList(ivBytes));
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return jsonEncode(<String, String>{
      'iv': iv.base64,
      'data': encrypted.base64,
    });
  }

  static String decrypt({
    required String cipherText,
    required String secret,
  }) {
    final payload = jsonDecode(cipherText) as Map<String, dynamic>;
    final key = _deriveKey(secret);
    final iv = IV.fromBase64(payload['iv'] as String);
    final encrypted = Encrypted.fromBase64(payload['data'] as String);
    final encrypter = Encrypter(AES(key));
    return encrypter.decrypt(encrypted, iv: iv);
  }

  static Key _deriveKey(String secret) {
    final digest = sha256.convert(utf8.encode(secret)).bytes;
    return Key(Uint8List.fromList(digest));
  }

  static String generateSecret() {
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    return base64Encode(bytes);
  }
}
