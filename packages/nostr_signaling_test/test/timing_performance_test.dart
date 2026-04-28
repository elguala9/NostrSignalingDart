import 'dart:async';
import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';

class TimingRelay implements INostrRelay {
  final List<NostrEvent> publishedEvents = [];
  final Map<String, List<RelayEventCallback>> subscriptions = {};
  bool _isConnected = false;

  @override
  Future<void> connect() async {
    _isConnected = true;
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    subscriptions.clear();
    publishedEvents.clear();
  }

  @override
  bool isConnected() => _isConnected;

  @override
  Future<String> publishEvent(NostrEvent event) async {
    publishedEvents.add(event);
    for (final callbacks in subscriptions.values) {
      for (final callback in callbacks) {
        Future.microtask(() => callback(event));
      }
    }
    return event.id;
  }

  @override
  Future<String> subscribe(
    Map<String, dynamic> filter,
    RelayEventCallback onEvent,
  ) async {
    final subId = 'sub_${subscriptions.length + 1}';
    subscriptions.putIfAbsent(subId, () => []).add(onEvent);
    final authors = filter['authors'] as List<String>?;
    if (authors != null) {
      for (final event in publishedEvents) {
        if (authors.contains(event.pubkey)) {
          Future.microtask(() => onEvent(event));
        }
      }
    }
    return subId;
  }

  @override
  Future<void> unsubscribe(String subscriptionId) async {
    subscriptions.remove(subscriptionId);
  }
}

