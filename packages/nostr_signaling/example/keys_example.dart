import 'package:nostr_signaling/nostr_signaling.dart';

void main() {
  // ====================================================================
  // Generate a new random key pair
  // ====================================================================
  print('=== Generating new keys ===');
  final newKeyPair = NostrKeys.generate();
  print('Private Key: ${newKeyPair.privateKey}');
  print('Public Key:  ${newKeyPair.publicKey}');
  print('Valid? ${newKeyPair.isValid()}');
  print('');

  // ====================================================================
  // Import a key pair from a private key
  // ====================================================================
  print('=== Importing from private key ===');
  const myPrivateKey =
      '0000000000000000000000000000000000000000000000000000000000000001';
  final keyPairFromPrivate = NostrKeys.fromPrivateKeyHex(myPrivateKey);
  print('Private Key: ${keyPairFromPrivate.privateKey}');
  print('Public Key:  ${keyPairFromPrivate.publicKey}');
  print('');

  // ====================================================================
  // Import a full key pair (both keys)
  // ====================================================================
  print('=== Importing both keys ===');
  const privateKey =
      '0000000000000000000000000000000000000000000000000000000000000001';
  const publicKey =
      '79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798';

  try {
    final importedKeyPair = NostrKeys.fromHex(
      privateKeyHex: privateKey,
      publicKeyHex: publicKey,
    );
    print('Keys imported successfully!');
    print('Private: ${importedKeyPair.privateKey}');
    print('Public:  ${importedKeyPair.publicKey}');
  } catch (e) {
    print('Error: $e');
  }
  print('');

  // ====================================================================
  // Validate key format
  // ====================================================================
  print('=== Validating key format ===');
  const testKey =
      '0000000000000000000000000000000000000000000000000000000000000001';
  print('Valid private key format? ${NostrKeys.isValidPrivateKeyFormat(testKey)}');
  print('Valid public key format? ${NostrKeys.isValidPublicKeyFormat(publicKey)}');
  print('');

  // ====================================================================
  // Human-readable toString output
  // ====================================================================
  print('=== Human-readable output ===');
  final keyPair = NostrKeys.generate();
  print('KeyPair: $keyPair');
}
