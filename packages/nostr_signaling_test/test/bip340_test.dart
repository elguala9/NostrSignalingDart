import 'package:bip340/bip340.dart' as bip340;
import 'package:hex/hex.dart';
import 'package:test/test.dart';

void main() {
  group('BIP340 Signature Test', () {
    test('Test bip340.sign() with known private key', () {
      // Test vector from BIP340 spec
      final privateKey = '0000000000000000000000000000000000000000000000000000000000000001';
      final message = '0000000000000000000000000000000000000000000000000000000000000000';

      print('\n🔐 BIP340 Signature Test');
      print('Private Key: $privateKey');
      print('Message: $message');

      try {
        final signature = bip340.sign(privateKey, message, '');
        print('✓ Signature generated: $signature');
        print('  Length: ${signature.length} chars (${signature.length ~/ 2} bytes)');

        expect(signature.length, equals(128), reason: 'Signature should be 128 hex chars (64 bytes)');
      } catch (e) {
        print('❌ Error: $e');
        rethrow;
      }
    });

    test('Test bip340.sign() with a simple message', () {
      // Using test constants from the project
      final privateKey = '009d7edc1c7b89f2e3d4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6';
      final message = 'abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234';

      print('\n🔐 BIP340 Signature Test with Project Keys');
      print('Private Key: $privateKey');
      print('Message: $message');

      try {
        final signature = bip340.sign(privateKey, message, '');
        print('✓ Signature generated: $signature');
        print('  Length: ${signature.length} chars (${signature.length ~/ 2} bytes)');

        expect(signature.length, equals(128), reason: 'Signature should be 128 hex chars (64 bytes)');
      } catch (e) {
        print('❌ Error: $e');
        rethrow;
      }
    });
  });
}
