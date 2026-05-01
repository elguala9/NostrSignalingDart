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
typedef NostrUserId = String;

/// Hash length for the payload hash field.
///
/// Controls how many hex characters of the SHA-256 digest are included
/// in the published payload. Shorter hashes reduce payload size at the
/// cost of a higher collision probability.
enum PayloadHashLength {
  /// 8 hex characters (32 bits) – minimal, useful for high-throughput signaling
  bits32(8),

  /// 16 hex characters (64 bits) – good default balance
  bits64(16),

  /// 64 hex characters (256 bits) – full SHA-256 digest
  bits256(64);

  /// Number of hex characters for this hash length.
  final int hexChars;
  const PayloadHashLength(this.hexChars);
}
