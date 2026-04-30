import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:singleton_manager/singleton_manager.dart';

import '../implementations/gzip_compression_engine.dart';
import '../implementations/nostr_relay_impl.dart';
import '../implementations/nostr_signaling_impl.dart';
import '../interfaces/i_compression.dart';
import '../keys.dart';
import '../nostr_relay_list.dart';

/// Registry-based variant of [initialPointNostrSignaling].
///
/// Registers [NostrSignalingImpl] under a named [key] via [RegistryAccess],
/// allowing multiple named instances (e.g., `'alice'`, `'bob'`) to coexist.
///
/// Usage:
/// ```dart
/// initialPointNostrSignalingRegistry(
///   key: 'alice',
///   keyPair: aliceKeyPair,
/// );
/// ```
void initialPointNostrSignalingRegistry({
  String key = 'default',
  required NostrKeyPair keyPair,
  List<String> relayUrls = const ['wss://relay.damus.io'],
  bool useCompression = false,
  ICompressionEngine? compressionEngine,
}) {
  final relays = relayUrls
      .map((url) => NostrRelayImpl(relayUrl: url))
      .toList();

  final signaling = NostrSignalingImpl(
    keyPair: keyPair,
    relays: NostrRelayList(relays),
    useCompression: useCompression,
    compressionEngine: compressionEngine ??
        (useCompression ? GzipCompressionEngine() : null),
  );

  RegistryAccess.register<INostrSignaling>(key, signaling);
}

/// Retrieve IIdHandlerStorageRepository from registry by key.
INostrSignaling getINostrSignalingFromRegistry(
        {String key = 'default'}) =>
    RegistryAccess.getInstance<INostrSignaling>(key);
