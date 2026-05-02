import 'dart:async';
import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:crypto/crypto.dart' as crypto;

import 'package:dart_nostr/dart_nostr.dart';
import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:singleton_manager/singleton_manager.dart';


@isSingleton
class NostrSignalingImpl implements INostrSignaling, IValueForRegistry {
  @protected
  @isMandatoryParameter
  late NostrKeyPair keyPair;

  String get pubkey => keyPair.publicKey;
  String get privkey => keyPair.privateKey;

  @isInjected
  @protected
  late NostrRelayList relays;

  late bool useCompression;
  late PayloadHashLength payloadHashLength;

  @isOptionalParameter
  @protected
  late ICompressionEngine? compressionEngine = GzipCompressionEngine();

  final Map<NostrUserId, IEventCallback> _subscriptions = {};
  final Map<NostrUserId, Map<INostrRelay, String>> _relaySubscriptionIds = {};
  Map<NostrUserId, IEventCallback>? _pendingCallbacks;

  NostrSignalingImpl.emptyForDI();

  void initializeDI() {
    relays = NostrRelayList([]);
  }

  NostrSignalingImpl({
    required this.keyPair,
    required this.relays,
    this.useCompression = false,
    this.payloadHashLength = PayloadHashLength.bits64,
    ICompressionEngine? compressionEngine,
  }) : compressionEngine = compressionEngine ?? GzipCompressionEngine();

  NostrSignalingImpl.single({
    required this.keyPair,
    required INostrRelay relay,
    this.useCompression = false,
    this.payloadHashLength = PayloadHashLength.bits64,
    ICompressionEngine? compressionEngine,
  }) : relays = NostrRelayList.single(relay),
       compressionEngine = compressionEngine ?? GzipCompressionEngine();

  void setOnEventCallbacks(Map<NostrUserId, IEventCallback> onEventCallbacks) {
    _pendingCallbacks = onEventCallbacks;
  }

  @override
  Future<void> connect() async {
    await relays.connectAll();
    if (_pendingCallbacks != null) {
      await Future.wait(
        _pendingCallbacks!.entries.map((e) => subscribe(e.key, e.value)),
      );
      _pendingCallbacks = null;
    }
  }

  @override
  Future<void> disconnect() async {
    await Future.wait(_subscriptions.keys.map(unsubscribe));
    await relays.disconnectAll();
  }

  @override
  Future<void> destroy() => disconnect();

  @override
  bool isConnected() => relays.isAnyConnected();

  @override
  Future<String> publish(List<int> data) async {
    final rawBytes = useCompression
        ? (await compressionEngine?.compress(data) as CompressedData).data
        : data;

    final payloadInfo = _PayloadInfo(
      data: rawBytes,
      createdAt: DateTime.now().toUtc(),
      hashLength: payloadHashLength,
    );

    final event = _createEvent(
      content: payloadInfo.toJson(),
      kind: useCompression ? 1000 : 1001,
    );

    final completer = Completer<String>();
    int failures = 0;
    for (final relay in relays) {
      relay.publishEvent(event).then((id) {
        if (!completer.isCompleted) completer.complete(id);
      }).catchError((_) {
        failures++;
        if (failures == relays.length && !completer.isCompleted) {
          completer.completeError(Exception('All relays failed to publish'));
        }
      });
    }

    return completer.future.timeout(const Duration(seconds: 15));
  }

  @override
  Future<String> subscribe(NostrUserId id, IEventCallback onEvent, {int? since}) async {
    if (_relaySubscriptionIds.containsKey(id)) await unsubscribe(id);

    _subscriptions[id] = onEvent;
    _relaySubscriptionIds[id] = {};

    since ??= DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final filter = NostrFilter(
      authors: [id],
      kinds: [1000, 1001],
      since: DateTime.fromMillisecondsSinceEpoch(since * 1000),
    );

    final subIds = await Future.wait(relays.map((relay) async {
      final subId = await relay.subscribe(filter, (event) {
        final content = event.content ?? '';
        final payload = _decodePayload(content);
        final data = payload?.data ?? _decodeContent(content);
        onEvent(id, data, hash: payload?.hash);
      });
      _relaySubscriptionIds[id]![relay] = subId;
      return subId;
    }));
    return subIds.first;
  }

  @override
  Future<List<int>> retrieveLast(NostrUserId id) async {
    final filter = NostrFilter(
      authors: [id],
      kinds: [1000, 1001],
      limit: 1,
    );

    final results = <_PayloadInfo>[];
    await Future.wait(relays.map((relay) async {
      final subId = await relay.subscribe(filter, (event) {
        final payload = _decodePayload(event.content ?? '');
        if (payload != null) results.add(payload);
      });
      Future.delayed(const Duration(seconds: 5), () {
        relay.unsubscribe(subId);
      });
    }));

    await Future.delayed(const Duration(seconds: 6));
    if (results.isEmpty) return [];

    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results.first.data;
  }

  @override
  Future<void> unsubscribe(NostrUserId id) async {
    _subscriptions.remove(id);
    final subIds = _relaySubscriptionIds.remove(id) ?? {};
    await Future.wait(
      subIds.entries.map((e) => e.key.unsubscribe(e.value)),
      eagerError: false,
    );
  }

  NostrEvent _createEvent({
    required String content,
    required int kind,
  }) {
    final keyPairs = NostrKeyPairs(private: keyPair.privateKey);
    return NostrEvent.fromPartialData(
      kind: kind,
      content: content,
      keyPairs: keyPairs,
      tags: [],
    );
  }

  List<int> _decodeContent(String content) {
    if (content.startsWith('{')) {
      final d = jsonDecode(content);
      if (d is Map && d['data'] is String) return base64Decode(d['data'] as String);
    }
    if (RegExp(r'^[A-Za-z0-9+/]*={0,2}$').hasMatch(content)) return base64Decode(content);
    return utf8.encode(content);
  }

  _PayloadInfo? _decodePayload(String content) => _PayloadInfo.fromJson(content);
}

class _PayloadInfo {
  final List<int> data;
  final DateTime createdAt;
  final String hash;
  final PayloadHashLength hashLength;

  _PayloadInfo({
    required this.data,
    required this.createdAt,
    this.hashLength = PayloadHashLength.bits64,
  }) : hash = crypto.sha256
            .convert(data)
            .toString()
            .substring(0, hashLength.hexChars);

  _PayloadInfo._fromParsed({
    required this.data,
    required this.createdAt,
    required this.hash,
  }) : hashLength = PayloadHashLength.values.firstWhere(
          (l) => l.hexChars == hash.length,
          orElse: () => PayloadHashLength.bits64,
        );

  String toJson() => jsonEncode({
        'data': base64Encode(data),
        'created_at': createdAt.toUtc().toIso8601String(),
        'hash': hash,
      });

  static _PayloadInfo? fromJson(String content) {
    if (!content.startsWith('{')) return null;
    final d = jsonDecode(content);
    if (d is Map && d['data'] is String && d['created_at'] is String && d['hash'] is String) {
      return _PayloadInfo._fromParsed(
        data: base64Decode(d['data'] as String),
        createdAt: DateTime.parse(d['created_at'] as String),
        hash: d['hash'] as String,
      );
    }
    return null;
  }
}
