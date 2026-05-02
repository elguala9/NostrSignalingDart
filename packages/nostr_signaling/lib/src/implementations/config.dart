import 'dart:convert';
import 'dart:io';

import '../constants.dart';
import '../keys.dart';

const standardRelays = [
    NostrStandardRelays.damus,
    NostrStandardRelays.nostr,
    NostrStandardRelays.nos,
    NostrStandardRelays.primal,
    NostrStandardRelays.startr,
    NostrStandardRelays.band,
    NostrStandardRelays.purple,
    NostrStandardRelays.snort,
    NostrStandardRelays.wine,
    NostrStandardRelays.offchain,
  ];

class NostrConfig{
  static const String defaultConfigPath = 'nostr_config.json';

 List<String> relays;

  NostrKeyPair? keyPair;

  String collection;

  NostrConfig({List<String>? relays, this.keyPair, String? collection})
      : relays = relays ?? standardRelays,
        collection = collection ?? defaultEventCallbackCollection;

  Map<String, dynamic> toJson() => {
    'relays': relays,
    'collection': collection,
    if (keyPair != null) ...{
      'privateKey': keyPair!.privateKey,
      'publicKey': keyPair!.publicKey,
    },
  };

  factory NostrConfig.fromJson(Map<String, dynamic> json) {
    final keyPair = json['privateKey'] != null && json['publicKey'] != null
        ? NostrKeyPair(
            privateKey: json['privateKey'] as String,
            publicKey: json['publicKey'] as String,
          )
        : null;
    return NostrConfig(
      relays: (json['relays'] as List<dynamic>?)?.cast<String>(),
      keyPair: keyPair,
      collection: json['collection'] as String?,
    );
  }

  static Future<NostrConfig?> load([String path = defaultConfigPath]) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final contents = await file.readAsString();
        final json = jsonDecode(contents) as Map<String, dynamic>;
        return NostrConfig.fromJson(json);
      }
    } catch (_) {}
    return null;
  }

  static NostrConfig? loadSync([String path = defaultConfigPath]) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        final contents = file.readAsStringSync();
        final json = jsonDecode(contents) as Map<String, dynamic>;
        return NostrConfig.fromJson(json);
      }
    } catch (_) {}
    return null;
  }

  Future<void> save([String path = defaultConfigPath]) async {
    await File(path).writeAsString(jsonEncode(toJson()));
  }
}