import 'package:singleton_manager/singleton_manager.dart';

import '../implementations/gzip_compression_engine.dart';
import '../implementations/nostr_relay_impl.dart';
import '../implementations/nostr_signaling_impl.dart';
import '../interfaces/i_compression.dart';
import '../interfaces/i_nostr_signaling.dart';
import '../keys.dart';
import '../nostr_relay_list.dart';

/// DI-style initialisation of the Nostr signaling stack.
///
/// Creates relay connections and the signaling instance, then registers
/// [INostrSignaling] as a global singleton via [SingletonDIAccess].
///
/// Usage:
/// ```dart
/// await initialPointNostrSignaling(
///   keyPair: myKeyPair,
///   relayUrls: ['wss://relay.damus.io'],
/// );
/// ```
Future<void> initialPointNostrSignaling({
  required NostrKeyPair keyPair,
  List<String> relayUrls = const ['wss://relay.damus.io'],
  bool useCompression = false,
  ICompressionEngine? compressionEngine,
}) async {
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

  SingletonDIAccess.addInstanceAs<INostrSignaling, NostrSignalingImpl>(signaling);
}


/// Retrieve IIdHandlerStorageRepository from registry by key.
INostrSignaling getINostrSignaling({String key = 'default'}) =>
    RegistryAccess.getInstance<INostrSignaling>(key);
