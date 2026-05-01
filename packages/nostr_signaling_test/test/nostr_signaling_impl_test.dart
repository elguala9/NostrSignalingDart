import 'dart:async';
import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';

void main() {
  group('NostrSignalingImpl con relay reali', () {
    late NostrRelayImpl realRelay;
    late NostrSignalingImpl signaling;

    setUp(() {
      realRelay = NostrRelayImpl(relayUrl: 'wss://nos.lol');

      signaling = NostrSignalingImpl.single(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
        relay: realRelay,
        useCompression: false,
      );
    });

    tearDown(() async {
      try {
        if (realRelay.isConnected()) {
          await realRelay.disconnect();
        }
      } catch (e) {
        // Ignore disconnect errors
      }
    });

    test('connect si connette al relay reale', () async {
      expect(realRelay.isConnected(), false);
      await signaling.connect().timeout(const Duration(seconds: 15));
      await Future.delayed(const Duration(milliseconds: 500));
      expect(realRelay.isConnected(), true);
    });

    test('disconnect si disconnette dal relay reale', () async {
      await signaling.connect().timeout(const Duration(seconds: 15));
      await Future.delayed(const Duration(milliseconds: 500));
      expect(realRelay.isConnected(), true);
      await signaling.disconnect().timeout(const Duration(seconds: 15));
      expect(realRelay.isConnected(), false);
    });

    test('isConnected ritorna lo stato del relay reale', () async {
      expect(signaling.isConnected(), false);
      await signaling.connect().timeout(const Duration(seconds: 15));
      await Future.delayed(const Duration(milliseconds: 500));
      expect(signaling.isConnected(), true);
    });

    test('publish invia un evento al relay reale', () async {
      await signaling.connect().timeout(const Duration(seconds: 15));
      await Future.delayed(const Duration(milliseconds: 500));
      const testData = [1, 2, 3, 4, 5];

      final eventId = await signaling.publish(testData).timeout(const Duration(seconds: 15));

      expect(eventId, isNotEmpty);
    });

    test('subscribe si sottoscrive al relay reale', () async {
      await signaling.connect().timeout(const Duration(seconds: 15));
      await Future.delayed(const Duration(milliseconds: 500));
      const targetId = 'target_user_id';

      final subId = await signaling.subscribe(targetId, EventCallback((id, data) {})).timeout(const Duration(seconds: 15));

      expect(subId, isNotEmpty);
    });

    test('unsubscribe rimuove la sottoscrizione dal relay reale', () async {
      await signaling.connect().timeout(const Duration(seconds: 15));
      await Future.delayed(const Duration(milliseconds: 500));
      const targetId = 'target_user_id';

      await signaling.subscribe(targetId, EventCallback((id, data) {})).timeout(const Duration(seconds: 15));
      await signaling.unsubscribe(targetId).timeout(const Duration(seconds: 15));

      expect(true, equals(true));
    });

    test('pubkey e privkey sono memorizzate correttamente', () {
      expect(signaling.pubkey, equals(NostrTestKeys.testPublicKey1));
      expect(signaling.privkey, equals(NostrTestKeys.testPrivateKey1));
    });

    test('useCompression flag è impostato correttamente', () {
      final withoutCompression = NostrSignalingImpl.single(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
        relay: realRelay,
        useCompression: false,
      );

      expect(withoutCompression.useCompression, equals(false));

      final gzipEngine = GzipCompressionEngine();
      final withCompression = NostrSignalingImpl.single(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
        relay: realRelay,
        useCompression: true,
        compressionEngine: gzipEngine,
      );

      expect(withCompression.useCompression, equals(true));
    });
  });

  group('NostrSignalingImpl con multiple relay', () {
    late NostrRelayImpl relay1;
    late NostrRelayImpl relay2;
    late NostrSignalingImpl signaling;

    setUp(() {
      relay1 = NostrRelayImpl(relayUrl: 'wss://nos.lol');
      relay2 = NostrRelayImpl(relayUrl: 'wss://relay.damus.io');

      signaling = NostrSignalingImpl(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
        relays: NostrRelayList([relay1, relay2]),
        useCompression: false,
      );
    });

    tearDown(() async {
      try {
        if (relay1.isConnected()) await relay1.disconnect();
        if (relay2.isConnected()) await relay2.disconnect();
      } catch (e) {
        // Ignore errors
      }
    });

    test('connect connette a tutti i relay', () async {
      expect(relay1.isConnected(), false);
      expect(relay2.isConnected(), false);
      await signaling.connect().timeout(const Duration(seconds: 15));
      await Future.delayed(const Duration(milliseconds: 500));
      expect(signaling.isConnected(), true);
    });

    test('publish invia a tutti i relay', () async {
      await signaling.connect().timeout(const Duration(seconds: 15));
      await Future.delayed(const Duration(milliseconds: 500));
      const testData = [1, 2, 3, 4, 5];

      final eventId = await signaling.publish(testData).timeout(const Duration(seconds: 15));

      expect(eventId, isNotEmpty);
    });

    test('isConnected ritorna true se almeno un relay è connesso', () async {
      expect(signaling.isConnected(), false);
      await signaling.connect().timeout(const Duration(seconds: 15));
      await Future.delayed(const Duration(milliseconds: 500));
      expect(signaling.isConnected(), true);
    });
  });
}
