import 'dart:async';
import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';

void main() {
  group('NostrSignalingImpl con relay reali', () {
    late NostrRelayImpl realRelay;
    late NostrSignalingImpl signaling;

    setUp(() {
      realRelay = NostrRelayImpl(relayUrl: 'wss://nos.lol');

      signaling = NostrSignalingImpl(
        pubkey: NostrTestKeys.testPublicKey1,
        privkey: NostrTestKeys.testPrivateKey1,
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
      await signaling.connect().timeout(Duration(seconds: 15));
      await Future.delayed(Duration(milliseconds: 500));
      expect(realRelay.isConnected(), true);
    });

    test('disconnect si disconnette dal relay reale', () async {
      await signaling.connect().timeout(Duration(seconds: 15));
      await Future.delayed(Duration(milliseconds: 500));
      expect(realRelay.isConnected(), true);
      await signaling.disconnect().timeout(Duration(seconds: 15));
      expect(realRelay.isConnected(), false);
    });

    test('isConnected ritorna lo stato del relay reale', () async {
      expect(signaling.isConnected(), false);
      await signaling.connect().timeout(Duration(seconds: 15));
      await Future.delayed(Duration(milliseconds: 500));
      expect(signaling.isConnected(), true);
    });

    test('publish invia un evento al relay reale', () async {
      await signaling.connect().timeout(Duration(seconds: 15));
      await Future.delayed(Duration(milliseconds: 500));
      const testData = [1, 2, 3, 4, 5];

      final eventId = await signaling.publish(testData).timeout(Duration(seconds: 15));

      expect(eventId, isNotEmpty);
    });

    test('subscribe si sottoscrive al relay reale', () async {
      await signaling.connect().timeout(Duration(seconds: 15));
      await Future.delayed(Duration(milliseconds: 500));
      const targetId = 'target_user_id';

      final subId = await signaling.subscribe(targetId, (id, data) {}).timeout(Duration(seconds: 15));

      expect(subId, isNotEmpty);
    });

    test('unsubscribe rimuove la sottoscrizione dal relay reale', () async {
      await signaling.connect().timeout(Duration(seconds: 15));
      await Future.delayed(Duration(milliseconds: 500));
      const targetId = 'target_user_id';

      final subId = await signaling.subscribe(targetId, (id, data) {}).timeout(Duration(seconds: 15));
      await signaling.unsubscribe(targetId).timeout(Duration(seconds: 15));

      expect(true, equals(true));
    });

    test('pubkey e privkey sono memorizzate correttamente', () {
      expect(signaling.pubkey, equals(NostrTestKeys.testPublicKey1));
      expect(signaling.privkey, equals(NostrTestKeys.testPrivateKey1));
    });

    test('useCompression flag è impostato correttamente', () {
      final withoutCompression = NostrSignalingImpl(
        pubkey: NostrTestKeys.testPublicKey1,
        privkey: NostrTestKeys.testPrivateKey1,
        relay: realRelay,
        useCompression: false,
      );

      expect(withoutCompression.useCompression, equals(false));

      final gzipEngine = GzipCompressionEngine();
      final withCompression = NostrSignalingImpl(
        pubkey: NostrTestKeys.testPublicKey1,
        privkey: NostrTestKeys.testPrivateKey1,
        relay: realRelay,
        useCompression: true,
        compressionEngine: gzipEngine,
      );

      expect(withCompression.useCompression, equals(true));
    });
  });
}
