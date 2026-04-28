import 'package:test/test.dart';
import 'package:nostr_signaling/nostr_signaling.dart';

void main() {
  group('NostrKeyPair', () {
    test('crea una coppia di chiavi valida da chiave privata', () {
      const privateKey =
          '0000000000000000000000000000000000000000000000000000000000000001';
      const expectedPublicKey =
          '79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798';

      final keyPair = NostrKeyPair.fromPrivateKey(privateKey);

      expect(keyPair.privateKey, equals(privateKey));
      expect(keyPair.publicKey, equals(expectedPublicKey));
    });

    test('valida una coppia di chiavi valida', () {
      final keyPair = NostrKeyPair.fromPrivateKey(
        '0000000000000000000000000000000000000000000000000000000000000001',
      );

      expect(keyPair.isValid(), isTrue);
    });

    test('riconosce una coppia di chiavi non valida', () {
      final keyPair = NostrKeyPair(
        privateKey:
            '0000000000000000000000000000000000000000000000000000000000000001',
        publicKey: 'chiave_pubblica_errata_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
      );

      expect(keyPair.isValid(), isFalse);
    });

    test('confronta due coppie di chiavi uguali', () {
      const privateKey =
          '0000000000000000000000000000000000000000000000000000000000000001';

      final keyPair1 = NostrKeyPair.fromPrivateKey(privateKey);
      final keyPair2 = NostrKeyPair.fromPrivateKey(privateKey);

      expect(keyPair1, equals(keyPair2));
    });
  });

  group('NostrKeys', () {
    test('genera una nuova coppia di chiavi casuale', () {
      final keyPair1 = NostrKeys.generate();
      final keyPair2 = NostrKeys.generate();

      // Le chiavi generate dovrebbero essere non vuote
      expect(keyPair1.privateKey, isNotEmpty);
      expect(keyPair1.publicKey, isNotEmpty);
      expect(keyPair2.privateKey, isNotEmpty);
      expect(keyPair2.publicKey, isNotEmpty);

      // Le chiavi private dovrebbero avere il formato corretto
      expect(keyPair1.privateKey.length, equals(64));
      expect(keyPair2.privateKey.length, equals(64));

      // Entrambe le coppie dovrebbero essere valide
      expect(keyPair1.isValid(), isTrue);
      expect(keyPair2.isValid(), isTrue);

      // Con alta probabilità, due chiavi generate dovrebbero essere diverse
      // (ma non garantito per il test, quindi lo saltiamo se accade)
    });

    test('crea una coppia da chiave privata hex', () {
      const privateKey =
          '0000000000000000000000000000000000000000000000000000000000000002';
      const expectedPublicKey =
          'c6047f9441ed7d6d3045406e95c07cd85c778e4b8cef3ca7abac09b95c709ee5';

      final keyPair = NostrKeys.fromPrivateKeyHex(privateKey);

      expect(keyPair.privateKey, equals(privateKey));
      expect(keyPair.publicKey, equals(expectedPublicKey));
    });

    test('importa una coppia di chiavi dai due valori hex', () {
      const privateKey =
          '0000000000000000000000000000000000000000000000000000000000000001';
      const publicKey =
          '79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798';

      final keyPair = NostrKeys.fromHex(
        privateKeyHex: privateKey,
        publicKeyHex: publicKey,
      );

      expect(keyPair.privateKey, equals(privateKey));
      expect(keyPair.publicKey, equals(publicKey));
    });

    test('lancia eccezione quando le chiavi non corrispondono', () {
      const privateKey =
          '0000000000000000000000000000000000000000000000000000000000000001';
      const wrongPublicKey = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

      expect(
        () => NostrKeys.fromHex(
          privateKeyHex: privateKey,
          publicKeyHex: wrongPublicKey,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('valida il formato della chiave privata', () {
      expect(
        NostrKeys.isValidPrivateKeyFormat(
          '0000000000000000000000000000000000000000000000000000000000000001',
        ),
        isTrue,
      );

      expect(
        NostrKeys.isValidPrivateKeyFormat('troppo_corta'),
        isFalse,
      );

      expect(
        NostrKeys.isValidPrivateKeyFormat('zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz'),
        isFalse,
      );
    });

    test('valida il formato della chiave pubblica', () {
      expect(
        NostrKeys.isValidPublicKeyFormat(
          '79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798',
        ),
        isTrue,
      );

      expect(
        NostrKeys.isValidPublicKeyFormat('troppo_corta'),
        isFalse,
      );

      expect(
        NostrKeys.isValidPublicKeyFormat('zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz'),
        isFalse,
      );
    });
  });
}
