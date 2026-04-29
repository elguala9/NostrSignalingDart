import 'package:dart_nostr/dart_nostr.dart';

typedef RelayEventCallback = void Function(NostrEvent event);

abstract class INostrRelay {
  Future<void> connect();

  Future<void> disconnect();

  bool isConnected();

  Future<String> publishEvent(NostrEvent event);

  Future<String> subscribe(
    NostrFilter filter,
    RelayEventCallback onEvent,
  );

  Future<void> unsubscribe(String subscriptionId);
}
