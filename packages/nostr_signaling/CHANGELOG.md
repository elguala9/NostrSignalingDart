## 0.3.0

- `EventCallback` is now a class (not a typedef) with built-in deduplication
  via `work_db` — the same event hash is never processed twice.
- `PayloadHashLength` enum — choose between 32-bit, 64-bit, or full 256-bit
  payload hash to balance collision risk vs. overhead.
- Various test improvements and refactoring.

## 0.2.0

- `NostrConfig` — config file persistence with `load()` / `loadSync()` / `save()`.
- `initialPointNostrSignalingFromConfig()` — singleton initial point that reads
  key pair and relays from a JSON config file (no required parameters).
- `initialPointNostrSignalingRegistryFromConfig()` — registry variant for
  multiple named instances from config files.
- `initialPointNostrSignalingDefault()` and
  `initialPointNostrSignalingRegistryDefault()` now try loading an existing
  config file before falling back to defaults.

## 0.1.0

- Initial release.
- `INostrSignaling` abstract interface for Nostr-based peer signaling.
- `NostrSignalingImpl` concrete implementation with single/multi-relay support.
- `NostrRelayImpl` concrete WebSocket relay implementation via `dart_nostr`.
- `GzipCompressionEngine` with automatic compressed-data detection.
- `NostrSignalingFactory` convenience factory with pre-configured factory methods.
- `NostrKeys` / `NostrKeyPair` key generation, import, and validation utilities.
- `NostrTestKeys` / `NostrTestRelays` constants for testing and development.
- Base64 content encoding for safe transport over Nostr.
- Concurrent publish/subscribe across multiple relays.
