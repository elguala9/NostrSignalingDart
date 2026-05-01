// ignore_for_file: avoid_print
import 'dart:async';
import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';

const allRelayUrls = [
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

List<NostrRelayImpl> _createRelayInstances() =>
    allRelayUrls.map((url) => NostrRelayImpl(relayUrl: url)).toList();

Future<List<NostrRelayImpl>> _connectSequentially(
    List<NostrRelayImpl> relays) async {
  final connected = <NostrRelayImpl>[];
  for (final relay in relays) {
    try {
      await relay.connect().timeout(const Duration(seconds: 10));
      if (relay.isConnected()) {
        connected.add(relay);
      }
    } catch (e) {
      print('  ⚠ Relay ${relay.relayUrl} non connesso: $e');
    }
  }
  return connected;
}

Future<void> _disconnectAll(List<NostrRelayImpl> relays) async {
  for (final relay in relays) {
    try {
      if (relay.isConnected()) {
        await relay.disconnect().timeout(const Duration(seconds: 5));
      }
    } catch (_) {}
  }
}

void main() {
  group('NostrSignalingImpl with 10 real relays', () {
    late List<NostrRelayImpl> relayInstances;
    late NostrSignalingImpl signaling;

    setUp(() {
      relayInstances = _createRelayInstances();
    });

    tearDown(() async {
      await _disconnectAll(relayInstances);
    });

    test('connect connette a tutti i 10 relay', () async {
      final connected = await _connectSequentially(relayInstances);
      print('  Connessi: ${connected.length}/10 relay');

      expect(connected.length, greaterThanOrEqualTo(8),
          reason: 'Almeno 8 relay su 10 devono connettersi');
    }, timeout: const Timeout(Duration(seconds: 120)));

    test('disconnect disconnette dai relay connessi', () async {
      final connected = await _connectSequentially(relayInstances);
      expect(connected, isNotEmpty);

      await _disconnectAll(connected);

      final stillConnected = connected.where((r) => r.isConnected());
      expect(stillConnected, isEmpty);
    }, timeout: const Timeout(Duration(seconds: 120)));

    test('publish restituisce event ID valido sui relay connessi', () async {
      final connected = await _connectSequentially(relayInstances);

      signaling = NostrSignalingImpl(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
        relays: NostrRelayList(connected),
        useCompression: false,
      );

      const testData = [1, 2, 3, 4, 5];
      final eventId = await signaling.publish(testData);

      expect(eventId, isNotEmpty);
      expect(eventId.length, equals(64));
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('publish + callback recupera dati propagati', () async {
      final connected = await _connectSequentially(relayInstances);

      signaling = NostrSignalingImpl(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
        relays: NostrRelayList(connected),
        useCompression: false,
      );

      final uniqueData = [
        DateTime.now().millisecondsSinceEpoch % 256,
        77,
        88,
      ];

      final since = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 1;
      final completer = Completer<List<int>>();
      await signaling.subscribe(
        NostrTestKeys.testPublicKey1,
        EventCallback((id, data) {
          if (!completer.isCompleted && _listMatches(data, uniqueData)) {
            completer.complete(data);
          }
        }),
        since: since,
      );

      await signaling.publish(uniqueData);

      print('⏳ Attesa ricezione dati su ${connected.length} relay...');
      final recovered = await completer.future
          .timeout(const Duration(seconds: 15));

      print('  Dati originali:  $uniqueData');
      print('  Dati ricevuti:   $recovered');

      expect(recovered, equals(uniqueData));
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('publish multipli senza errori', () async {
      final connected = await _connectSequentially(relayInstances);

      signaling = NostrSignalingImpl(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
        relays: NostrRelayList(connected),
        useCompression: false,
      );

      const data1 = [10, 20, 30];
      const data2 = [40, 50, 60];
      const data3 = [70, 80, 90];

      final id1 = await signaling.publish(data1);
      final id2 = await signaling.publish(data2);
      final id3 = await signaling.publish(data3);

      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      expect(id3, isNotEmpty);
      expect(id1, isNot(id2));
      expect(id2, isNot(id3));

      print('  Event IDs: $id1, $id2, $id3');
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('isConnected true se almeno 1 relay connesso', () async {
      final connected = await _connectSequentially(relayInstances.take(3).toList());
      expect(connected, isNotEmpty);

      signaling = NostrSignalingImpl(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
        relays: NostrRelayList(connected),
        useCompression: false,
      );

      expect(signaling.isConnected(), true);
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('isConnected false se nessun relay connesso', () {
      signaling = NostrSignalingImpl(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
        relays: NostrRelayList(relayInstances),
        useCompression: false,
      );

      expect(signaling.isConnected(), false);
    });

    test('subscribe e unsubscribe sui relay connessi', () async {
      final connected = await _connectSequentially(relayInstances);

      signaling = NostrSignalingImpl(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
        relays: NostrRelayList(connected),
        useCompression: false,
      );

      final subId = await signaling.subscribe(
        NostrTestKeys.testPublicKey2,
        EventCallback((id, data) {}),
      );

      expect(subId, isNotEmpty);

      await signaling.unsubscribe(NostrTestKeys.testPublicKey2);
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('publish scala con i relay connessi (performance)', () async {
      final connected = await _connectSequentially(relayInstances);

      signaling = NostrSignalingImpl(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
        relays: NostrRelayList(connected),
        useCompression: false,
      );

      final testData = List.generate(100, (i) => i);

      final stopwatch = Stopwatch()..start();
      await signaling.publish(testData);
      stopwatch.stop();

      print(
          'Published to ${connected.length} relays in ${stopwatch.elapsedMilliseconds}ms');

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(10000),
        reason: 'Publish should complete within 10 seconds',
      );
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}

bool _listMatches(List<int> a, List<int> b) =>
    a.length == b.length &&
    List.generate(a.length, (i) => a[i] == b[i]).every((e) => e);
