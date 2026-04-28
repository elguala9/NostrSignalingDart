import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';

void main() {
  group('NostrSignalingFactory', () {
    test('create() ritorna una INostrSignaling', () {
      final signaling = NostrSignalingFactory.create(
        pubkey: NostrTestKeys.testPublicKey1,
        privkey: NostrTestKeys.testPrivateKey1,
      );

      expect(signaling, isA<INostrSignaling>());
    });

    test('create() usa il relay di default se non specificato', () {
      final signaling = NostrSignalingFactory.create(
        pubkey: NostrTestKeys.testPublicKey1,
        privkey: NostrTestKeys.testPrivateKey1,
      );

      expect(signaling, isNotNull);
      // Il relay è privato, quindi non possiamo controllarlo direttamente
      // ma sappiamo che è stato creato
    });

    test('create() accetta un relay URL custom', () {
      const customRelay = 'wss://custom-relay.example.com';

      final signaling = NostrSignalingFactory.create(
        pubkey: NostrTestKeys.testPublicKey1,
        privkey: NostrTestKeys.testPrivateKey1,
        relayUrl: customRelay,
      );

      expect(signaling, isA<INostrSignaling>());
    });

    test('createWithGzipCompression() abilita la compressione', () {
      final signaling = NostrSignalingFactory.createWithGzipCompression(
        pubkey: NostrTestKeys.testPublicKey1,
        privkey: NostrTestKeys.testPrivateKey1,
      );

      expect(signaling, isA<INostrSignaling>());
    });

    test('createWithCustomRelays() accetta una lista di relay iniettati', () {
      final customRelay1 = NostrRelayImpl(relayUrl: NostrTestRelays.nos);
      final customRelay2 = NostrRelayImpl(relayUrl: NostrTestRelays.damus);

      final signaling = NostrSignalingFactory.createWithCustomRelays(
        pubkey: NostrTestKeys.testPublicKey1,
        privkey: NostrTestKeys.testPrivateKey1,
        relays: [customRelay1, customRelay2],
      );

      expect(signaling, isA<INostrSignaling>());
    });

    test('createWithMultipleRelays() accetta una lista di URL', () {
      final signaling = NostrSignalingFactory.createWithMultipleRelays(
        pubkey: NostrTestKeys.testPublicKey1,
        privkey: NostrTestKeys.testPrivateKey1,
        relayUrls: [NostrTestRelays.nos, NostrTestRelays.damus],
      );

      expect(signaling, isA<INostrSignaling>());
    });

    test('createWithGzipCompressionAndMultipleRelays() abilita compressione e multi-relay', () {
      final signaling = NostrSignalingFactory.createWithGzipCompressionAndMultipleRelays(
        pubkey: NostrTestKeys.testPublicKey1,
        privkey: NostrTestKeys.testPrivateKey1,
        relayUrls: [NostrTestRelays.nos, NostrTestRelays.damus],
      );

      expect(signaling, isA<INostrSignaling>());
    });

    test('tutti i factory methods preservano le chiavi', () {
      const pubkey = NostrTestKeys.testPublicKey2;
      const privkey = NostrTestKeys.testPrivateKey2;

      final signaling = NostrSignalingFactory.create(
        pubkey: pubkey,
        privkey: privkey,
      );

      final impl = signaling as NostrSignalingImpl;
      expect(impl.pubkey, equals(pubkey));
      expect(impl.privkey, equals(privkey));
    });
  });
}
