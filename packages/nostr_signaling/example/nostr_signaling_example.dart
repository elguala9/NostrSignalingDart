import 'package:nostr_signaling/nostr_signaling.dart';

void main() async {
  // ====================================================================
  // Example 1: Simple signaling without compression
  // ====================================================================
  print('=== Example 1: Basic Signaling ===');

  final signaling = NostrSignalingFactory.create(
    pubkey: NostrTestKeys.testPublicKey1,
    privkey: NostrTestKeys.testPrivateKey1,
    relayUrl: NostrTestRelays.damus,
  );

  await signaling.connect();
  print('Connected to relay');

  // Publish raw data
  final eventId = await signaling.publish([1, 2, 3, 4, 5]);
  print('Event published: $eventId');

  // Listen for messages from a peer
  await signaling.subscribe('target_user_id', (id, data) {
    print('Received from $id: $data');
  });

  // Retrieve the last event from a peer
  final lastData = await signaling.retrieveLast('target_user_id');
  print('Last data from peer: $lastData');

  await signaling.disconnect();

  print('');

  // ====================================================================
  // Example 2: Signaling with GZip compression
  // ====================================================================
  print('=== Example 2: With GZip Compression ===');

  final signalingWithCompression =
      NostrSignalingFactory.createWithGzipCompression(
    pubkey: NostrTestKeys.testPublicKey2,
    privkey: NostrTestKeys.testPrivateKey2,
    relayUrl: NostrTestRelays.nos,
  );

  await signalingWithCompression.connect();
  print('Connected to relay with compression');

  // Large data will be compressed automatically before publishing
  final largeData = List<int>.generate(1000, (i) => i % 256);
  final compressedEventId = await signalingWithCompression.publish(largeData);
  print('Compressed event published: $compressedEventId');

  await signalingWithCompression.disconnect();

  print('');

  // ====================================================================
  // Example 3: Using the compression engine directly
  // ====================================================================
  print('=== Example 3: Direct Compression Engine Usage ===');

  final gzipEngine = GzipCompressionEngine();
  final dataToCompress = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  final compressed = await gzipEngine.compress(dataToCompress);
  print('Original size: ${compressed.originalSize} bytes');
  print('Compressed size: ${compressed.compressedSize} bytes');
  print('Ratio: ${compressed.compressionRatio.toStringAsFixed(2)}%');

  final decompressed = await gzipEngine.decompress(compressed);
  print('Decompressed data: $decompressed');

  print('');

  // ====================================================================
  // Example 4: Multi-relay redundancy
  // ====================================================================
  print('=== Example 4: Multi-Relay Redundancy ===');

  final multiRelay = NostrSignalingFactory.createWithMultipleRelays(
    pubkey: NostrTestKeys.testPublicKey3,
    privkey: NostrTestKeys.testPrivateKey3,
    relayUrls: [
      NostrTestRelays.damus,
      NostrTestRelays.nos,
    ],
  );

  await multiRelay.connect();
  print('Connected to multiple relays');

  final multiEventId = await multiRelay.publish([10, 20, 30]);
  print('Event published to all relays: $multiEventId');

  await multiRelay.disconnect();
}
