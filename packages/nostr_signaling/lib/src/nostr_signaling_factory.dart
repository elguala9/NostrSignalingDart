import 'implementations/gzip_compression_engine.dart';
import 'implementations/nostr_relay_impl.dart';
import 'implementations/nostr_signaling_impl.dart';
import 'interfaces/i_relay.dart';
import 'interfaces/i_compression.dart';
import 'interfaces/i_nostr_signaling.dart';

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

  /// Creates an [INostrSignaling] with multiple relays for redundancy.
  ///
  /// Events are published to all relays. The first successful response
  /// is returned.
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

  /// Creates an [INostrSignaling] with GZip compression and a single relay.
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

  /// Creates an [INostrSignaling] with GZip compression and multiple relays.
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

  /// Creates an [INostrSignaling] with custom [INostrRelay] instances.
  ///
  /// Use this when you need full control over relay configuration.
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
