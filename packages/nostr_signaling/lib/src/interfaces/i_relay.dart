import 'package:dart_nostr/dart_nostr.dart';
import 'package:singleton_manager/singleton_manager.dart';

/// Callback for raw Nostr events received from a relay.
typedef RelayEventCallback = void Function(NostrEvent event);

/// Abstract Nostr relay interface.
///
/// Encapsulates a WebSocket connection to a single Nostr relay with
/// connect, disconnect, publish, and subscribe capabilities.
abstract class INostrRelay implements IValueForRegistry{
  /// Opens a WebSocket connection to the relay.
  Future<void> connect();

  /// Closes the WebSocket connection and cleans up subscriptions.
  Future<void> disconnect();

  /// Returns `true` if the relay is currently connected.
  bool isConnected();

  /// Publishes a signed [event] to the relay.
  ///
  /// Returns the event ID on success.
  Future<String> publishEvent(NostrEvent event);

  /// Subscribes to events matching [filter].
  ///
  /// [onEvent] is called for each matching event received.
  /// Returns the subscription ID.
  Future<String> subscribe(
    NostrFilter filter,
    RelayEventCallback onEvent,
  );

  /// Unsubscribes from a previously created subscription.
  Future<void> unsubscribe(String subscriptionId);
}
