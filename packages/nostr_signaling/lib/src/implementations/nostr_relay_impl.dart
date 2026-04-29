import 'dart:async';

import 'package:dart_nostr/dart_nostr.dart';

import '../interfaces/i_relay.dart';

class NostrRelayImpl implements INostrRelay {
  final String relayUrl;
  final Nostr _nostr = Nostr();
  bool _isConnected = false;
  final Map<String, NostrEventsStream> _subscriptions = {};

  NostrRelayImpl({required this.relayUrl});

  @override
  Future<void> connect() async {
    if (_isConnected) return;
    final result = await _nostr.connect([relayUrl]);
    if (result.isFailure) {
      throw Exception(result.failureOrNull?.message ?? 'Failed to connect');
    }
    _isConnected = true;
  }

  @override
  Future<void> disconnect() async {
    _subscriptions.clear();
    final result = await _nostr.disconnect();
    if (result.isFailure) {
      // Already disconnected, ignore
    }
    _isConnected = false;
  }

  @override
  bool isConnected() {
    return _isConnected && _nostr.isConnected;
  }

  @override
  Future<String> publishEvent(NostrEvent event) async {
    final result = await _nostr
        .publish(event)
        .timeout(const Duration(seconds: 10));
    if (result.isFailure) {
      throw Exception(result.failureOrNull?.message ?? 'Failed to publish');
    }
    return event.id ?? '';
  }

  @override
  Future<String> subscribe(
    NostrFilter filter,
    RelayEventCallback onEvent,
  ) async {
    final result = _nostr.subscribe(filter);
    if (result.isFailure) {
      throw Exception(result.failureOrNull?.message ?? 'Failed to subscribe');
    }

    final eventsStream = result.valueOrNull!;
    final subId = eventsStream.subscriptionId;

    eventsStream.stream.listen(
      (event) => onEvent(event),
      onError: (_) {},
      onDone: () {
        _subscriptions.remove(subId);
      },
    );

    _subscriptions[subId] = eventsStream;
    return subId;
  }

  @override
  Future<void> unsubscribe(String subscriptionId) async {
    final eventsStream = _subscriptions.remove(subscriptionId);
    if (eventsStream != null) {
      eventsStream.close();
    }
  }
}
