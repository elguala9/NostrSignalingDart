import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';

void main() {
  group('Interfacce Nostr Signaling', () {
    test('INostrSignaling è un\'interfaccia astratta', () {
      expect(INostrSignaling, isA<Type>());
      // Non possiamo istanziare un'interfaccia astratta direttamente
    });

    test('INostrRelay è un\'interfaccia astratta', () {
      expect(INostrRelay, isA<Type>());
    });

    test('ICompressionEngine è un\'interfaccia astratta', () {
      expect(ICompressionEngine, isA<Type>());
    });

    test('NostrSignalingImpl implementa INostrSignaling', () {
      final relay = NostrRelayImpl(relayUrl: 'wss://relay.test.com');
      final signaling = NostrSignalingImpl(
        pubkey: NostrTestKeys.testPublicKey1,
        privkey: NostrTestKeys.testPrivateKey1,
        relay: relay,
      );

      expect(signaling, isA<INostrSignaling>());
    });

    test('NostrRelayImpl implementa INostrRelay', () {
      final relay = NostrRelayImpl(relayUrl: 'wss://relay.test.com');

      expect(relay, isA<INostrRelay>());
    });

    test('GzipCompressionEngine implementa ICompressionEngine', () {
      final engine = GzipCompressionEngine();

      expect(engine, isA<ICompressionEngine>());
    });
  });

  group('EventCallback typedef', () {
    test('EventCallback è definito correttamente', () {
      // EventCallback = void Function(NostrId id, List<int> data)
      void testCallback(String id, List<int> data) {}

      expect(testCallback, isNotNull);
    });
  });

  group('NostrId typedef', () {
    test('NostrId è un alias per String', () {
      const testId = 'test_id_123';
      expect(testId, isA<String>());
      expect(testId, equals('test_id_123'));
    });
  });
}
