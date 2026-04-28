import 'package:nostr_signaling/nostr_signaling.dart';

void main() async {
  // === ESEMPIO 1: Signaling semplice senza compressione ===
  print('=== Esempio 1: Signaling semplice ===');

  final signaling = NostrSignalingFactory.create(
    pubkey: NostrTestKeys.testPublicKey1,
    privkey: NostrTestKeys.testPrivateKey1,
    relayUrl: NostrTestRelays.damus,
  );

  await signaling.connect();
  print('Connesso al relay');

  // Pubblica dati raw
  final eventId = await signaling.publish([1, 2, 3, 4, 5]);
  print('Evento pubblicato: $eventId');

  // Ascolta messaggi
  await signaling.subscribe('target_user_id', (id, data) {
    print('Ricevuto da $id: $data');
  });

  await signaling.disconnect();

  print('\n');

  // === ESEMPIO 2: Signaling con compressione GZip ===
  print('=== Esempio 2: Con compressione GZip ===');

  final signalingWithCompression =
      NostrSignalingFactory.createWithGzipCompression(
    pubkey: NostrTestKeys.testPublicKey2,
    privkey: NostrTestKeys.testPrivateKey2,
    relayUrl: NostrTestRelays.nos,
  );

  await signalingWithCompression.connect();
  print('Connesso al relay con compressione');

  // I dati verranno compressi automaticamente
  final largeData = List<int>.generate(1000, (i) => i % 256);
  final compressedEventId = await signalingWithCompression.publish(largeData);
  print('Evento compresso pubblicato: $compressedEventId');

  await signalingWithCompression.disconnect();

  print('\n');

  // === ESEMPIO 3: Compressione custom ===
  print('=== Esempio 3: Compressione custom ===');

  final gzipEngine = GzipCompressionEngine();
  final dataToCompress = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  final compressed = await gzipEngine.compress(dataToCompress);
  print('Dati originali: ${compressed.originalSize} bytes');
  print('Dati compressi: ${compressed.compressedSize} bytes');
  print('Ratio compressione: ${compressed.compressionRatio.toStringAsFixed(2)}%');

  final decompressed = await gzipEngine.decompress(compressed);
  print('Decompresso: $decompressed');
}
