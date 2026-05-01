import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  group('MockEventCallback', () {
    test('totalCalls incremented on each call', () {
      final mock = MockEventCallback((id, data) {});

      mock.call('alice', [1, 2, 3], hash: 'a');
      mock.call('alice', [4, 5, 6], hash: 'b');
      mock.call('alice', [7, 8, 9], hash: 'c');

      expect(mock.totalCalls, equals(3));
    });

    test('tracks duplicate hashes from multiple relays', () {
      final mock = MockEventCallback((id, data) {});

      // Same event hash arriving from 3 different relays
      mock.call('alice', [1, 2, 3], hash: 'same-event');
      mock.call('alice', [1, 2, 3], hash: 'same-event');
      mock.call('alice', [1, 2, 3], hash: 'same-event');

      // totalCalls counts all 3 (before dedup)
      expect(mock.totalCalls, equals(3));
      // relayCount confirms all 3 relays delivered it
      expect(mock.relayCount('same-event'), equals(3));
    });

    test('tracks different hashes independently', () {
      final mock = MockEventCallback((id, data) {});

      mock.call('alice', [1, 2, 3], hash: 'hash-a');
      mock.call('alice', [4, 5, 6], hash: 'hash-a');
      mock.call('alice', [7, 8, 9], hash: 'hash-b');

      expect(mock.relayCount('hash-a'), equals(2));
      expect(mock.relayCount('hash-b'), equals(1));
      expect(mock.totalCalls, equals(3));
    });

    test('inner callback called only once per unique hash (dedup preserved)', () {
      int innerCount = 0;
      final mock = MockEventCallback((id, data) { innerCount++; });

      // 3 relays, same event
      mock.call('alice', [1, 2, 3], hash: 'same-event');
      mock.call('alice', [1, 2, 3], hash: 'same-event');
      mock.call('alice', [1, 2, 3], hash: 'same-event');

      // Mock counts 3, but inner callback only 1 (dedup by EventCallback)
      expect(mock.totalCalls, equals(3));
      expect(innerCount, equals(1));
    });

    test('inner callback called per unique hash', () {
      int innerCount = 0;
      final mock = MockEventCallback((id, data) { innerCount++; });

      // 3 relays, 2 unique hashes
      mock.call('alice', [1, 2, 3], hash: 'hash-x');
      mock.call('alice', [1, 2, 3], hash: 'hash-x');
      mock.call('alice', [4, 5, 6], hash: 'hash-y');

      expect(mock.totalCalls, equals(3));
      expect(innerCount, equals(2));
    });

    test('expectRelayCount assertion', () {
      final mock = MockEventCallback((id, data) {});

      mock.call('alice', [1, 2, 3], hash: 'event-1');
      mock.call('alice', [1, 2, 3], hash: 'event-1');
      mock.call('alice', [1, 2, 3], hash: 'event-1');

      mock.expectRelayCount('event-1', 3);
      mock.expectTotalCalls(3);
    });

    test('works without hash (calls always counted)', () {
      final mock = MockEventCallback((id, data) {});

      mock.call('alice', [1, 2, 3]);
      mock.call('alice', [4, 5, 6]);
      mock.call('alice', [7, 8, 9]);

      expect(mock.totalCalls, equals(3));
    });

    test('completes callback data correctly', () {
      final received = <List<int>>[];
      final mock = MockEventCallback((id, data) { received.add(data); });

      mock.call('alice', [1, 2, 3], hash: 'a');
      mock.call('alice', [99, 100], hash: 'b');

      expect(received, hasLength(2));
      expect(received[0], equals([1, 2, 3]));
      expect(received[1], equals([99, 100]));
    });
  });
}
