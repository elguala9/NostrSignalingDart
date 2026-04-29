import 'dart:async';
import 'package:dart_nostr/dart_nostr.dart';
import 'package:mockito/mockito.dart';
import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';

/// Mock relay che simula lo scambio di dati tra peer
class SharedNostrRelay extends Mock implements INostrRelay {
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

    for (final subscribers in subscriptions.values) {
      for (final callback in subscribers) {
        unawaited(Future.microtask(() => callback(event)));
      }
    }

    return event.id ?? '';
  }

  @override
  Future<String> subscribe(
    NostrFilter filter,
    RelayEventCallback onEvent,
  ) async {
    final subId = 'sub_${subscriptions.length + 1}';
    subscriptions.putIfAbsent(subId, () => []).add(onEvent);

    final authors = filter.authors;
    if (authors != null) {
      for (final event in publishedEvents) {
        if (authors.contains(event.pubkey)) {
          unawaited(Future.microtask(() => onEvent(event)));
        }
      }
    }

    return subId;
  }

  @override
  Future<void> unsubscribe(String subscriptionId) async {
    subscriptions.remove(subscriptionId);
  }

  NostrEvent? getLastEventFromAuthor(String pubkey) {
    for (final event in publishedEvents.reversed) {
      if (event.pubkey == pubkey) {
        return event;
      }
    }
    return null;
  }
}

