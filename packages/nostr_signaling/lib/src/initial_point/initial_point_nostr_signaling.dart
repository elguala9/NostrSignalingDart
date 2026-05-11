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

Future<void> initialPointNostrSignaling({
  required NostrKeyPair keyPair,
  List<String> relayUrls = const ['wss://relay.damus.io'],
  bool useCompression = false,
  ICompressionEngine? compressionEngine,
  Map<NostrUserId, IEventCallback>? onEventCallbacks,
}) async {
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
    useCompression: false,
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
