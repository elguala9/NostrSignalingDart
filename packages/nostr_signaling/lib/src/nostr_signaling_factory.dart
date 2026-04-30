import 'implementations/gzip_compression_engine.dart';
import 'implementations/nostr_relay_impl.dart';
import 'implementations/nostr_signaling_impl.dart';
import 'interfaces/i_relay.dart';
import 'interfaces/i_compression.dart';
import 'interfaces/i_nostr_signaling.dart';
import 'keys.dart';
import 'nostr_relay_list.dart';

/// Factory for creating [INostrSignaling] instances with common configurations.
///
/// Provides pre-configured factory methods for single relay, multi-relay,
/// compression, and custom relay setups.
class NostrSignalingFactory {
  static const String _defaultRelayUrl = 'wss://relay.damus.io';

  /// Creates an [INostrSignaling] with a single relay.
  ///
  /// Uses the Damus relay by default. Optionally enables compression
  /// with a custom [compressionEngine].
  static INostrSignaling create({
    required NostrKeyPair keyPair,
    String relayUrl = _defaultRelayUrl,
    bool useCompression = false,
    ICompressionEngine? compressionEngine,
  }) {
    final relay = NostrRelayImpl(relayUrl: relayUrl);

    return NostrSignalingImpl.single(
      keyPair: keyPair,
      relay: relay,
      useCompression: useCompression,
      compressionEngine: compressionEngine,
    );
  }

  /// Creates an [INostrSignaling] with multiple relays for redundancy.
  ///
  /// Events are published to all relays. The first successful response
  /// is returned.
  static INostrSignaling createWithMultipleRelays({
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
      compressionEngine: compressionEngine,
    );
  }

  /// Creates an [INostrSignaling] with GZip compression and a single relay.
  static INostrSignaling createWithGzipCompression({
    required NostrKeyPair keyPair,
    String relayUrl = _defaultRelayUrl,
  }) {
    final relay = NostrRelayImpl(relayUrl: relayUrl);
    final compressionEngine = GzipCompressionEngine();

    return NostrSignalingImpl.single(
      keyPair: keyPair,
      relay: relay,
      useCompression: true,
      compressionEngine: compressionEngine,
    );
  }

  /// Creates an [INostrSignaling] with GZip compression and multiple relays.
  static INostrSignaling createWithGzipCompressionAndMultipleRelays({
    required NostrKeyPair keyPair,
    List<String> relayUrls = const [_defaultRelayUrl],
  }) {
    final relays = relayUrls.map((url) => NostrRelayImpl(relayUrl: url)).toList();
    final compressionEngine = GzipCompressionEngine();

    return NostrSignalingImpl(
      keyPair: keyPair,
      relays: NostrRelayList(relays),
      useCompression: true,
      compressionEngine: compressionEngine,
    );
  }

  /// Creates an [INostrSignaling] with custom [INostrRelay] instances.
  ///
  /// Use this when you need full control over relay configuration.
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
      compressionEngine: compressionEngine,
    );
  }
}
