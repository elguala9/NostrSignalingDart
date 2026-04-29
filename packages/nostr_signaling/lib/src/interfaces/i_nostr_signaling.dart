import '../types.dart';

/// Callback invoked when an event is received from a peer.
///
/// [id] is the sender's Nostr public key, [data] is the decoded payload.
typedef EventCallback = void Function(NostrUserId id, List<int> data);

/// Abstract Nostr signaling interface.
///
/// Provides publish/subscribe semantics for exchanging binary data
/// between Nostr peers. Supports optional compression and multi-relay
/// redundancy.
abstract class INostrSignaling {
  /// Connects to the configured Nostr relay(s).
  Future<void> connect();

  /// Disconnects from all relays and cleans up active subscriptions.
  Future<void> disconnect();

  /// Returns `true` if at least one relay is connected.
  bool isConnected();

  /// Publishes [data] to the Nostr network.
  ///
  /// Returns the event ID of the published event. If compression is
  /// enabled, [data] is compressed before publishing.
  Future<String> publish(List<int> data);

  /// Subscribes to events from [id] (a Nostr public key).
  ///
  /// [onEvent] is called for each received event. Optionally filters
  /// events after the given Unix timestamp [since].
  /// Returns the subscription ID.
  Future<String> subscribe(NostrUserId id, EventCallback onEvent, {int? since});

  /// Retrieves the last published event from [id].
  ///
  /// Returns the decoded byte payload, or an empty list if no events found.
  Future<List<int>> retrieveLast(NostrUserId id);

  /// Unsubscribes from all events from [id].
  Future<void> unsubscribe(NostrUserId id);
}
