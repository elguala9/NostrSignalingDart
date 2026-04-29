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
