import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';

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
  Future<String> subscribe(NostrId id, EventCallback onEvent) async {
    _subscriptions[id] = onEvent;

    final filter = {
      'authors': [pubkey],
      'kinds': [1000, 1001],
      '#p': [id],
    };

    _currentSubscriptionId = await relay.subscribe(filter, (event) {
      final data = _decodeContent(event.content);
      onEvent(id, data);
    });

    return _currentSubscriptionId;
  }

  @override
  Future<List<int>> retriveLast(NostrId id) async {
    final filter = {
      'authors': [pubkey],
      'kinds': [1000, 1001],
      '#p': [id],
      'limit': 1,
    };

    late List<int> lastData;
    late Completer<void> completer = Completer();

    final subId = await relay.subscribe(filter, (event) {
      lastData = _decodeContent(event.content);
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    await completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        relay.unsubscribe(subId);
      },
    );

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
    final eventId = _generateEventId(content, kind, now);
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
    // Nostr event ID: SHA256([0, pubkey, created_at, kind, tags, content])
    final eventData = [
      0,
      pubkey,
      createdAt,
      kind,
      [],
      content,
    ];

    final jsonString = jsonEncode(eventData);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  String _signEvent(String eventId) {
    // TODO: Implementare Schnorr signature con private key
    // Per ora usa una versione "firmata" con formato corretto
    // Formato Nostr signature: hex string di 128 caratteri (64 bytes)
    
    // Questa è una implementazione di placeholder che genera
    // una "firma" valida nel formato ma non cryptograficamente corretta
    final hash = sha256.convert(utf8.encode('$privkey$eventId'));
    return hash.toString();
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
