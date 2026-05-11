import 'implementations/gzip_compression_engine.dart';
import 'implementations/nostr_relay_impl.dart';
import 'implementations/nostr_signaling_impl.dart';
import 'interfaces/i_relay.dart';
import 'interfaces/i_compression.dart';
import 'interfaces/i_nostr_signaling.dart';
import 'keys.dart';
import 'nostr_relay_list.dart';

class NostrSignalingFactory {
  static const String _defaultRelayUrl = 'wss://relay.damus.io';

  static INostrSignaling create({
    required NostrKeyPair keyPair,
    List<String> relayUrls = const [_defaultRelayUrl],
    bool useCompression = false,
    ICompressionEngine? compressionEngine,
  }) {
    final relays = relayUrls.map((url) => NostrRelayImpl(relayUrl: url)).toList();
    return NostrSignalingImpl(
      keyPair: keyPair,
      relays: NostrRelayList(relays),
      useCompression: useCompression,
      compressionEngine: compressionEngine ??
          (useCompression ? GzipCompressionEngine() : null),
    );
  }

  static INostrSignaling createWithCustomRelays({
    required NostrKeyPair keyPair,
    required List<INostrRelay> relays,
    bool useCompression = false,
    ICompressionEngine? compressionEngine,
  }) {
    return NostrSignalingImpl(
      keyPair: keyPair,
      relays: NostrRelayList(relays),
      useCompression: useCompression,
      compressionEngine: compressionEngine ??
          (useCompression ? GzipCompressionEngine() : null),
    );
  }
}
