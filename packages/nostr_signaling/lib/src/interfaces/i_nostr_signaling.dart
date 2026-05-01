import 'package:singleton_manager/singleton_manager.dart';
import 'package:work_db/work_db.dart';

import '../types.dart';

/// Callback invoked when an event is received from a peer.
///
/// [id] is the sender's Nostr public key, [data] is the decoded payload.
/// Tracks seen event hashes using [work_db] to avoid invoking the callback
/// more than once for the same hash. By default uses an in-memory database
/// with [maxRecords] limit; pass a persistent [database] for durable dedup.
class EventCallback {
  final void Function(NostrUserId id, List<int> data) _callback;
  final IWorkDbSync _db;
  final String _collection;

  EventCallback(
    this._callback, {
    IWorkDbSync? database,
    String collection = 'nostr_signaling_seen_hashes',
    int maxRecords = 1000,
  })  : _db = database ?? WorkDb.memory(maxRecordsPerCollection: maxRecords),
        _collection = collection;

  void call(NostrUserId id, List<int> data, {String? hash}) {
    if (hash != null) {
      final existing = _db.retrieveSync(
        ItemId(id: hash, collection: _collection),
      );
      if (existing != null) return;
      _db.createSync(
        ItemWithId(
          id: hash,
          collection: _collection,
          item: {
            'hash': hash,
            'received_at': DateTime.now().toUtc().toIso8601String(),
          },
        ),
      );
    }
    _callback(id, data);
  }
}

/// Abstract Nostr signaling interface.
///
/// Provides publish/subscribe semantics for exchanging binary data
/// between Nostr peers. Supports optional compression and multi-relay
/// redundancy.
abstract class INostrSignaling implements IValueForRegistry {
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
