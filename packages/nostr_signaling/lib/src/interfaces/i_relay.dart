import '../types.dart';

typedef RelayEventCallback = void Function(NostrEvent event);

abstract class INostrRelay {
  Future<void> connect();

  Future<void> disconnect();

  bool isConnected();

  /// Pubblica un evento sul relay
  Future<String> publishEvent(NostrEvent event);

  /// Si sottoscrive a eventi che matchano il filtro
  /// Restituisce il subscription ID
  Future<String> subscribe(
    Map<String, dynamic> filter,
    RelayEventCallback onEvent,
  );

  /// Annulla una sottoscrizione
  Future<void> unsubscribe(String subscriptionId);
}
