import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';

void main() {
  group('NostrTestKeys', () {
    test('testPrivateKey1 è una stringa hex valida', () {
      expect(NostrTestKeys.testPrivateKey1, isA<String>());
      expect(NostrTestKeys.testPrivateKey1.length, equals(64)); // 32 bytes = 64 hex chars
      // Verifica che sia hex
      expect(
        RegExp(r'^[0-9a-f]+$').hasMatch(NostrTestKeys.testPrivateKey1),
        true,
      );
    });

    test('testPublicKey1 è una stringa hex valida', () {
      expect(NostrTestKeys.testPublicKey1, isA<String>());
      expect(NostrTestKeys.testPublicKey1.length, equals(64)); // 32 bytes = 64 hex chars
      expect(
        RegExp(r'^[0-9a-f]+$').hasMatch(NostrTestKeys.testPublicKey1),
        true,
      );
    });

    test('tutte le chiavi private hanno la lunghezza corretta', () {
      expect(NostrTestKeys.testPrivateKey1.length, equals(64));
      expect(NostrTestKeys.testPrivateKey2.length, equals(64));
      expect(NostrTestKeys.testPrivateKey3.length, equals(64));
      expect(NostrTestKeys.testPrivateKeyLuca.length, equals(64));
    });

    test('tutte le chiavi pubbliche hanno la lunghezza corretta', () {
      expect(NostrTestKeys.testPublicKey1.length, equals(64));
      expect(NostrTestKeys.testPublicKey2.length, equals(64));
      expect(NostrTestKeys.testPublicKey3.length, equals(64));
      expect(NostrTestKeys.testPublicKeyLuca.length, equals(64));
    });

    test('le chiavi private sono diverse le une dalle altre', () {
      expect(NostrTestKeys.testPrivateKey1, isNot(NostrTestKeys.testPrivateKey2));
      expect(NostrTestKeys.testPrivateKey2, isNot(NostrTestKeys.testPrivateKey3));
      expect(NostrTestKeys.testPrivateKey1, isNot(NostrTestKeys.testPrivateKeyLuca));
    });

    test('le chiavi pubbliche sono diverse le une dalle altre', () {
      expect(NostrTestKeys.testPublicKey1, isNot(NostrTestKeys.testPublicKey2));
      expect(NostrTestKeys.testPublicKey2, isNot(NostrTestKeys.testPublicKey3));
      expect(NostrTestKeys.testPublicKey1, isNot(NostrTestKeys.testPublicKeyLuca));
    });
  });

  group('NostrTestRelays', () {
    test('tutti i relay hanno URL validi', () {
      expect(NostrTestRelays.damus, startsWith('wss://'));
      expect(NostrTestRelays.nostr, startsWith('wss://'));
      expect(NostrTestRelays.nos, startsWith('wss://'));
      expect(NostrTestRelays.primal, startsWith('wss://'));
      expect(NostrTestRelays.startr, startsWith('wss://'));
      expect(NostrTestRelays.band, startsWith('wss://'));
      expect(NostrTestRelays.purple, startsWith('wss://'));
      expect(NostrTestRelays.snort, startsWith('wss://'));
      expect(NostrTestRelays.wine, startsWith('wss://'));
      expect(NostrTestRelays.offchain, startsWith('wss://'));
    });

    test('i relay sono diversi gli uni dagli altri', () {
      final allRelays = [
        NostrTestRelays.damus,
        NostrTestRelays.nostr,
        NostrTestRelays.nos,
        NostrTestRelays.primal,
        NostrTestRelays.startr,
        NostrTestRelays.band,
        NostrTestRelays.purple,
        NostrTestRelays.snort,
        NostrTestRelays.wine,
        NostrTestRelays.offchain,
      ];
      for (var i = 0; i < allRelays.length; i++) {
        for (var j = i + 1; j < allRelays.length; j++) {
          expect(allRelays[i], isNot(allRelays[j]));
        }
      }
    });

    test('gli URL dei relay non sono vuoti', () {
      expect(NostrTestRelays.damus.isNotEmpty, true);
      expect(NostrTestRelays.nostr.isNotEmpty, true);
      expect(NostrTestRelays.nos.isNotEmpty, true);
      expect(NostrTestRelays.primal.isNotEmpty, true);
      expect(NostrTestRelays.startr.isNotEmpty, true);
      expect(NostrTestRelays.band.isNotEmpty, true);
      expect(NostrTestRelays.purple.isNotEmpty, true);
      expect(NostrTestRelays.snort.isNotEmpty, true);
      expect(NostrTestRelays.wine.isNotEmpty, true);
      expect(NostrTestRelays.offchain.isNotEmpty, true);
    });

    test('10 relay disponibili per test', () {
      final allRelays = [
        NostrTestRelays.damus,
        NostrTestRelays.nostr,
        NostrTestRelays.nos,
        NostrTestRelays.primal,
        NostrTestRelays.startr,
        NostrTestRelays.band,
        NostrTestRelays.purple,
        NostrTestRelays.snort,
        NostrTestRelays.wine,
        NostrTestRelays.offchain,
      ];
      expect(allRelays.length, equals(10));
      expect(allRelays.toSet().length, equals(10));
    });
  });
}
