import 'dart:async';
import 'dart:convert';
import 'package:nostr/nostr.dart';

import '../interfaces/i_compression.dart';
import '../interfaces/i_nostr_signaling.dart';
import '../interfaces/i_relay.dart';
import '../types.dart';

class NostrSignalingImpl implements INostrSignaling {
  final String pubkey;
  final String privkey;
  final List<INostrRelay> relays;
  final bool useCompression;
  final ICompressionEngine? compressionEngine;

  final Map<NostrId, EventCallback> _subscriptions = {};
  final Map<NostrId, Map<INostrRelay, String>> _relaySubscriptionIds = {};

  NostrSignalingImpl({
    required this.pubkey,
    required this.privkey,
    required List<INostrRelay> relays,
    this.useCompression = false,
    this.compressionEngine,
  }) : relays = relays.isNotEmpty ? relays : throw ArgumentError('At least one relay is required');

  /// Convenience constructor for a single relay
  NostrSignalingImpl.single({
    required this.pubkey,
    required this.privkey,
    required INostrRelay relay,
    this.useCompression = false,
    this.compressionEngine,
  }) : relays = [relay] {
    if (relays.isEmpty) throw ArgumentError('At least one relay is required');
  }

  @override
  Future<void> connect() async {
    await Future.wait(relays.map((relay) => relay.connect()));
  }

  @override
  Future<void> disconnect() async {
    for (final id in _subscriptions.keys) {
      await unsubscribe(id);
    }
    await Future.wait(relays.map((relay) => relay.disconnect()));
  }

  @override
  bool isConnected() {
    return relays.any((relay) => relay.isConnected());
  }

  @override
  Future<String> publish(List<int> data) async {
    final contentToPublish = useCompression && compressionEngine != null
        ? await compressionEngine!.compress(data)
        : data;

    final content = contentToPublish is CompressedData
        ? _encodeContent(contentToPublish.data)
        : _encodeContent(contentToPublish as List<int>);

    final event = _createEvent(
      content: content,
      kind: useCompression ? 1000 : 1001,
    );

    // Publish to all relays and return the event ID
    // All relays get the same event with the same ID
    final publishFutures = relays.map((relay) => relay.publishEvent(event));
    final results = await Future.wait(publishFutures, eagerError: false);

    // Return the first successful result or the first result
    return results.whereType<String>().firstOrNull ?? results.first;
  }

  @override
  Future<String> subscribe(NostrId id, EventCallback onEvent, {int? since}) async {
    // Unsubscribe from previous subscription to this ID if it exists
    if (_relaySubscriptionIds.containsKey(id)) {
      await unsubscribe(id);
    }

    _subscriptions[id] = onEvent;
    _relaySubscriptionIds[id] = {};

    // Subscribe to all events from the specified author with our custom kinds
    final filter = <String, dynamic>{
      'authors': [id],
      'kinds': [1000, 1001],
      if (since != null) 'since': since,
    };

    // Subscribe on all relays
    final subscriptionFutures = relays.map((relay) async {
      final subId = await relay.subscribe(filter, (event) {
        final data = _decodeContent(event.content);
        onEvent(id, data);
      });
      _relaySubscriptionIds[id]![relay] = subId;
      return subId;
    });

    final subIds = await Future.wait(subscriptionFutures);
    return subIds.first;
  }

  @override
  Future<List<int>> retriveLast(NostrId id) async {
    final filter = <String, dynamic>{
      'authors': [id],
      'kinds': [1000, 1001],
      'limit': 1,
    };

    // Try to retrieve from all relays concurrently and return the first successful result
    final retrieveFutures = relays.map((relay) async {
      List<int> lastData = [];
      final completer = Completer<void>();

      try {
        final subId = await relay.subscribe(filter, (event) {
          lastData = _decodeContent(event.content);
          if (!completer.isCompleted) {
            completer.complete();
          }
        });

        try {
          await completer.future.timeout(const Duration(seconds: 5));
        } finally {
          await relay.unsubscribe(subId);
        }
      } catch (e) {
        // Relay failed, will try next one
      }

      return lastData;
    });

    final results = await Future.wait(retrieveFutures);

    // Return the first non-empty result, or empty list if all failed
    return results.firstWhere(
      (data) => data.isNotEmpty,
      orElse: () => [],
    );
  }

  @override
  Future<void> unsubscribe(NostrId id) async {
    if (_subscriptions.containsKey(id)) {
      _subscriptions.remove(id);
      final relaySubIds = _relaySubscriptionIds.remove(id) ?? {};

      // Unsubscribe from all relays
      await Future.wait(
        relaySubIds.entries.map((entry) async {
          final relay = entry.key;
          final subId = entry.value;
          await relay.unsubscribe(subId);
        }),
        eagerError: false,
      );
    }
  }

  NostrEvent _createEvent({
    required String content,
    required int kind,
  }) {
    // Use nostr library Event.from() which automatically:
    // 1. Generates event ID from canonical JSON
    // 2. Signs with BIP340 Schnorr signature
    final event = Event.from(
      kind: kind,
      tags: [],
      content: content,
      privkey: privkey,
    );

    return NostrEvent(
      id: event.id,
      pubkey: event.pubkey,
      createdAt: event.createdAt,
      kind: event.kind,
      tags: event.tags,
      content: event.content,
      sig: event.sig,
    );
  }

  String _encodeContent(List<int> data) {
    // Codifica i dati come base64 per trasporto sicuro
    return base64Encode(data);
  }

  List<int> _decodeContent(String content) {
    // Decodifica il contenuto da base64
    try {
      return base64Decode(content);
    } catch (e) {
      return utf8.encode(content);
    }
  }
}
