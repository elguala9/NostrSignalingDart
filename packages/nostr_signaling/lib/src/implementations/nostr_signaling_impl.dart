import 'dart:async';
import 'dart:convert';

import 'package:dart_nostr/dart_nostr.dart';

import '../interfaces/i_compression.dart';
import '../interfaces/i_nostr_signaling.dart';
import '../interfaces/i_relay.dart';
import '../types.dart';

/// Concrete implementation of [INostrSignaling].
///
/// Supports single and multi-relay configurations with optional
/// compression. Data is base64-encoded for safe transport over Nostr.
/// Events are published to all relays concurrently; the first successful
/// response is returned.
class NostrSignalingImpl implements INostrSignaling {
  /// The signer's Nostr public key.
  final String pubkey;

  /// The signer's Nostr private key.
  final String privkey;

  /// The list of relays to publish/subscribe to.
  final List<INostrRelay> relays;

  /// Whether to compress data before publishing.
  final bool useCompression;

  /// The compression engine to use (required if [useCompression] is true).
  final ICompressionEngine? compressionEngine;

  final Map<NostrUserId, EventCallback> _subscriptions = {};
  final Map<NostrUserId, Map<INostrRelay, String>> _relaySubscriptionIds = {};

  /// Creates a [NostrSignalingImpl] with one or more relays.
  ///
  /// Throws [ArgumentError] if [relays] is empty.
  NostrSignalingImpl({
    required this.pubkey,
    required this.privkey,
    required List<INostrRelay> relays,
    this.useCompression = false,
    this.compressionEngine,
  }) : relays = relays.isNotEmpty ? relays : throw ArgumentError('At least one relay is required');

  /// Creates a [NostrSignalingImpl] with a single relay.
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

    // Publish to all relays, return first successful event ID
    final completer = Completer<String>();
    var errorCount = 0;

    for (final relay in relays) {
      relay.publishEvent(event).then((id) {
        if (!completer.isCompleted) completer.complete(id);
      }).catchError((_) {
        errorCount++;
        if (errorCount >= relays.length && !completer.isCompleted) {
          completer.complete(event.id ?? '');
        }
      });
    }

    return completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () => event.id ?? '',
    );
  }

  @override
  Future<String> subscribe(NostrUserId id, EventCallback onEvent, {int? since}) async {
    // Unsubscribe from previous subscription to this ID if it exists
    if (_relaySubscriptionIds.containsKey(id)) {
      await unsubscribe(id);
    }

    _subscriptions[id] = onEvent;
    _relaySubscriptionIds[id] = {};

    // Subscribe to all events from the specified author with our custom kinds
    final filter = NostrFilter(
      authors: [id],
      kinds: [1000, 1001],
      since: since != null
          ? DateTime.fromMillisecondsSinceEpoch(since * 1000)
          : null,
    );

    // Subscribe on all relays
    final subscriptionFutures = relays.map((relay) async {
      final subId = await relay.subscribe(filter, (event) {
        final data = _decodeContent(event.content ?? '');
        onEvent(id, data);
      });
      _relaySubscriptionIds[id]![relay] = subId;
      return subId;
    });

    final subIds = await Future.wait(subscriptionFutures);
    return subIds.first;
  }

  @override
  Future<List<int>> retriveLast(NostrUserId id) async {
    final filter = NostrFilter(
      authors: [id],
      kinds: [1000, 1001],
      limit: 1,
    );

    // Try to retrieve from all relays concurrently and return the first successful result
    final retrieveFutures = relays.map((relay) async {
      List<int> lastData = [];
      final completer = Completer<void>();

      try {
        final subId = await relay.subscribe(filter, (event) {
          lastData = _decodeContent(event.content ?? '');
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
  Future<void> unsubscribe(NostrUserId id) async {
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
    final keyPairs = NostrKeyPairs(private: privkey);
    return NostrEvent.fromPartialData(
      kind: kind,
      content: content,
      keyPairs: keyPairs,
      tags: [],
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
