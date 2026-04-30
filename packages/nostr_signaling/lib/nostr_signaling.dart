/// A Nostr-based signaling library for exchanging binary data between peers.
///
/// Provides publish/subscribe semantics over the Nostr protocol with
/// optional GZip compression, multi-relay redundancy, and pluggable
/// compression engines.
library nostr_signaling;

export 'src/constants.dart';
export 'src/types.dart';
export 'src/keys.dart';
export 'src/interfaces/i_compression.dart';
export 'src/interfaces/i_nostr_signaling.dart';
export 'src/interfaces/i_relay.dart';
export 'src/implementations/nostr_signaling_impl.dart';
export 'src/implementations/nostr_relay_impl.dart';
export 'src/implementations/gzip_compression_engine.dart';
export 'src/nostr_relay_list.dart';
export 'src/nostr_signaling_factory.dart';
export 'src/initial_point/initial_point_nostr_signaling.dart';
export 'src/initial_point/initial_point_nostr_signaling_registry.dart';
