import '../types.dart';

abstract class ICompressionEngine {
  Future<CompressedData> compress(List<int> data);
  Future<List<int>> decompress(CompressedData compressed);
}