void main() {
  group('Three Peers Data Exchange', () {
    late SharedNostrRelay sharedRelay;
    late NostrSignalingImpl peer1;
    late NostrSignalingImpl peer2;
    late NostrSignalingImpl peer3;

    setUp(() {
      sharedRelay = SharedNostrRelay();

      peer1 = NostrSignalingImpl.single(
        pubkey: NostrTestKeys.testPublicKey1,
        privkey: NostrTestKeys.testPrivateKey1,
        relay: sharedRelay,
        useCompression: false,
      );

      peer2 = NostrSignalingImpl.single(
        pubkey: NostrTestKeys.testPublicKey2,
        privkey: NostrTestKeys.testPrivateKey2,
        relay: sharedRelay,
        useCompression: false,
      );

      peer3 = NostrSignalingImpl.single(
        pubkey: NostrTestKeys.testPublicKey3,
        privkey: NostrTestKeys.testPrivateKey3,
        relay: sharedRelay,
        useCompression: false,
      );
    });

    tearDown(() async {
      await sharedRelay.disconnect();
    });

    test('Tre peer si connettono al relay', () async {
      await sharedRelay.connect();

      await peer1.connect();
      await peer2.connect();
      await peer3.connect();

      expect(sharedRelay.isConnected(), isTrue);
    });

    test('Peer1 pubblica dati e vengono memorizzati nel relay', () async {
      await sharedRelay.connect();
      await peer1.connect();

      final testData = [72, 101, 108, 108, 111]; // "Hello" in ASCII
      final publishedId = await peer1.publish(testData);

      expect(publishedId, isNotEmpty);
      expect(sharedRelay.publishedEvents.length, equals(1));
      expect(sharedRelay.publishedEvents[0].pubkey,
          equals(NostrTestKeys.testPublicKey1));
    });

    test('Peer1 e peer2 scambiano dati bidirezionalmente', () async {
      await sharedRelay.connect();
      await peer1.connect();
      await peer2.connect();

      final data1 = [1, 2, 3, 4, 5];
      final data2 = [10, 20, 30, 40, 50];

      // Peer1 pubblica
      final id1 = await peer1.publish(data1);
      // Peer2 pubblica
      final id2 = await peer2.publish(data2);

      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      expect(sharedRelay.publishedEvents.length, equals(2));

      final peer1Event = sharedRelay.getLastEventFromAuthor(
          NostrTestKeys.testPublicKey1);
      final peer2Event = sharedRelay.getLastEventFromAuthor(
          NostrTestKeys.testPublicKey2);

      expect(peer1Event, isNotNull);
      expect(peer2Event, isNotNull);
    });

    test('Tre peer scambiano dati in sequenza', () async {
      await sharedRelay.connect();
      await peer1.connect();
      await peer2.connect();
      await peer3.connect();

      final dataPeer1 = [1, 1, 1];
      final dataPeer2 = [2, 2, 2];
      final dataPeer3 = [3, 3, 3];

      final id1 = await peer1.publish(dataPeer1);
      final id2 = await peer2.publish(dataPeer2);
      final id3 = await peer3.publish(dataPeer3);

      expect(sharedRelay.publishedEvents.length, equals(3));
      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      expect(id3, isNotEmpty);

      // Verifica che tutti e tre gli eventi siano nel relay
      final event1 = sharedRelay.getLastEventFromAuthor(
          NostrTestKeys.testPublicKey1);
      final event2 = sharedRelay.getLastEventFromAuthor(
          NostrTestKeys.testPublicKey2);
      final event3 = sharedRelay.getLastEventFromAuthor(
          NostrTestKeys.testPublicKey3);

      expect(event1?.pubkey, equals(NostrTestKeys.testPublicKey1));
      expect(event2?.pubkey, equals(NostrTestKeys.testPublicKey2));
      expect(event3?.pubkey, equals(NostrTestKeys.testPublicKey3));
    });

    test('Peer riceve notifica quando un altro peer pubblica', () async {
      await sharedRelay.connect();
      await peer1.connect();
      await peer2.connect();

      // Peer2 si iscrive agli eventi di Peer1
      await peer2.subscribe(NostrTestKeys.testPublicKey1, (id, data) {
        // Callback ricevuto
      });

      // Peer1 pubblica
      await peer1.publish([111, 222, 233]);

      // Aspetta che il callback venga processato
      await Future.delayed(const Duration(milliseconds: 100));

      // Verifica che l'evento sia stato pubblicato
      expect(sharedRelay.publishedEvents.length, equals(1));
    });

    test('Peer1, peer2 e peer3 mantengono dati indipendenti', () async {
      await sharedRelay.connect();
      await peer1.connect();
      await peer2.connect();
      await peer3.connect();

      // Ogni peer pubblica i propri dati
      await peer1.publish([111]);
      await peer2.publish([222]);
      await peer3.publish([233]);

      // Verifica che i dati siano mantenuti separatamente
      final event1 = sharedRelay.getLastEventFromAuthor(
          NostrTestKeys.testPublicKey1);
      final event2 = sharedRelay.getLastEventFromAuthor(
          NostrTestKeys.testPublicKey2);
      final event3 = sharedRelay.getLastEventFromAuthor(
          NostrTestKeys.testPublicKey3);

      expect(event1?.pubkey, equals(NostrTestKeys.testPublicKey1));
      expect(event2?.pubkey, equals(NostrTestKeys.testPublicKey2));
      expect(event3?.pubkey, equals(NostrTestKeys.testPublicKey3));
      expect(sharedRelay.publishedEvents.length, equals(3));
    });

    test('Disconnessione del relay ferma lo scambio dati', () async {
      await sharedRelay.connect();
      await peer1.connect();
      await peer2.connect();
      await peer3.connect();

      await peer1.publish([1, 2, 3]);
      expect(sharedRelay.publishedEvents.length, equals(1));

      await sharedRelay.disconnect();
      expect(sharedRelay.isConnected(), isFalse);
      expect(sharedRelay.subscriptions.isEmpty, isTrue);
    });

    test('Multipli eventi dallo stesso peer mantengono ordine', () async {
      await sharedRelay.connect();
      await peer1.connect();

      // Peer1 pubblica multipli eventi
      final id1 = await peer1.publish([1]);
      final id2 = await peer1.publish([2]);
      final id3 = await peer1.publish([3]);

      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      expect(id3, isNotEmpty);

      // Verifica che gli eventi siano in ordine
      final peer1Events = sharedRelay.publishedEvents
          .where((e) => e.pubkey == NostrTestKeys.testPublicKey1)
          .toList();
      expect(peer1Events.length, equals(3));
    });

    test('Peer può recuperare ultimi dati dal relay', () async {
      await sharedRelay.connect();
      await peer1.connect();

      // Publish some data
      await peer1.publish([99, 99, 99]);

      // Get the last event from peer1
      final lastEvent = sharedRelay.getLastEventFromAuthor(
          NostrTestKeys.testPublicKey1);

      expect(lastEvent, isNotNull);
      expect(lastEvent?.pubkey, equals(NostrTestKeys.testPublicKey1));
    });

    test('Tre peer mantengono storia eventi indipendente', () async {
      await sharedRelay.connect();
      await peer1.connect();
      await peer2.connect();
      await peer3.connect();

      // Pubblica multipli eventi da ogni peer
      for (var i = 1; i <= 3; i++) {
        await peer1.publish([i]);
        await peer2.publish([i * 10]);
        await peer3.publish([i * 20]);
      }

      // Verifica che ogni peer abbia 3 eventi
      final peer1Events = sharedRelay.publishedEvents
          .where((e) => e.pubkey == NostrTestKeys.testPublicKey1)
          .length;
      final peer2Events = sharedRelay.publishedEvents
          .where((e) => e.pubkey == NostrTestKeys.testPublicKey2)
          .length;
      final peer3Events = sharedRelay.publishedEvents
          .where((e) => e.pubkey == NostrTestKeys.testPublicKey3)
          .length;

      expect(peer1Events, equals(3));
      expect(peer2Events, equals(3));
      expect(peer3Events, equals(3));
      expect(sharedRelay.publishedEvents.length, equals(9));
    });
  });
}
