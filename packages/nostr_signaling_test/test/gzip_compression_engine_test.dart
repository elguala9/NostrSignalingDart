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

    test('lancia eccezione se i dati sono già gzippati', () async {
      final originalData = List<int>.generate(100, (i) => i % 256);
      final compressed = await engine.compress(originalData);

      // Prova a comprimere dati già compressi
      expect(
        () => engine.compress(compressed.data),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('GZIP'),
        )),
      );
    });

    test('lancia eccezione se i dati sono zippati (ZIP)', () async {
      // Simula un file ZIP con magic number corretto
      final zipData = [0x50, 0x4b, 0x03, 0x04]; // PK\x03\x04

      expect(
        () => engine.compress(zipData),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('ZIP'),
        )),
      );
    });

    test('lancia eccezione se i dati sono compressi con BZIP2', () async {
      // Simula un file BZIP2 con magic number corretto
      final bzip2Data = [0x42, 0x5a, 0x68]; // BZh

      expect(
        () => engine.compress(bzip2Data),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('BZIP2'),
        )),
      );
    });

    test('lancia eccezione se i dati sono compressi con 7z', () async {
      // Simula un file 7z con magic number corretto
      final data7z = [0x37, 0x7a, 0xbc]; // 7z¼

      expect(
        () => engine.compress(data7z),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('7z'),
        )),
      );
    });

    test('lancia eccezione se i dati sono compressi con RAR', () async {
      // Simula un file RAR con magic number corretto
      final rarData = [0x52, 0x61, 0x72]; // Rar

      expect(
        () => engine.compress(rarData),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('RAR'),
        )),
      );
    });

    test('comprime dati normali senza problemi', () async {
      final normalData = [1, 2, 3, 4, 5];

      // Non dovrebbe lanciare eccezione
      final compressed = await engine.compress(normalData);

      expect(compressed.originalSize, equals(5));
      expect(compressed.data, isNotEmpty);
    });
  });
}