void main() {
  group('Performance & Timing Analysis', () {
    late TimingRelay relay;
    late NostrSignalingImpl peer1;
    late NostrSignalingImpl peer2;
    late NostrSignalingImpl peer3;

    setUp(() {
      relay = TimingRelay();
      relay.connect();

      peer1 = NostrSignalingImpl(
        pubkey: NostrTestKeys.testPublicKey1,
        privkey: NostrTestKeys.testPrivateKey1,
        relay: relay,
        useCompression: false,
      );

      peer2 = NostrSignalingImpl(
        pubkey: NostrTestKeys.testPublicKey2,
        privkey: NostrTestKeys.testPrivateKey2,
        relay: relay,
        useCompression: false,
      );

      peer3 = NostrSignalingImpl(
        pubkey: NostrTestKeys.testPublicKey3,
        privkey: NostrTestKeys.testPrivateKey3,
        relay: relay,
        useCompression: false,
      );
    });

    test('Single Message: Peer1 → Peer2', () async {
      print('\n╔════════════════════════════════════════════════════════╗');
      print('║     SINGLE MESSAGE: PEER1 → PEER2                   ║');
      print('╚════════════════════════════════════════════════════════╝\n');

      final testData = [1, 2, 3, 4, 5];
      late List<int> receivedData;
      final completer = Completer<void>();

      // Setup
      print('📍 SETUP');
      final setupStart = DateTime.now();
      await peer2.subscribe(peer1.pubkey, (id, data) {
        receivedData = data;
        completer.complete();
      });
      final setupTime = DateTime.now().difference(setupStart);
      print('   Sottoscrizione completata in: ${setupTime.inMicroseconds}μs\n');

      // Publish
      print('📤 PUBBLICAZIONE');
      print('   Dati: $testData');
      final publishStart = DateTime.now();
      final eventId = await peer1.publish(testData);
      final publishTime = DateTime.now().difference(publishStart);
      print('   Tempo di pubblicazione: ${publishTime.inMicroseconds}μs\n');

      // Receive
      print('📥 RICEZIONE');
      final receiveStart = DateTime.now();
      await completer.future;
      final receiveTime = DateTime.now().difference(receiveStart);
      print('   Tempo di ricezione: ${receiveTime.inMicroseconds}μs');
      print('   Dati ricevuti: $receivedData\n');

      // Summary
      final totalTime = DateTime.now().difference(setupStart);
      print('═══════════════════════════════════════════════════════');
      print('📊 RIEPILOGO TEMPI');
      print('═══════════════════════════════════════════════════════');
      print('Sottoscrizione:    ${setupTime.inMicroseconds.toString().padLeft(10)}μs');
      print('Pubblicazione:     ${publishTime.inMicroseconds.toString().padLeft(10)}μs');
      print('Ricezione:         ${receiveTime.inMicroseconds.toString().padLeft(10)}μs');
      print('Totale:            ${totalTime.inMicroseconds.toString().padLeft(10)}μs');
      print('═══════════════════════════════════════════════════════\n');

      expect(receivedData, equals(testData));
    });

    test('Bidirectional Exchange: Peer1 ↔ Peer2 ↔ Peer3', () async {
      print('\n╔════════════════════════════════════════════════════════╗');
      print('║  BIDIRECTIONAL: PEER1 ↔ PEER2 ↔ PEER3            ║');
      print('╚════════════════════════════════════════════════════════╝\n');

      final data1 = [10, 20, 30];
      final data2 = [40, 50, 60];
      final data3 = [70, 80, 90];

      late List<int> p2ReceivedFromP1;
      late List<int> p3ReceivedFromP1;
      late List<int> p1ReceivedFromP2;
      late List<int> p3ReceivedFromP2;
      late List<int> p1ReceivedFromP3;
      late List<int> p2ReceivedFromP3;

      final completers = {
        'p2←p1': Completer<void>(),
        'p3←p1': Completer<void>(),
        'p1←p2': Completer<void>(),
        'p3←p2': Completer<void>(),
        'p1←p3': Completer<void>(),
        'p2←p3': Completer<void>(),
      };

      // Setup subscriptions
      print('📍 SETUP SOTTOSCRIZIONI');
      final setupStart = DateTime.now();

      await peer2.subscribe(peer1.pubkey, (id, data) {
        p2ReceivedFromP1 = data;
        if (!completers['p2←p1']!.isCompleted) completers['p2←p1']!.complete();
      });
      await peer3.subscribe(peer1.pubkey, (id, data) {
        p3ReceivedFromP1 = data;
        if (!completers['p3←p1']!.isCompleted) completers['p3←p1']!.complete();
      });
      await peer1.subscribe(peer2.pubkey, (id, data) {
        p1ReceivedFromP2 = data;
        if (!completers['p1←p2']!.isCompleted) completers['p1←p2']!.complete();
      });
      await peer3.subscribe(peer2.pubkey, (id, data) {
        p3ReceivedFromP2 = data;
        if (!completers['p3←p2']!.isCompleted) completers['p3←p2']!.complete();
      });
      await peer1.subscribe(peer3.pubkey, (id, data) {
        p1ReceivedFromP3 = data;
        if (!completers['p1←p3']!.isCompleted) completers['p1←p3']!.complete();
      });
      await peer2.subscribe(peer3.pubkey, (id, data) {
        p2ReceivedFromP3 = data;
        if (!completers['p2←p3']!.isCompleted) completers['p2←p3']!.complete();
      });

      final setupTime = DateTime.now().difference(setupStart);
      print('   6 sottoscrizioni completate in: ${setupTime.inMicroseconds}μs\n');

      // Publish
      print('📤 PUBBLICAZIONE');
      final publishStart = DateTime.now();

      final p1PubStart = DateTime.now();
      await peer1.publish(data1);
      final p1PubTime = DateTime.now().difference(p1PubStart);
      print('   Peer1 pubblica [${data1.join(',')}] in ${p1PubTime.inMicroseconds}μs');

      final p2PubStart = DateTime.now();
      await peer2.publish(data2);
      final p2PubTime = DateTime.now().difference(p2PubStart);
      print('   Peer2 pubblica [${data2.join(',')}] in ${p2PubTime.inMicroseconds}μs');

      final p3PubStart = DateTime.now();
      await peer3.publish(data3);
      final p3PubTime = DateTime.now().difference(p3PubStart);
      print('   Peer3 pubblica [${data3.join(',')}] in ${p3PubTime.inMicroseconds}μs\n');

      // Receive
      print('📥 RICEZIONE');
      final receiveStart = DateTime.now();
      await Future.wait(completers.values.map((c) => c.future));
      final receiveTime = DateTime.now().difference(receiveStart);
      print('   Tutti i messaggi ricevuti in: ${receiveTime.inMicroseconds}μs\n');

      // Verify
      print('✓ Peer1 ricevuto: P2=${p1ReceivedFromP2.join(',')} P3=${p1ReceivedFromP3.join(',')}');
      print('✓ Peer2 ricevuto: P1=${p2ReceivedFromP1.join(',')} P3=${p2ReceivedFromP3.join(',')}');
      print('✓ Peer3 ricevuto: P1=${p3ReceivedFromP1.join(',')} P2=${p3ReceivedFromP2.join(',')}\n');

      // Summary
      final totalTime = DateTime.now().difference(setupStart);
      print('═══════════════════════════════════════════════════════');
      print('📊 RIEPILOGO TEMPI');
      print('═══════════════════════════════════════════════════════');
      print('Setup:             ${setupTime.inMicroseconds.toString().padLeft(10)}μs');
      print('Pub Peer1:         ${p1PubTime.inMicroseconds.toString().padLeft(10)}μs');
      print('Pub Peer2:         ${p2PubTime.inMicroseconds.toString().padLeft(10)}μs');
      print('Pub Peer3:         ${p3PubTime.inMicroseconds.toString().padLeft(10)}μs');
      print('Ricezione:         ${receiveTime.inMicroseconds.toString().padLeft(10)}μs');
      print('Totale:            ${totalTime.inMicroseconds.toString().padLeft(10)}μs');
      print('═══════════════════════════════════════════════════════\n');

      expect(p2ReceivedFromP1, equals(data1));
      expect(p3ReceivedFromP1, equals(data1));
      expect(p1ReceivedFromP2, equals(data2));
      expect(p3ReceivedFromP2, equals(data2));
      expect(p1ReceivedFromP3, equals(data3));
      expect(p2ReceivedFromP3, equals(data3));
    });

    test('Throughput: 50 messaggi da Peer1', () async {
      print('\n╔════════════════════════════════════════════════════════╗');
      print('║        THROUGHPUT: 50 MESSAGGI DA PEER1            ║');
      print('╚════════════════════════════════════════════════════════╝\n');

      int receivedCount = 0;
      final completer = Completer<void>();

      print('📍 SETUP');
      final setupStart = DateTime.now();
      await peer2.subscribe(peer1.pubkey, (id, data) {
        receivedCount++;
        if (receivedCount == 50) {
          completer.complete();
        }
      });
      final setupTime = DateTime.now().difference(setupStart);
      print('   Setup completato in: ${setupTime.inMicroseconds}μs\n');

      print('📤 INVIO DI 50 MESSAGGI');
      final publishStart = DateTime.now();

      for (int i = 1; i <= 50; i++) {
        final data = [i];
        await peer1.publish(data);
        if (i % 10 == 0) {
          print('   ✓ ${i} messaggi inviati');
        }
      }

      print('\n📥 RICEZIONE');
      await completer.future;
      final totalTime = DateTime.now().difference(publishStart);

      print('\n═══════════════════════════════════════════════════════');
      print('📊 RIEPILOGO PERFORMANCE');
      print('═══════════════════════════════════════════════════════');
      print('Messaggi inviati:     50');
      print('Messaggi ricevuti:    $receivedCount');
      print('Tempo totale:         ${totalTime.inMilliseconds}ms');
      print('Tempo medio/msg:      ${(totalTime.inMicroseconds / 50).toStringAsFixed(0)}μs');
      print('Throughput:           ${(50000 / totalTime.inMilliseconds).toStringAsFixed(0)} msg/sec');
      print('═══════════════════════════════════════════════════════\n');

      expect(receivedCount, equals(50));
    });
  });
}
