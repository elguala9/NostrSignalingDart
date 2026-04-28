import 'package:bip340/bip340.dart' as bip340;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';

/// Una coppia di chiavi Nostr (privata + pubblica)
/// Utilizza lo standard BIP340 per la derivazione delle chiavi
class NostrKeyPair {
  /// Chiave privata in formato hex (32 bytes)
  final String privateKey;

  /// Chiave pubblica in formato hex (32 bytes), derivata dalla chiave privata
  final String publicKey;

  NostrKeyPair({
    required this.privateKey,
    required this.publicKey,
  });

  /// Crea una coppia di chiavi dalla sola chiave privata
  /// La chiave pubblica viene derivata automaticamente usando BIP340
  factory NostrKeyPair.fromPrivateKey(String privateKey) {
    final publicKey = bip340.getPublicKey(privateKey);
    return NostrKeyPair(
      privateKey: privateKey,
      publicKey: publicKey,
    );
  }

  /// Valida se le due chiavi formano effettivamente una coppia valida
  bool isValid() {
    try {
      final derivedPublicKey = bip340.getPublicKey(privateKey);
      return derivedPublicKey == publicKey;
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

/// Utility per generare e gestire chiavi Nostr
class NostrKeys {
  NostrKeys._(); // non istanziabile

  /// Genera una nuova coppia di chiavi Nostr randomiche
  /// Utilizza SecureRandom per generare una chiave privata sicura
  static NostrKeyPair generate() {
    // Genera 32 byte casuali
    final random = _SecureRandomGenerator();
    final randomBytes = random.nextBytes(32);

    // Converte in hex string
    final privateKey = _bytesToHex(randomBytes);

    return NostrKeyPair.fromPrivateKey(privateKey);
  }

  /// Importa una coppia di chiavi da due hex strings
  /// Valida che le chiavi formino una coppia valida
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

  /// Crea una coppia di chiavi dalla sola chiave privata hex
  /// La chiave pubblica viene derivata automaticamente
  static NostrKeyPair fromPrivateKeyHex(String privateKeyHex) {
    return NostrKeyPair.fromPrivateKey(privateKeyHex);
  }

  /// Valida se una chiave privata è in formato valido (64 caratteri hex)
  static bool isValidPrivateKeyFormat(String key) {
    if (key.length != 64) return false;
    return _isValidHexString(key);
  }

  /// Valida se una chiave pubblica è in formato valido (64 caratteri hex)
  static bool isValidPublicKeyFormat(String key) {
    if (key.length != 64) return false;
    return _isValidHexString(key);
  }

  static bool _isValidHexString(String s) {
    final hexRegex = RegExp(r'^[0-9a-fA-F]+$');
    return hexRegex.hasMatch(s);
  }
}

// Helper interno per convertire bytes a hex string
String _bytesToHex(List<int> bytes) {
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

// Helper per generare numeri casuali sicuri
class _SecureRandomGenerator {
  final _random = Random.secure();

  List<int> nextBytes(int length) {
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }
}
