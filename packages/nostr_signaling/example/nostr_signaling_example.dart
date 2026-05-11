import 'dart:io';

import 'package:nostr_signaling/nostr_signaling.dart';

void main() async {
  // ====================================================================
  // Example 1: Simple signaling without compression
  // ====================================================================
  print('=== Example 1: Basic Signaling ===');

  final signaling = NostrSignalingFactory.create(
    keyPair: NostrKeyPair(
      privateKey: NostrTestKeys.testPrivateKey1,
      publicKey: NostrTestKeys.testPublicKey1,
    ),
    relayUrls: [NostrStandardRelays.damus],
  );

  await signaling.connect();
  print('Connected to relay');

  final eventId = await signaling.publish([1, 2, 3, 4, 5]);
  print('Event published: $eventId');

  await signaling.subscribe('target_user_id', EventCallback((id, data) {
    print('Received from $id: $data');
  }));

  final lastData = await signaling.retrieveLast('target_user_id');
  print('Last data from peer: $lastData');

  await signaling.disconnect();

  print('');

  // ====================================================================
  // Example 2: Signaling with GZip compression
  // ====================================================================
  print('=== Example 2: With GZip Compression ===');

  final signalingWithCompression =
      NostrSignalingFactory.create(
    keyPair: NostrKeyPair(
      privateKey: NostrTestKeys.testPrivateKey2,
      publicKey: NostrTestKeys.testPublicKey2,
    ),
    relayUrls: [NostrStandardRelays.nos],
    useCompression: true,
  );

  await signalingWithCompression.connect();
  print('Connected to relay with compression');

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

  final multiRelay = NostrSignalingFactory.create(
    keyPair: NostrKeyPair(
      privateKey: NostrTestKeys.testPrivateKey3,
      publicKey: NostrTestKeys.testPublicKey3,
    ),
    relayUrls: [
      NostrStandardRelays.damus,
      NostrStandardRelays.nos,
    ],
  );

  await multiRelay.connect();
  print('Connected to multiple relays');

  final multiEventId = await multiRelay.publish([10, 20, 30]);
  print('Event published to all relays: $multiEventId');

  await multiRelay.disconnect();

  print('');

  // ====================================================================
  // Example 5: Initial point — Singleton DI variant
  // ====================================================================
  print('=== Example 5: Initial Point — Singleton DI ===');

  await initialPointNostrSignaling(
    keyPair: NostrKeyPair(
      privateKey: NostrTestKeys.testPrivateKey1,
      publicKey: NostrTestKeys.testPublicKey1,
    ),
    relayUrls: [NostrStandardRelays.damus],
  );

  final fromSingleton = getINostrSignaling();
  print('Retrieved signaling instance: $fromSingleton');

  print('');

  // ====================================================================
  // Example 6: Initial point — Registry variant (multiple instances)
  // ====================================================================
  print('=== Example 6: Initial Point — Registry (multi-instance) ===');

  initialPointNostrSignalingRegistry(
    registryKey: 'alice',
    keyPair: NostrKeyPair(
      privateKey: NostrTestKeys.testPrivateKey1,
      publicKey: NostrTestKeys.testPublicKey1,
    ),
    relayUrls: [NostrStandardRelays.damus],
  );

  initialPointNostrSignalingRegistry(
    registryKey: 'bob',
    keyPair: NostrKeyPair(
      privateKey: NostrTestKeys.testPrivateKey2,
      publicKey: NostrTestKeys.testPublicKey2,
    ),
    relayUrls: [NostrStandardRelays.nos],
  );

  final alice = getINostrSignalingFromRegistry(key: 'alice');
  final bob = getINostrSignalingFromRegistry(key: 'bob');
  print('Alice instance: $alice');
  print('Bob instance: $bob');

  print('');

  // ====================================================================
  // Example 7: Initial point from config file — Singleton
  // ====================================================================
  print('=== Example 7: Initial Point From Config (Singleton) ===');

  final configPath = 'example_config.json';
  await NostrConfig(
    keyPair: NostrKeyPair(
      privateKey: NostrTestKeys.testPrivateKey1,
      publicKey: NostrTestKeys.testPublicKey1,
    ),
    relays: [NostrStandardRelays.damus],
  ).save(configPath);

  await initialPointNostrSignalingFromConfig(configPath: configPath);

  final fromConfigSingleton = getINostrSignaling();
  print('Retrieved from config: $fromConfigSingleton');
  File(configPath).deleteSync();

  print('');

  // ====================================================================
  // Example 8: Initial point from config file — Registry
  // ====================================================================
  print('=== Example 8: Initial Point From Config (Registry) ===');

  await NostrConfig(
    keyPair: NostrKeyPair(
      privateKey: NostrTestKeys.testPrivateKey2,
      publicKey: NostrTestKeys.testPublicKey2,
    ),
  ).save(configPath);

  initialPointNostrSignalingRegistryFromConfig(
    key: 'from_config',
    configPath: configPath,
  );

  final fromConfigRegistry = getINostrSignalingFromRegistry(key: 'from_config');
  print('Retrieved from config registry: $fromConfigRegistry');
  File(configPath).deleteSync();
}
