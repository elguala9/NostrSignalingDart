import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:bip340/bip340.dart' as bip340;
import 'package:crypto/crypto.dart';
import 'package:hex/hex.dart';

import '../interfaces/compression.dart';
import '../interfaces/nostr_signaling.dart';
import '../interfaces/relay.dart';
import '../types.dart';

class NostrSignalingImpl implements INostrSignaling {
  final String pubkey;
  final String privkey;
  final INostrRelay relay;
  final bool useCompression;
  final ICompressionEngine? compressionEngine;

  late String _currentSubscriptionId;
  final Map<NostrId, EventCallback> _subscriptions = {};

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
  @override
  Future<String> subscribe(NostrId id, EventCallback onEvent) async {
    _subscriptions[id] = onEvent;

    // Subscribe to all events from the specified author with our custom kinds
    final filter = <String, dynamic>{
      'authors': [id],
      'kinds': [1000, 1001],
    };

    _currentSubscriptionId = await relay.subscribe(filter, (event) {
      final data = _decodeContent(event.content);
      onEvent(id, data);
    });

    return _currentSubscriptionId;
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
      if (_currentSubscriptionId.isNotEmpty) {
        await relay.unsubscribe(_currentSubscriptionId);
      }
    }
  }

  NostrEvent _createEvent({
    required String content,
    required int kind,
  }) {
    final now = (DateTime.now().millisecondsSinceEpoch / 1000).floor();

    // Calculate event ID from canonical Nostr representation
    final eventId = _generateEventId(content, kind, now);

    // Sign the event ID using BIP340 Schnorr signature
    final signature = _signEvent(eventId);

    return NostrEvent(
      id: eventId,
      pubkey: pubkey,
      createdAt: now,
      kind: kind,
      tags: [],
      content: content,
      sig: signature,
    );
  }

  String _generateEventId(String content, int kind, int createdAt) {
    // Nostr NIP-01: Event ID is SHA256 of [0, pubkey, created_at, kind, tags, content]
    final eventData = [0, pubkey, createdAt, kind, [], content];
    final jsonString = jsonEncode(eventData);
    print('[DEBUG] Computing event ID from: $jsonString');
    
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    final eventId = digest.toString();
    print('[DEBUG] Event ID: $eventId');
    
    return eventId;
  }

  String _signEvent(String eventIdHex) {
    // Sign the event ID (which is a 32-byte SHA256 hash) using BIP340 Schnorr
    // bip340.sign expects: privateKey (hex string), message (hex string), auxData (hex string)
    final signature = bip340.sign(privkey, eventIdHex, '');
    return signature;
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
