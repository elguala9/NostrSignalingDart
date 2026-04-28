import '../types.dart';

typedef EventCallback = void Function(NostrId id, List<int> data);


abstract class INostrSignaling {
  Future<void> connect();

  Future<void> disconnect();

  bool isConnected();

  Future<String> publish(List<int> data);

  Future<String> subscribe(NostrId id, EventCallback onEvent);

  Future<List<int>> retriveLast(NostrId id); // retrive the data of the last event

  Future<void> unsubscribe(NostrId id);
}
