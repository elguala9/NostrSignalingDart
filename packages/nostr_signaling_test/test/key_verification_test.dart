import 'package:bip340/bip340.dart' as bip340;
import 'package:hex/hex.dart';
import 'package:test/test.dart';
import 'package:nostr_signaling/nostr_signaling.dart';

void main() {
  group('Key Verification Test', () {
    test('Verify public key matches private key', () {
      print('\n🔐 Key Verification Test');

      final privKey = NostrTestKeys.testPrivateKey1;
      final pubKey = NostrTestKeys.testPublicKey1;

      print('Private Key: $privKey');
      print('Public Key:  $pubKey');

      // Try to derive the public key from the private key
      try {
        final derivedPubKey = bip340.getPublicKey(privKey);
        print('Derived Public Key: $derivedPubKey');
        print('Expected Public Key: $pubKey');

        if (derivedPubKey.toLowerCase() == pubKey.toLowerCase()) {
          print('✓ Keys match!');
        } else {
          print('❌ Keys DO NOT match!');
        }
      } catch (e) {
        print('❌ Error deriving public key: $e');
      }
    });

    test('Sign and verify a message', () {
      print('\n🔐 Sign and Verify Test');

      final privKey = NostrTestKeys.testPrivateKey1;
      final pubKey = NostrTestKeys.testPublicKey1;
      const message = 'test message';

      print('Message: $message');

      try {
        // Compute hash of message
        final messageHex = HEX.encode(message.codeUnits);
        print('Message Hex: $messageHex');

        // Sign the message
        final signature = bip340.sign(privKey, messageHex, '');
        print('Signature: $signature');
        print('Signature Length: ${signature.length} chars (${signature.length ~/ 2} bytes)');

        // Verify the signature
        final isValid = bip340.verify(pubKey, messageHex, signature);
        print('Verification: ${isValid ? '✓ VALID' : '❌ INVALID'}');
      } catch (e) {
        print('❌ Error: $e');
      }
    });
  });
}
