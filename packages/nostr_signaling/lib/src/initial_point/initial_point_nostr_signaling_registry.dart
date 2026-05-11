import 'package:singleton_manager/singleton_manager.dart';
import '../implementations/config.dart';
import '../implementations/gzip_compression_engine.dart';
import '../implementations/nostr_relay_impl.dart';
import '../implementations/nostr_signaling_impl.dart';
import '../interfaces/i_compression.dart';
import '../interfaces/i_event_callback.dart';
import '../interfaces/i_nostr_signaling.dart';
import '../keys.dart';
import '../nostr_relay_list.dart';
import '../types.dart';

void initialPointNostrSignalingRegistry({
  String registryKey = 'default',
  required NostrKeyPair keyPair,
  List<String> relayUrls = const ['wss://relay.damus.io'],
  bool useCompression = false,
  ICompressionEngine? compressionEngine,
  Map<NostrUserId, IEventCallback>? onEventCallbacks,
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

  if (onEventCallbacks != null) {
    signaling.setOnEventCallbacks(onEventCallbacks);
  }

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
    useCompression: false,
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
