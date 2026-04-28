import 'implementations/gzip_compression_engine.dart';
import 'implementations/nostr_relay_impl.dart';
import 'implementations/nostr_signaling_impl.dart';
import 'interfaces/compression.dart';
import 'interfaces/nostr_signaling.dart';

class NostrSignalingFactory {
  static const String _defaultRelayUrl = 'wss://relay.damus.io';

  /// Crea un'istanza di INostrSignaling con il relay di default
  static INostrSignaling create({
    required String pubkey,
    required String privkey,
    String relayUrl = _defaultRelayUrl,
    bool useCompression = false,
    ICompressionEngine? compressionEngine,
  }) {
    final relay = NostrRelayImpl(relayUrl: relayUrl);

    return NostrSignalingImpl(
      pubkey: pubkey,
      privkey: privkey,
      relay: relay,
      useCompression: useCompression,
      compressionEngine: compressionEngine,
    );
  }

  /// Crea un'istanza di INostrSignaling con compressione GZip attivata
  static INostrSignaling createWithGzipCompression({
    required String pubkey,
    required String privkey,
    String relayUrl = _defaultRelayUrl,
  }) {
    final relay = NostrRelayImpl(relayUrl: relayUrl);
    final compressionEngine = GzipCompressionEngine();

    return NostrSignalingImpl(
      pubkey: pubkey,
      privkey: privkey,
      relay: relay,
      useCompression: true,
      compressionEngine: compressionEngine,
    );
  }

  /// Crea un'istanza di INostrSignaling con un relay custom
  static INostrSignaling createWithCustomRelay({
    required String pubkey,
    required String privkey,
    required NostrRelayImpl relay,
    bool useCompression = false,
    ICompressionEngine? compressionEngine,
  }) {
    return NostrSignalingImpl(
      pubkey: pubkey,
      privkey: privkey,
      relay: relay,
      useCompression: useCompression,
      compressionEngine: compressionEngine,
    );
  }
}
