import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';

void main() {
  group('GzipCompressionEngine', () {
    late GzipCompressionEngine engine;

    setUp(() {
      engine = GzipCompressionEngine();
    });

    test('compress riduce la dimensione dei dati', () async {
      final originalData = List<int>.generate(1000, (i) => i % 256);

      final compressed = await engine.compress(originalData);

      expect(compressed.originalSize, equals(1000));
      expect(compressed.compressedSize, lessThan(1000));
      expect(compressed.compressionRatio, greaterThan(0));
    });

    test('decompress ripristina i dati originali', () async {
      final originalData = List<int>.generate(100, (i) => i % 256);

      final compressed = await engine.compress(originalData);
      final decompressed = await engine.decompress(compressed);

      expect(decompressed, equals(originalData));
    });

    test('gestisce dati vuoti', () async {
      final emptyData = <int>[];

      final compressed = await engine.compress(emptyData);

      expect(compressed.originalSize, equals(0));
      expect(compressed.data, isNotEmpty);
    });

    test('calcola correttamente il compression ratio', () async {
      final data = List<int>.generate(500, (i) => 42); // Dati altamente ripetitivi

      final compressed = await engine.compress(data);

      expect(compressed.compressionRatio, greaterThan(50)); // Dovrebbe comprimere molto bene
    });

    test('timestamp è impostato correttamente', () async {
      final data = [1, 2, 3];
      final beforeTime = DateTime.now().millisecondsSinceEpoch;

      final compressed = await engine.compress(data);

      final afterTime = DateTime.now().millisecondsSinceEpoch;

      expect(compressed.timestamp, greaterThanOrEqualTo(beforeTime));
      expect(compressed.timestamp, lessThanOrEqualTo(afterTime));
    });
  });
}
