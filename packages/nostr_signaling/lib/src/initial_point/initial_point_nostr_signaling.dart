import 'package:nostr_signaling/src/implementations/config.dart';
import 'package:nostr_signaling/src/interfaces/i_event_callback.dart';
import 'package:singleton_manager/singleton_manager.dart';

import '../implementations/gzip_compression_engine.dart';
import '../implementations/nostr_relay_impl.dart';
import '../implementations/nostr_signaling_impl.dart';
import '../interfaces/i_compression.dart';
import '../interfaces/i_nostr_signaling.dart';
import '../keys.dart';
import '../nostr_relay_list.dart';
import '../types.dart';

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
  Map<NostrUserId, IEventCallback>? onEventCallbacks,
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

  if (onEventCallbacks != null) {
    signaling.setOnEventCallbacks(onEventCallbacks);
  }

  SingletonDIAccess.addInstanceAs<INostrSignaling, NostrSignalingImpl>(signaling);
}

/// Convenience initial point that uses 10 standard Nostr relays and no compression.
///
/// Only [keyPair] is required; everything else is pre-configured.
///
/// Usage:
/// ```dart
/// await initialPointNostrSignalingDefault(keyPair: myKeyPair);
/// ```
Future<void> initialPointNostrSignalingDefault({
  required NostrKeyPair keyPair,
  Map<NostrUserId, IEventCallback>? onEventCallbacks,
}) async {

  NostrConfig config = (await NostrConfig.load()) ?? NostrConfig();
  await initialPointNostrSignaling(
    keyPair: keyPair,
    relayUrls: config.relays,
    useCompression: false,
    onEventCallbacks: onEventCallbacks,
  );
}

/// Initial point that reads key pair and relays from [NostrConfig].
///
/// Loads [NostrConfig] from [configPath] (default: `nostr_config.json`).
/// Throws [StateError] if the file is missing or contains no key pair.
///
/// Usage:
/// ```dart
/// await initialPointNostrSignalingFromConfig();
/// ```
Future<void> initialPointNostrSignalingFromConfig({
  String configPath = NostrConfig.defaultConfigPath,
  bool useCompression = false,
  ICompressionEngine? compressionEngine,
  Map<NostrUserId, IEventCallback>? onEventCallbacks,
}) async {
  final config = await NostrConfig.load(configPath);
  if (config == null) {
    throw StateError('Config file not found: $configPath');
  }
  final keyPair = config.keyPair;
  if (keyPair == null) {
    throw StateError('No keyPair in config: $configPath');
  }
  await initialPointNostrSignaling(
    keyPair: keyPair,
    relayUrls: config.relays,
    useCompression: useCompression,
    compressionEngine: compressionEngine,
    onEventCallbacks: onEventCallbacks,
  );
}

/// Retrieve [INostrSignaling] from the singleton DI registry.
///
/// Must be called after [initialPointNostrSignaling] or
/// [initialPointNostrSignalingDefault] has completed.
INostrSignaling getINostrSignaling() =>
    SingletonDIAccess.get<INostrSignaling>();
