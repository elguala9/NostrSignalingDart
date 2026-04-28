import 'implementations/gzip_compression_engine.dart';
import 'implementations/nostr_relay_impl.dart';
import 'implementations/nostr_signaling_impl.dart';
import 'interfaces/i_relay.dart';
import 'interfaces/i_compression.dart';
import 'interfaces/i_nostr_signaling.dart';

class NostrSignalingFactory {
  static const String _defaultRelayUrl = 'wss://relay.damus.io';

  /// Creates INostrSignaling with a single relay (default: Damus relay)
  static INostrSignaling create({
    required String pubkey,
    required String privkey,
    String relayUrl = _defaultRelayUrl,
    bool useCompression = false,
    ICompressionEngine? compressionEngine,
  }) {
    final relay = NostrRelayImpl(relayUrl: relayUrl);

    return NostrSignalingImpl.single(
      pubkey: pubkey,
      privkey: privkey,
      relay: relay,
      useCompression: useCompression,
      compressionEngine: compressionEngine,
    );
  }

  /// Creates INostrSignaling with multiple relays for redundancy
  static INostrSignaling createWithMultipleRelays({
    required String pubkey,
    required String privkey,
    List<String> relayUrls = const [_defaultRelayUrl],
    bool useCompression = false,
    ICompressionEngine? compressionEngine,
  }) {
    final relays = relayUrls.map((url) => NostrRelayImpl(relayUrl: url)).toList();

    return NostrSignalingImpl(
      pubkey: pubkey,
      privkey: privkey,
      relays: relays,
      useCompression: useCompression,
      compressionEngine: compressionEngine,
    );
  }

  /// Creates INostrSignaling with GZIP compression and a single relay
  static INostrSignaling createWithGzipCompression({
    required String pubkey,
    required String privkey,
    String relayUrl = _defaultRelayUrl,
  }) {
    final relay = NostrRelayImpl(relayUrl: relayUrl);
    final compressionEngine = GzipCompressionEngine();

    return NostrSignalingImpl.single(
      pubkey: pubkey,
      privkey: privkey,
      relay: relay,
      useCompression: true,
      compressionEngine: compressionEngine,
    );
  }

  /// Creates INostrSignaling with GZIP compression and multiple relays
  static INostrSignaling createWithGzipCompressionAndMultipleRelays({
    required String pubkey,
    required String privkey,
    List<String> relayUrls = const [_defaultRelayUrl],
  }) {
    final relays = relayUrls.map((url) => NostrRelayImpl(relayUrl: url)).toList();
    final compressionEngine = GzipCompressionEngine();

    return NostrSignalingImpl(
      pubkey: pubkey,
      privkey: privkey,
      relays: relays,
      useCompression: true,
      compressionEngine: compressionEngine,
    );
  }

  /// Creates INostrSignaling with custom relay instances
  static INostrSignaling createWithCustomRelays({
    required String pubkey,
    required String privkey,
    required List<INostrRelay> relays,
    bool useCompression = false,
    ICompressionEngine? compressionEngine,
  }) {
    return NostrSignalingImpl(
      pubkey: pubkey,
      privkey: privkey,
      relays: relays,
      useCompression: useCompression,
      compressionEngine: compressionEngine,
    );
  }
}
