import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:work_db/work_db.dart';

/// Callback invoked when an event is received from a peer.
///
/// [id] is the sender's Nostr public key, [data] is the decoded payload.
/// Tracks seen event hashes using [work_db] to avoid invoking the callback
/// more than once for the same hash. By default uses an in-memory database
/// with [maxRecords] limit; pass a persistent [database] for durable dedup.
class EventCallback implements IEventCallback{
  final void Function(NostrUserId id, List<int> data) _callback;
  final IWorkDbSync _db;
  final String _collection;

  EventCallback(
    this._callback, {
    IWorkDbSync? database,
    String collection = defaultEventCallbackCollection,
    int maxRecords = 1000,
  })  : _db = database ?? WorkDb.memory(maxRecordsPerCollection: maxRecords),
        _collection = collection;

  @override
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