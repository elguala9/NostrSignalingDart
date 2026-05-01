import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';

/// Mock EventCallback that counts every `call()` invocation,
/// including duplicates from multiple relays with the same hash.
///
/// Unlike [EventCallback], this does NOT suppress duplicates — it tracks
/// them so tests can verify that all relays delivered the same event.
///
/// Example:
/// ```dart
/// final mock = MockEventCallback((id, data) {
///   print('Received: $data');
/// });
///
/// await signaling.subscribe(targetId, mock);
///
/// // After event propagates through 3 relays:
/// expect(mock.totalCalls, equals(3));
/// mock.expectRelayCount(sameHash, 3);
/// ```
class MockEventCallback extends EventCallback {
  int totalCalls = 0;
  final Map<String, int> callsPerHash = {};

  MockEventCallback(void Function(NostrUserId id, List<int> data) onEvent)
      : super(onEvent);

  @override
  void call(NostrUserId id, List<int> data, {String? hash}) {
    totalCalls++;
    if (hash != null) {
      callsPerHash[hash] = (callsPerHash[hash] ?? 0) + 1;
    }
    super.call(id, data, hash: hash);
  }

  /// Returns how many relays delivered the event with [hash].
  int relayCount(String hash) => callsPerHash[hash] ?? 0;

  /// Asserts the event with [hash] arrived from exactly [expected] relays.
  void expectRelayCount(String hash, int expected) {
    expect(relayCount(hash), equals(expected));
  }

  /// Asserts that [call] was invoked exactly [expected] times total.
  void expectTotalCalls(int expected) {
    expect(totalCalls, equals(expected));
  }

  /// Asserts that [call] was invoked at least [expected] times total.
  void expectAtLeastCalls(int expected) {
    expect(totalCalls, greaterThanOrEqualTo(expected));
  }
}
