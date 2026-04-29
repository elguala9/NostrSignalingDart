/// Metadata and payload from a compression operation.
///
/// Contains the original and compressed sizes, the compression ratio,
/// the raw compressed bytes, and a timestamp.
class CompressedData {
  /// Size of the data before compression (in bytes).
  final int originalSize;

  /// Size of the data after compression (in bytes).
  final int compressedSize;

  /// Compression ratio as a percentage (0.0 = no compression, 100.0 = perfect).
  final double compressionRatio;

  /// The compressed byte payload.
  final List<int> data;

  /// Unix timestamp (milliseconds) when compression occurred.
  final int timestamp;

  /// Creates a [CompressedData] instance.
  CompressedData({
    required this.originalSize,
    required this.compressedSize,
    required this.compressionRatio,
    required this.data,
    required this.timestamp,
  });
}

/// A Nostr public key identifier (hex-encoded 32-byte public key).
typedef NostrId = String;
