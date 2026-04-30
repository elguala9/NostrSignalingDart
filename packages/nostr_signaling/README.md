# nostr_signaling

[![Dart SDK](https://img.shields.io/badge/dart-%3E%3D3.0.0-blue)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![pub.dev](https://img.shields.io/badge/pub.dev-v0.1.0-orange)](https://pub.dev/packages/nostr_signaling)

A Nostr-based signaling library for Dart. Exchange arbitrary binary data
between Nostr peers, with optional **GZip compression** and **multi-relay
redundancy**.

## Features

- **Nostr signaling** &mdash; publish and subscribe to arbitrary binary data
  over the Nostr protocol.
- **GZip compression** &mdash; reduce payload size automatically; detects and
  rejects already-compressed data.
- **Multi-relay** &mdash; publish/subscribe across multiple Nostr relays for
  reliability and redundancy.
- **Key management** &mdash; generate, import, and validate Nostr key pairs.
- **Pluggable engine** &mdash; implement `ICompressionEngine` to add custom
  compression algorithms.

## Getting started

Add `nostr_signaling` to your `pubspec.yaml`:

```yaml
dependencies:
  nostr_signaling: ^0.1.0
```

## Usage

### Basic signaling (no compression)

```dart
import 'package:nostr_signaling/nostr_signaling.dart';

void main() async {
  final signaling = NostrSignalingFactory.create(
    pubkey: 'your-public-key-hex',
    privkey: 'your-private-key-hex',
  );

  await signaling.connect();

  // Publish raw bytes to a peer
  final eventId = await signaling.publish([1, 2, 3, 4, 5]);

  // Subscribe to messages from a peer
  await signaling.subscribe('peer-pubkey-hex', (id, data) {
    print('Received from $id: $data');
  });

  await signaling.disconnect();
}
```

### With GZip compression

```dart
final signaling = NostrSignalingFactory.createWithGzipCompression(
  pubkey: 'your-public-key-hex',
  privkey: 'your-private-key-hex',
);

await signaling.connect();

// Large data is compressed automatically before publishing
final largeData = List<int>.generate(10000, (i) => i % 256);
await signaling.publish(largeData);
```

### Key generation

```dart
// Generate a new random key pair
final keyPair = NostrKeys.generate();
print('Private: ${keyPair.privateKey}');
print('Public:  ${keyPair.publicKey}');

// Import from an existing private key
final imported = NostrKeys.fromPrivateKeyHex('your-private-key-hex');

// Import and validate a full key pair
final validated = NostrKeys.fromHex(
  privateKeyHex: 'private-key-hex',
  publicKeyHex: 'public-key-hex',
);
```

### Custom compression engine

```dart
class MyCompressionEngine implements ICompressionEngine {
  @override
  Future<CompressedData> compress(List<int> data) async {
    // Your custom compression logic
    return CompressedData(
      originalSize: data.length,
      compressedSize: data.length,
      compressionRatio: 0,
      data: data,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<int>> decompress(CompressedData compressed) async {
    // Your custom decompression logic
    return compressed.data;
  }
}

final signaling = NostrSignalingFactory.create(
  pubkey: 'pubkey',
  privkey: 'privkey',
  useCompression: true,
  compressionEngine: MyCompressionEngine(),
);
```

### Multi-relay redundancy

```dart
final signaling = NostrSignalingFactory.createWithMultipleRelays(
  pubkey: 'pubkey',
  privkey: 'privkey',
  relayUrls: [
    'wss://relay.damus.io',
    'wss://nos.lol',
    'wss://relay.primal.net',
  ],
);
```

## Config file

`NostrConfig` persists relay URLs and key pair to a JSON file on disk.

```dart
// Save config
final config = NostrConfig(
  keyPair: myKeyPair,
  relays: ['wss://relay.damus.io'],
);
await config.save();                // → nostr_config.json

// Load config
final loaded = await NostrConfig.load();      // async
final loadedSync = NostrConfig.loadSync();    // sync
```

### Initial point from config (no required parameters)

Loads key pair and relays from the config file automatically.
Throws `StateError` if the file is missing or has no key pair.

```dart
// Singleton DI — no parameters needed
await initialPointNostrSignalingFromConfig();

final signaling = getINostrSignaling();

// Registry DI — supports multiple named instances
initialPointNostrSignalingRegistryFromConfig(key: 'alice');
initialPointNostrSignalingRegistryFromConfig(key: 'bob');
```

Both accept an optional `configPath` (default: `nostr_config.json`).

## API overview

| Class / Interface | Description |
|---|---|
| `INostrSignaling` | Abstract signaling interface (connect, publish, subscribe, etc.) |
| `NostrSignalingImpl` | Concrete signaling implementation |
| `INostrRelay` | Abstract relay interface |
| `NostrRelayImpl` | Concrete WebSocket relay via dart_nostr |
| `ICompressionEngine` | Pluggable compression interface |
| `GzipCompressionEngine` | GZip compression with auto-detection |
| `NostrConfig` | Config file persistence (relays + key pair) |
| `NostrSignalingFactory` | Factory with pre-configured factory methods |
| `NostrKeys` / `NostrKeyPair` | Key generation, import, and validation |
| `CompressedData` | Compression metadata (original size, ratio, timestamp) |
| `NostrTestKeys` / `NostrTestRelays` | Test constants |

## Event kinds

| Kind | Description |
|---|---|
| `1000` | Compressed payload (base64-encoded) |
| `1001` | Raw payload (base64-encoded) |

## Additional information

- [Repository](https://github.com/lgualandi/NostrSignaling)
- [Issue tracker](https://github.com/lgualandi/NostrSignaling/issues)
- **License:** MIT
