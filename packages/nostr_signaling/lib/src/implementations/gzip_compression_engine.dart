import 'package:archive/archive.dart';

import '../interfaces/i_compression.dart';
import '../types.dart';

class GzipCompressionEngine implements ICompressionEngine {
  @override
  Future<CompressedData> compress(List<int> data) async {
    _checkIfAlreadyCompressed(data);

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

  /// Controlla se i dati sono già compressi
  /// Lancia ArgumentError se riconosce un formato compresso
  void _checkIfAlreadyCompressed(List<int> data) {
    if (data.isEmpty) return;

    // Controlla magic number (primi 2-3 byte)
    final first = data[0];
    final second = data.length > 1 ? data[1] : 0;
    final third = data.length > 2 ? data[2] : 0;

    // GZIP: 0x1f 0x8b
    if (first == 0x1f && second == 0x8b) {
      throw ArgumentError('I dati sono già compressi con GZIP');
    }

    // ZIP: 0x50 0x4b ('PK')
    if (first == 0x50 && second == 0x4b) {
      throw ArgumentError('I dati sono già compressi con ZIP');
    }

    // BZIP2: 0x42 0x5a ('BZ')
    if (first == 0x42 && second == 0x5a) {
      throw ArgumentError('I dati sono già compressi con BZIP2');
    }

    // 7z: 0x37 0x7a 0xbc
    if (first == 0x37 && second == 0x7a && third == 0xbc) {
      throw ArgumentError('I dati sono già compressi con 7z');
    }

    // RAR: 0x52 0x61 0x72 ('Rar')
    if (first == 0x52 && second == 0x61 && third == 0x72) {
      throw ArgumentError('I dati sono già compressi con RAR');
    }
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
