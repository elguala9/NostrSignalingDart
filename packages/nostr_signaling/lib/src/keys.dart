import 'package:dart_nostr/dart_nostr.dart';

class NostrKeyPair {
  final String privateKey;
  final String publicKey;

  NostrKeyPair({
    required this.privateKey,
    required this.publicKey,
  });

  factory NostrKeyPair.fromPrivateKey(String privateKey) {
    final keyPairs = Nostr().keys.generateKeyPairFromExistingPrivateKey(privateKey);
    return NostrKeyPair(
      privateKey: keyPairs.private,
      publicKey: keyPairs.public,
    );
  }

  bool isValid() {
    try {
      final derived = Nostr().keys.derivePublicKey(privateKey: privateKey);
      return derived == publicKey;
    } catch (_) {
      return false;
    }
  }

  @override
  String toString() => 'NostrKeyPair('
      'private: ${privateKey.substring(0, 8)}...,'
      'public: ${publicKey.substring(0, 8)}...)'
      '';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NostrKeyPair &&
          runtimeType == other.runtimeType &&
          privateKey == other.privateKey &&
          publicKey == other.publicKey;

  @override
  int get hashCode => privateKey.hashCode ^ publicKey.hashCode;
}

class NostrKeys {
  NostrKeys._();

  static NostrKeyPair generate() {
    final keyPairs = Nostr().keys.generateKeyPair();
    return NostrKeyPair(
      privateKey: keyPairs.private,
      publicKey: keyPairs.public,
    );
  }

  static NostrKeyPair fromHex({
    required String privateKeyHex,
    required String publicKeyHex,
  }) {
    final keyPair = NostrKeyPair(
      privateKey: privateKeyHex,
      publicKey: publicKeyHex,
    );

    if (!keyPair.isValid()) {
      throw ArgumentError(
        'Le chiavi fornite non formano una coppia valida: '
        'la chiave pubblica non corrisponde alla chiave privata',
      );
    }

    return keyPair;
  }

  static NostrKeyPair fromPrivateKeyHex(String privateKeyHex) {
    return NostrKeyPair.fromPrivateKey(privateKeyHex);
  }

  static bool isValidPrivateKeyFormat(String key) {
    return Nostr().keys.isValidPrivateKey(key);
  }

  static bool isValidPublicKeyFormat(String key) {
    if (key.length != 64) return false;
    final hexRegex = RegExp(r'^[0-9a-fA-F]+$');
    return hexRegex.hasMatch(key);
  }
}
