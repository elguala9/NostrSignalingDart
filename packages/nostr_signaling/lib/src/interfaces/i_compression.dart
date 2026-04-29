import '../types.dart';

/// Pluggable compression engine interface.
///
/// Implement this interface to add custom compression algorithms
/// (e.g. Zstd, LZ4, Brotli) to the signaling pipeline.
abstract class ICompressionEngine {
  /// Compresses [data] and returns compression metadata.
  Future<CompressedData> compress(List<int> data);

  /// Decompresses [compressed] data back to its original form.
  Future<List<int>> decompress(CompressedData compressed);
}
