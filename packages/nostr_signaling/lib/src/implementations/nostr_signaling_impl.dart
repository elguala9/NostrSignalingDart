import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:hex/hex.dart';
import 'package:nostr/nostr.dart';

import '../interfaces/i_compression.dart';
import '../interfaces/i_nostr_signaling.dart';
import '../interfaces/i_relay.dart';
import '../types.dart';

class NostrSignalingImpl implements INostrSignaling {
  final String pubkey;
  final String privkey;
  final INostrRelay relay;
  final bool useCompression;
  final ICompressionEngine? compressionEngine;

  late String _currentSubscriptionId;
  final Map<NostrId, EventCallback> _subscriptions = {};
  final Map<NostrId, String> _subscriptionIds = {};

  NostrSignalingImpl({
    required this.pubkey,
    required this.privkey,
    required this.relay,
    this.useCompression = false,
    this.compressionEngine,
  });

  @override
  Future<void> connect() async {
    await relay.connect();
  }

  @override
  Future<void> disconnect() async {
    for (final id in _subscriptions.keys) {
      await unsubscribe(id);
    }
    await relay.disconnect();
  }

  @override
  bool isConnected() {
    return relay.isConnected();
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

    final eventId = await relay.publishEvent(event);
    return eventId;
  }

  @override
  Future<String> subscribe(NostrId id, EventCallback onEvent, {int? since}) async {
    // Unsubscribe from previous subscription to this ID if it exists
    if (_subscriptionIds.containsKey(id)) {
      await relay.unsubscribe(_subscriptionIds[id]!);
    }

    _subscriptions[id] = onEvent;

    // Subscribe to all events from the specified author with our custom kinds
    final filter = <String, dynamic>{
      'authors': [id],
      'kinds': [1000, 1001],
      if (since != null) 'since': since,
    };

    final subId = await relay.subscribe(filter, (event) {
      final data = _decodeContent(event.content);
      onEvent(id, data);
    });

    _subscriptionIds[id] = subId;
    _currentSubscriptionId = subId;

    return subId;
  }

  @override
  Future<List<int>> retriveLast(NostrId id) async {
    final filter = <String, dynamic>{
      'authors': [id],
      'kinds': [1000, 1001],
      'limit': 1,
    };

    List<int> lastData = [];
    final completer = Completer<void>();

    final subId = await relay.subscribe(filter, (event) {
      lastData = _decodeContent(event.content);
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    try {
      await completer.future.timeout(const Duration(seconds: 5));
    } catch (e) {
      // Timeout o errore
    } finally {
      await relay.unsubscribe(subId);
    }

    return lastData;
  }

  @override
  Future<void> unsubscribe(NostrId id) async {
    if (_subscriptions.containsKey(id)) {
      _subscriptions.remove(id);
      final subId = _subscriptionIds.remove(id);
      if (subId != null) await relay.unsubscribe(subId);
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
