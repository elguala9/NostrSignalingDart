import 'package:archive/archive.dart';

import '../interfaces/i_compression.dart';
import '../types.dart';

class GzipCompressionEngine implements ICompressionEngine {
  @override
  Future<CompressedData> compress(List<int> data) async {
    final originalSize = data.length;
    final compressed = GZipEncoder().encode(data);
    final compressedSize = compressed?.length ?? 0;

    final compressionRatio = originalSize > 0
        ? (1 - (compressedSize / originalSize)) * 100
        : 0.0;

    return CompressedData(
      originalSize: originalSize,
      compressedSize: compressedSize,
      compressionRatio: compressionRatio,
      data: compressed ?? data,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<int>> decompress(CompressedData compressed) async {
    try {
      final decompressed = GZipDecoder().decodeBytes(compressed.data);
      return decompressed;
    } catch (e) {
      // Se la decompressione fallisce, ritorna i dati originali
      return compressed.data;
    }
  }
}
