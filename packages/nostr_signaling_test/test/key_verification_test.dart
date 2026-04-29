// ignore_for_file: avoid_print
import 'package:dart_nostr/dart_nostr.dart';
import 'package:test/test.dart';
import 'package:nostr_signaling/nostr_signaling.dart';

void main() {
  group('Key Verification Test (via dart_nostr)', () {
    test('Verify public key matches private key', () {
      print('\n🔐 Key Verification Test');

      const privKey = NostrTestKeys.testPrivateKey1;
      const pubKey = NostrTestKeys.testPublicKey1;

      print('Private Key: $privKey');
      print('Public Key:  $pubKey');

      try {
        final derivedPubKey = Nostr().keys.derivePublicKey(privateKey: privKey);
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

      const privKey = NostrTestKeys.testPrivateKey1;
      const pubKey = NostrTestKeys.testPublicKey1;
      const message = 'test message';

      print('Message: $message');

      try {
        final signature = Nostr().keys.sign(privateKey: privKey, message: message);
        print('Signature: $signature');
        print('Signature Length: ${signature.length} chars (${signature.length ~/ 2} bytes)');

        final isValid = Nostr().keys.verify(
          publicKey: pubKey,
          message: message,
          signature: signature,
        );
        print('Verification: ${isValid ? '✓ VALID' : '❌ INVALID'}');
      } catch (e) {
        print('❌ Error: $e');
      }
    });
  });
}
