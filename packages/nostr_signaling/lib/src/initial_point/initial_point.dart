import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:singleton_manager/singleton_manager.dart';

NostrSignalingImpl _createSignaling({
  required NostrKeyPair keyPair,
  required List<String> relayUrls,
  required bool useCompression,
  ICompressionEngine? compressionEngine,
  Map<NostrUserId, IEventCallback>? onEventCallbacks,
}) {
  final relays = relayUrls.map((url) => NostrRelayImpl(relayUrl: url)).toList();
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
  return signaling;
}

Future<void> initialPointNostrSignaling({
  required NostrKeyPair keyPair,
  List<String> relayUrls = const ['wss://relay.damus.io'],
  bool useCompression = false,
  ICompressionEngine? compressionEngine,
  Map<NostrUserId, IEventCallback>? onEventCallbacks,
}) async {
  final signaling = _createSignaling(
    keyPair: keyPair,
    relayUrls: relayUrls,
    useCompression: useCompression,
    compressionEngine: compressionEngine,
    onEventCallbacks: onEventCallbacks,
  );
  SingletonDIAccess.addInstanceAs<INostrSignaling, NostrSignalingImpl>(signaling);
}

Future<void> initialPointNostrSignalingDefault({
  required NostrKeyPair keyPair,
  Map<NostrUserId, IEventCallback>? onEventCallbacks,
}) async {
  final config = await NostrConfig.load();
  await initialPointNostrSignaling(
    keyPair: keyPair,
    relayUrls: config.relays,
    onEventCallbacks: onEventCallbacks,
  );
}

Future<void> initialPointNostrSignalingFromConfig({
  String configPath = NostrConfig.defaultConfigPath,
  bool useCompression = false,
  ICompressionEngine? compressionEngine,
  Map<NostrUserId, IEventCallback>? onEventCallbacks,
}) async {
  final config = await NostrConfig.load(configPath);
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

INostrSignaling getINostrSignaling() =>
    SingletonDIAccess.get<INostrSignaling>();

void initialPointNostrSignalingRegistry({
  String registryKey = 'default',
  required NostrKeyPair keyPair,
  List<String> relayUrls = const ['wss://relay.damus.io'],
  bool useCompression = false,
  ICompressionEngine? compressionEngine,
  Map<NostrUserId, IEventCallback>? onEventCallbacks,
}) {
  final signaling = _createSignaling(
    keyPair: keyPair,
    relayUrls: relayUrls,
    useCompression: useCompression,
    compressionEngine: compressionEngine,
    onEventCallbacks: onEventCallbacks,
  );
  RegistryAccess.register<INostrSignaling>(registryKey, signaling);
}

void initialPointNostrSignalingRegistryDefault({
  String key = 'default',
  required NostrKeyPair keyPair,
  Map<NostrUserId, IEventCallback>? onEventCallbacks,
}) {
  final config = NostrConfig.loadSync();
  initialPointNostrSignalingRegistry(
    registryKey: key,
    keyPair: keyPair,
    relayUrls: config.relays,
    onEventCallbacks: onEventCallbacks,
  );
}

void initialPointNostrSignalingRegistryFromConfig({
  String key = 'default',
  String configPath = NostrConfig.defaultConfigPath,
  bool useCompression = false,
  ICompressionEngine? compressionEngine,
  Map<NostrUserId, IEventCallback>? onEventCallbacks,
}) {
  final config = NostrConfig.loadSync(configPath);
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
    onEventCallbacks: onEventCallbacks,
  );
}

INostrSignaling getINostrSignalingFromRegistry({
  String key = 'default',
}) => RegistryAccess.getInstance<INostrSignaling>(key);
