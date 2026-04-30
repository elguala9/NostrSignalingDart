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
      expect(NostrStandardRelays.damus, startsWith('wss://'));
      expect(NostrStandardRelays.nostr, startsWith('wss://'));
      expect(NostrStandardRelays.nos, startsWith('wss://'));
      expect(NostrStandardRelays.primal, startsWith('wss://'));
      expect(NostrStandardRelays.startr, startsWith('wss://'));
      expect(NostrStandardRelays.band, startsWith('wss://'));
      expect(NostrStandardRelays.purple, startsWith('wss://'));
      expect(NostrStandardRelays.snort, startsWith('wss://'));
      expect(NostrStandardRelays.wine, startsWith('wss://'));
      expect(NostrStandardRelays.offchain, startsWith('wss://'));
    });

    test('i relay sono diversi gli uni dagli altri', () {
      final allRelays = [
        NostrStandardRelays.damus,
        NostrStandardRelays.nostr,
        NostrStandardRelays.nos,
        NostrStandardRelays.primal,
        NostrStandardRelays.startr,
        NostrStandardRelays.band,
        NostrStandardRelays.purple,
        NostrStandardRelays.snort,
        NostrStandardRelays.wine,
        NostrStandardRelays.offchain,
      ];
      for (var i = 0; i < allRelays.length; i++) {
        for (var j = i + 1; j < allRelays.length; j++) {
          expect(allRelays[i], isNot(allRelays[j]));
        }
      }
    });

    test('gli URL dei relay non sono vuoti', () {
      expect(NostrStandardRelays.damus.isNotEmpty, true);
      expect(NostrStandardRelays.nostr.isNotEmpty, true);
      expect(NostrStandardRelays.nos.isNotEmpty, true);
      expect(NostrStandardRelays.primal.isNotEmpty, true);
      expect(NostrStandardRelays.startr.isNotEmpty, true);
      expect(NostrStandardRelays.band.isNotEmpty, true);
      expect(NostrStandardRelays.purple.isNotEmpty, true);
      expect(NostrStandardRelays.snort.isNotEmpty, true);
      expect(NostrStandardRelays.wine.isNotEmpty, true);
      expect(NostrStandardRelays.offchain.isNotEmpty, true);
    });

    test('10 relay disponibili per test', () {
      final allRelays = [
        NostrStandardRelays.damus,
        NostrStandardRelays.nostr,
        NostrStandardRelays.nos,
        NostrStandardRelays.primal,
        NostrStandardRelays.startr,
        NostrStandardRelays.band,
        NostrStandardRelays.purple,
        NostrStandardRelays.snort,
        NostrStandardRelays.wine,
        NostrStandardRelays.offchain,
      ];
      expect(allRelays.length, equals(10));
      expect(allRelays.toSet().length, equals(10));
    });
  });
}
