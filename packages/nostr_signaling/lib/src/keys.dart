import 'package:dart_nostr/dart_nostr.dart';
import 'package:singleton_manager/singleton_manager.dart';

/// A validated Nostr key pair (private + public key).
///
/// Use [NostrKeys] to generate or import key pairs. Instances can be
/// validated with [isValid] and compared for equality.
class NostrKeyPair implements IValueForRegistry {
  /// The hex-encoded private key (32 bytes, 64 hex chars).
  final String privateKey;

  /// The hex-encoded public key (32 bytes, 64 hex chars).
  final String publicKey;

  /// Creates a key pair from its [privateKey] and [publicKey].
  NostrKeyPair({
    required this.privateKey,
    required this.publicKey,
  });

  /// Creates a key pair by deriving the public key from [privateKey].
  factory NostrKeyPair.fromPrivateKey(String privateKey) {
    final keyPairs = Nostr().keys.generateKeyPairFromExistingPrivateKey(privateKey);
    return NostrKeyPair(
      privateKey: keyPairs.private,
      publicKey: keyPairs.public,
    );
  }

  /// Returns `true` if the public key can be derived from the private key.
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

  @override
  void destroy(){

  }
}

/// Utility class for Nostr key generation, import, and validation.
class NostrKeys {
  NostrKeys._();

  /// Generates a new random Nostr key pair.
  static NostrKeyPair generate() {
    final keyPairs = Nostr().keys.generateKeyPair();
    return NostrKeyPair(
      privateKey: keyPairs.private,
      publicKey: keyPairs.public,
    );
  }

  /// Creates a [NostrKeyPair] from hex-encoded [privateKeyHex] and [publicKeyHex].
  ///
  /// Validates that the public key matches the private key.
  /// Throws [ArgumentError] if the key pair is invalid.
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
        'The provided keys do not form a valid pair: '
        'the public key does not match the private key',
      );
    }

    return keyPair;
  }

  /// Creates a [NostrKeyPair] from a hex-encoded [privateKeyHex].
  ///
  /// The public key is derived automatically.
  static NostrKeyPair fromPrivateKeyHex(String privateKeyHex) {
    return NostrKeyPair.fromPrivateKey(privateKeyHex);
  }

  /// Returns `true` if [key] is a valid Nostr private key format.
  static bool isValidPrivateKeyFormat(String key) {
    return Nostr().keys.isValidPrivateKey(key);
  }

  /// Returns `true` if [key] is a valid Nostr public key format (64 hex chars).
  static bool isValidPublicKeyFormat(String key) {
    if (key.length != 64) return false;
    final hexRegex = RegExp(r'^[0-9a-fA-F]+$');
    return hexRegex.hasMatch(key);
  }
  
}
