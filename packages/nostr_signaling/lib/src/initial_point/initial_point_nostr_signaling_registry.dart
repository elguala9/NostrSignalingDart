import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:singleton_manager/singleton_manager.dart';




/// Registry-based variant of [initialPointNostrSignaling].
///
/// Registers [NostrSignalingImpl] under a named [registryKey] via [RegistryAccess],
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
  String registryKey = 'default',
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

  RegistryAccess.register<INostrSignaling>(registryKey, signaling);
}

/// Convenience registry initial point that uses 10 standard Nostr relays
/// and no compression. Only [keyPair] is required; [key] defaults to `'default'`.
///
/// Usage:
/// ```dart
/// initialPointNostrSignalingRegistryDefault(keyPair: myKeyPair);
/// initialPointNostrSignalingRegistryDefault(key: 'alice', keyPair: aliceKeyPair);
/// ```
void initialPointNostrSignalingRegistryDefault({
  String key = 'default',
  required NostrKeyPair keyPair,
}) {
  
  NostrConfig config = NostrConfig.loadSync() ?? NostrConfig();
  initialPointNostrSignalingRegistry(
    registryKey: key,
    keyPair: keyPair,
    relayUrls: config.relays,
    useCompression: false,
  );
}

/// Registry-based initial point that reads key pair and relays from [NostrConfig].
///
/// Loads [NostrConfig] from [configPath] (default: `nostr_config.json`).
/// Throws [StateError] if the file is missing or contains no key pair.
///
/// Usage:
/// ```dart
/// initialPointNostrSignalingRegistryFromConfig();
/// initialPointNostrSignalingRegistryFromConfig(key: 'alice');
/// ```
void initialPointNostrSignalingRegistryFromConfig({
  String key = 'default',
  String configPath = NostrConfig.defaultConfigPath,
  bool useCompression = false,
  ICompressionEngine? compressionEngine,
}) {
  final config = NostrConfig.loadSync(configPath);
  if (config == null) {
    throw StateError('Config file not found: $configPath');
  }
  final keyPair = config.keyPair;
  if (keyPair == null) {
    throw StateError('No keyPair in config: $configPath');
  }
  initialPointNostrSignalingRegistry(
    registryKey: key,
    keyPair: keyPair,
    relayUrls: config.relays,
    useCompression: useCompression,
    compressionEngine: compressionEngine,
  );
}

/// Retrieve IIdHandlerStorageRepository from registry by key.
INostrSignaling getINostrSignalingFromRegistry(
        {String key = 'default'}) =>
    RegistryAccess.getInstance<INostrSignaling>(key);
