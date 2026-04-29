import 'package:archive/archive.dart';

import '../interfaces/i_compression.dart';
import '../types.dart';

/// GZip compression engine implementing [ICompressionEngine].
///
/// Compresses data using the GZip format and detects already-compressed
/// data by inspecting magic bytes to prevent double compression.
class GzipCompressionEngine implements ICompressionEngine {
  @override
  Future<CompressedData> compress(List<int> data) async {
    _checkIfAlreadyCompressed(data);

    final originalSize = data.length;
    final compressed = GZipEncoder().encode(data);
    final compressedSize = compressed.length;

    final compressionRatio = originalSize > 0
        ? (1 - (compressedSize / originalSize)) * 100
        : 0.0;

    return CompressedData(
      originalSize: originalSize,
      compressedSize: compressedSize,
      compressionRatio: compressionRatio,
      data: compressed,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Checks if [data] starts with magic bytes of a known compressed format.
  ///
  /// Throws [ArgumentError] if a compressed header (GZip, ZIP, BZip2, 7z, RAR)
  /// is detected, to prevent double compression.
  void _checkIfAlreadyCompressed(List<int> data) {
    if (data.isEmpty) return;

    final first = data[0];
    final second = data.length > 1 ? data[1] : 0;
    final third = data.length > 2 ? data[2] : 0;

    const suggestion = 'Consider using compress: false flag to skip compression.';

    // GZIP: 0x1f 0x8b
    if (first == 0x1f && second == 0x8b) {
      throw ArgumentError(
        'Data is already compressed with GZIP. $suggestion',
      );
    }

    // ZIP: 0x50 0x4b ('PK')
    if (first == 0x50 && second == 0x4b) {
      throw ArgumentError(
        'Data is already compressed with ZIP. $suggestion',
      );
    }

    // BZIP2: 0x42 0x5a ('BZ')
    if (first == 0x42 && second == 0x5a) {
      throw ArgumentError(
        'Data is already compressed with BZIP2. $suggestion',
      );
    }

    // 7z: 0x37 0x7a 0xbc
    if (first == 0x37 && second == 0x7a && third == 0xbc) {
      throw ArgumentError(
        'Data is already compressed with 7z. $suggestion',
      );
    }

    // RAR: 0x52 0x61 0x72 ('Rar')
    if (first == 0x52 && second == 0x61 && third == 0x72) {
      throw ArgumentError(
        'Data is already compressed with RAR. $suggestion',
      );
    }
  }

  @override
  Future<List<int>> decompress(CompressedData compressed) async {
    try {
      final decompressed = GZipDecoder().decodeBytes(compressed.data);
      return decompressed;
    } catch (e) {
      return compressed.data;
    }
  }
}
