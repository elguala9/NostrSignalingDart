import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../interfaces/relay.dart';
import '../types.dart';

class NostrRelayImpl implements INostrRelay {
  final String relayUrl;
  late WebSocketChannel _channel;
  bool _isConnected = false;
  final Map<String, RelayEventCallback> _subscriptions = {};
  final Map<String, StreamSubscription> _streamSubscriptions = {};

  NostrRelayImpl({required this.relayUrl});

  @override
  Future<void> connect() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(relayUrl));
      _isConnected = true;

      // Ascolta i messaggi dal relay
      _channel.stream.listen(
        (message) => _handleRelayMessage(message),
        onError: (error) {
          _isConnected = false;
        },
        onDone: () {
          _isConnected = false;
        },
      );
    } catch (e) {
      _isConnected = false;
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    for (final sub in _streamSubscriptions.values) {
      await sub.cancel();
    }
    _streamSubscriptions.clear();
    _subscriptions.clear();

    await _channel.sink.close();
    _isConnected = false;
  }

  @override
  bool isConnected() {
    return _isConnected;
  }

  @override
  Future<String> publishEvent(NostrEvent event) async {
    final eventMessage = [
      'EVENT',
      _eventToJson(event),
    ];

    _channel.sink.add(jsonEncode(eventMessage));
    return event.id;
  }

  @override
  Future<String> subscribe(
    Map<String, dynamic> filter,
    RelayEventCallback onEvent,
  ) async {
    final subscriptionId = _generateSubscriptionId();
    _subscriptions[subscriptionId] = onEvent;

    final subscribeMessage = [
      'REQ',
      subscriptionId,
      filter,
    ];

    _channel.sink.add(jsonEncode(subscribeMessage));
    return subscriptionId;
  }

  @override
  Future<void> unsubscribe(String subscriptionId) async {
    if (_subscriptions.containsKey(subscriptionId)) {
      _subscriptions.remove(subscriptionId);

      final closeMessage = [
        'CLOSE',
        subscriptionId,
      ];

      _channel.sink.add(jsonEncode(closeMessage));

      await _streamSubscriptions[subscriptionId]?.cancel();
      _streamSubscriptions.remove(subscriptionId);
    }
  }

  void _handleRelayMessage(dynamic message) {
    try {
      final decoded = jsonDecode(message as String) as List<dynamic>;

      if (decoded.isEmpty) return;

      final messageType = decoded[0] as String;

      switch (messageType) {
        case 'EVENT':
          if (decoded.length >= 3) {
            final subscriptionId = decoded[1] as String;
            final eventData = decoded[2] as Map<String, dynamic>;
            final event = _jsonToEvent(eventData);

            _subscriptions[subscriptionId]?.call(event);
          }
          break;

        case 'EOSE':
          // End of stored events
          break;

        case 'NOTICE':
          // Relay notice message
          break;

        case 'OK':
          // Event accepted/rejected
          break;

        default:
          break;
      }
    } catch (e) {
      // Errore nel parsing del messaggio
    }
  }

  Map<String, dynamic> _eventToJson(NostrEvent event) {
    return {
      'id': event.id,
      'pubkey': event.pubkey,
      'created_at': event.createdAt,
      'kind': event.kind,
      'tags': event.tags,
      'content': event.content,
      'sig': event.sig,
    };
  }

  NostrEvent _jsonToEvent(Map<String, dynamic> json) {
    return NostrEvent(
      id: json['id'] as String,
      pubkey: json['pubkey'] as String,
      createdAt: json['created_at'] as int,
      kind: json['kind'] as int,
      tags: List<List<String>>.from(
        (json['tags'] as List).map((tag) => List<String>.from(tag as List)),
      ),
      content: json['content'] as String,
      sig: json['sig'] as String,
    );
  }

  String _generateSubscriptionId() {
    return 'sub_${DateTime.now().millisecondsSinceEpoch}';
  }
}
