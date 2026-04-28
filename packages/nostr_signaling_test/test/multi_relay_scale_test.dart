import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';

/// Mock relay for testing without actual network connections
class MockRelay implements INostrRelay {
  final String id;
  bool _connected = false;
  final Map<String, RelayEventCallback> _subscriptions = {};
  final List<NostrEvent> _publishedEvents = [];

  MockRelay({required this.id});

  @override
  Future<void> connect() async {
    _connected = true;
    await Future.delayed(Duration(milliseconds: 100));
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    _subscriptions.clear();
  }

  @override
  bool isConnected() => _connected;

  @override
  Future<String> publishEvent(NostrEvent event) async {
    if (!_connected) throw Exception('Relay $id not connected');
    _publishedEvents.add(event);
    await Future.delayed(Duration(milliseconds: 50));
    return event.id;
  }

  @override
  Future<String> subscribe(
    Map<String, dynamic> filter,
    RelayEventCallback onEvent,
  ) async {
    if (!_connected) throw Exception('Relay $id not connected');
    final subId = 'sub_$id';
    _subscriptions[subId] = onEvent;
    await Future.delayed(Duration(milliseconds: 50));
    return subId;
  }

  @override
  Future<void> unsubscribe(String subscriptionId) async {
    _subscriptions.remove(subscriptionId);
    await Future.delayed(Duration(milliseconds: 50));
  }

  // Test helpers
  int get publishedEventsCount => _publishedEvents.length;
  int get activeSubscriptionsCount => _subscriptions.length;
}

void main() {
  group('NostrSignalingImpl with 10 relays', () {
    late List<MockRelay> mockRelays;
    late NostrSignalingImpl signaling;

    setUp(() {
      // Create 10 mock relays
      mockRelays = List.generate(
        10,
        (index) => MockRelay(id: 'relay_$index'),
      );

      signaling = NostrSignalingImpl(
        pubkey: NostrTestKeys.testPublicKey1,
        privkey: NostrTestKeys.testPrivateKey1,
        relays: mockRelays,
        useCompression: false,
      );
    });

    test('connect connette a tutti i 10 relay', () async {
      // Verify all relays are initially disconnected
      expect(mockRelays.every((r) => !r.isConnected()), true);

      // Connect
      await signaling.connect();

      // Verify all relays are connected
      expect(mockRelays.every((r) => r.isConnected()), true);
      expect(signaling.isConnected(), true);
    });

    test('disconnect disconnette da tutti i 10 relay', () async {
      // Connect first
      await signaling.connect();
      expect(mockRelays.every((r) => r.isConnected()), true);

      // Disconnect
      await signaling.disconnect();

      // Verify all relays are disconnected
      expect(mockRelays.every((r) => !r.isConnected()), true);
      expect(signaling.isConnected(), false);
    });

    test('publish invia l\'evento a tutti i 10 relay', () async {
      await signaling.connect();
      const testData = [1, 2, 3, 4, 5];

      final eventId = await signaling.publish(testData);

      expect(eventId, isNotEmpty);

      // Verify all relays received the same event
      for (final relay in mockRelays) {
        expect(relay.publishedEventsCount, equals(1));
        // All events should have the same ID
        expect(relay._publishedEvents[0].id, equals(eventId));
      }
    });

    test('subscribe crea sottoscrizioni su tutti i 10 relay', () async {
      await signaling.connect();
      const targetId = 'user_123';

      final subId = await signaling.subscribe(targetId, (id, data) {});

      expect(subId, isNotEmpty);

      // Verify all relays have an active subscription
      for (final relay in mockRelays) {
        expect(relay.activeSubscriptionsCount, equals(1));
      }
    });

    test('unsubscribe rimuove sottoscrizioni da tutti i 10 relay', () async {
      await signaling.connect();
      const targetId = 'user_123';

      await signaling.subscribe(targetId, (id, data) {});

      // Verify subscriptions are active
      expect(mockRelays.every((r) => r.activeSubscriptionsCount == 1), true);

      // Unsubscribe
      await signaling.unsubscribe(targetId);

      // Verify subscriptions are removed from all relays
      expect(mockRelays.every((r) => r.activeSubscriptionsCount == 0), true);
    });

    test('isConnected ritorna true se almeno 1 relay è connesso', () async {
      // Connect only 3 relays manually
      await mockRelays[0].connect();
      await mockRelays[1].connect();
      await mockRelays[2].connect();

      expect(signaling.isConnected(), true);
    });

    test('isConnected ritorna false se nessun relay è connesso', () async {
      // All start disconnected
      expect(signaling.isConnected(), false);
    });

    test('multiple publish invia diversi eventi a tutti i relay', () async {
      await signaling.connect();

      const testData1 = [1, 2, 3];
      const testData2 = [4, 5, 6];
      const testData3 = [7, 8, 9];

      await signaling.publish(testData1);
      await signaling.publish(testData2);
      await signaling.publish(testData3);

      // Each relay should have received 3 events
      for (final relay in mockRelays) {
        expect(relay.publishedEventsCount, equals(3));
      }
    });

    test('publish scala bene con 10 relay', () async {
      await signaling.connect();
      final testData = List.generate(100, (i) => i);

      final stopwatch = Stopwatch()..start();
      await signaling.publish(testData);
      stopwatch.stop();

      // Verify all relays got the event
      expect(mockRelays.every((r) => r.publishedEventsCount == 1), true);

      // Performance check: should complete reasonably fast
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      print('Published to 10 relays in ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}
