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

    test('throws exception if data is already GZIP compressed', () async {
      final originalData = List<int>.generate(100, (i) => i % 256);
      final compressed = await engine.compress(originalData);

      // Try to compress already compressed data
      expect(
        () => engine.compress(compressed.data),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          allOf([contains('GZIP'), contains('compress: false')]),
        )),
      );
    });

    test('throws exception if data is ZIP compressed', () async {
      // Simulates ZIP file with correct magic number
      final zipData = [0x50, 0x4b, 0x03, 0x04]; // PK\x03\x04

      expect(
        () => engine.compress(zipData),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          allOf([contains('ZIP'), contains('compress: false')]),
        )),
      );
    });

    test('throws exception if data is BZIP2 compressed', () async {
      // Simulates BZIP2 file with correct magic number
      final bzip2Data = [0x42, 0x5a, 0x68]; // BZh

      expect(
        () => engine.compress(bzip2Data),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          allOf([contains('BZIP2'), contains('compress: false')]),
        )),
      );
    });

    test('throws exception if data is 7z compressed', () async {
      // Simulates 7z file with correct magic number
      final data7z = [0x37, 0x7a, 0xbc]; // 7z¼

      expect(
        () => engine.compress(data7z),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          allOf([contains('7z'), contains('compress: false')]),
        )),
      );
    });

    test('throws exception if data is RAR compressed', () async {
      // Simulates RAR file with correct magic number
      final rarData = [0x52, 0x61, 0x72]; // Rar

      expect(
        () => engine.compress(rarData),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          allOf([contains('RAR'), contains('compress: false')]),
        )),
      );
    });

    test('compresses normal data without issues', () async {
      final normalData = [1, 2, 3, 4, 5];

      // Should not throw exception
      final compressed = await engine.compress(normalData);

      expect(compressed.originalSize, equals(5));
      expect(compressed.data, isNotEmpty);
    });
  });
}
