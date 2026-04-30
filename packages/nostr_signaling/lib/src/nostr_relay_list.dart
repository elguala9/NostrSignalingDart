import 'interfaces/i_relay.dart';

class NostrRelayList extends Iterable<INostrRelay> {
  final List<INostrRelay> _relays;

  NostrRelayList._(this._relays);

  factory NostrRelayList(List<INostrRelay> relays) {
    if (relays.isEmpty) {
      throw ArgumentError('At least one relay is required');
    }
    return NostrRelayList._(List.unmodifiable(relays));
  }

  factory NostrRelayList.single(INostrRelay relay) {
    return NostrRelayList._([relay]);
  }

  @override
  Iterator<INostrRelay> get iterator => _relays.iterator;

  @override
  int get length => _relays.length;

  INostrRelay operator [](int index) => _relays[index];

  Future<void> connectAll() => Future.wait(_relays.map((r) => r.connect()));

  Future<void> disconnectAll() => Future.wait(_relays.map((r) => r.disconnect()));

  bool isAnyConnected() => _relays.any((r) => r.isConnected());
}
