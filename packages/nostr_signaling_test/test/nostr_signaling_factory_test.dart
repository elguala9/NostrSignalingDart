import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';

void main() {
  group('NostrSignalingFactory', () {
    test('create() ritorna una INostrSignaling', () {
      final signaling = NostrSignalingFactory.create(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
      );

      expect(signaling, isA<INostrSignaling>());
    });

    test('create() usa il relay di default se non specificato', () {
      final signaling = NostrSignalingFactory.create(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
      );

      expect(signaling, isNotNull);
    });

    test('create() accetta un relay URL custom', () {
      const customRelay = 'wss://custom-relay.example.com';

      final signaling = NostrSignalingFactory.create(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
        relayUrls: [customRelay],
      );

      expect(signaling, isA<INostrSignaling>());
    });

    test('create() con compressione abilitata', () {
      final signaling = NostrSignalingFactory.create(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
        useCompression: true,
      );

      expect(signaling, isA<INostrSignaling>());
    });

    test('createWithCustomRelays() accetta una lista di relay iniettati', () {
      final customRelay1 = NostrRelayImpl(relayUrl: NostrStandardRelays.nos);
      final customRelay2 = NostrRelayImpl(relayUrl: NostrStandardRelays.damus);

      final signaling = NostrSignalingFactory.createWithCustomRelays(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
        relays: [customRelay1, customRelay2],
      );

      expect(signaling, isA<INostrSignaling>());
    });

    test('create() con multi-relay tramite URL', () {
      final signaling = NostrSignalingFactory.create(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
        relayUrls: [NostrStandardRelays.nos, NostrStandardRelays.damus],
      );

      expect(signaling, isA<INostrSignaling>());
    });

    test('create() con compressione e multi-relay', () {
      final signaling = NostrSignalingFactory.create(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
        relayUrls: [NostrStandardRelays.nos, NostrStandardRelays.damus],
        useCompression: true,
      );

      expect(signaling, isA<INostrSignaling>());
    });

    test('tutti i factory methods preservano le chiavi', () {
      const pubkey = NostrTestKeys.testPublicKey2;
      const privkey = NostrTestKeys.testPrivateKey2;

      final signaling = NostrSignalingFactory.create(
        keyPair: NostrKeyPair(
          privateKey: privkey,
          publicKey: pubkey,
        ),
      );

      final impl = signaling as NostrSignalingImpl;
      expect(impl.pubkey, equals(pubkey));
      expect(impl.privkey, equals(privkey));
    });
  });
}
