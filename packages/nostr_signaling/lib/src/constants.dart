/// Test-only Nostr key pairs for development and testing.
///
/// WARNING: These keys are publicly known. Never use them in production.
class NostrTestKeys {
  /// Test private key 1 (sequential, hex-encoded, 32 bytes).
  static const String testPrivateKey1 =
      '0000000000000000000000000000000000000000000000000000000000000001';

  /// Public key matching [testPrivateKey1] (BIP340 derivation).
  static const String testPublicKey1 =
      '79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798';

  /// Test private key 2 (random, non-sequential).
  static const String testPrivateKey2 =
      'd624e64db378fe3cd13fa9f562b176a46b3afc837b0ff294b7c4dd41297eb44b';

  /// Public key matching [testPrivateKey2].
  static const String testPublicKey2 =
      '59f6054fde4d37f43d539f6b128e0116cf30718adff96224291c68ec46dc3aa1';

  /// Test private key 3 (random, non-sequential).
  static const String testPrivateKey3 =
      '088af2d17d8c507f69bc9d1e727ca3ace683c5d13a453e5489712920afa2e43e';

  /// Public key matching [testPrivateKey3].
  static const String testPublicKey3 =
      'ffa8f33bc30bee0152260b34f24b850d257b97ceb4ae51ef0157e0a6a9e27d4f';

  /// Test private key for Luca Gualandi.
  static const String testPrivateKeyLuca =
      '009d7edc1c7b89f2e3d4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6';

  /// Public key matching [testPrivateKeyLuca].
  static const String testPublicKeyLuca =
      'fda9d4784c194d7ac520f915b1d238160e7d24bb51b3db4a5cb64d051f113716';
}

/// Well-known Nostr relay URLs for testing and development.
class NostrStandardRelays {
  /// Damus relay: `wss://relay.damus.io`
  static const String damus = 'wss://relay.damus.io';

  /// Nostr.info relay: `wss://relay.nostr.info`
  static const String nostr = 'wss://relay.nostr.info';

  /// Nos.lol relay: `wss://nos.lol`
  static const String nos = 'wss://nos.lol';

  /// Primal relay: `wss://relay.primal.net`
  static const String primal = 'wss://relay.primal.net';

  /// Nostr.net relay: `wss://relay.nostr.net`
  static const String startr = 'wss://relay.nostr.net';

  /// Mostr.pub relay: `wss://relay.mostr.pub`
  static const String band = 'wss://relay.mostr.pub';

  /// Purplepag.es relay: `wss://purplepag.es`
  static const String purple = 'wss://purplepag.es';

  /// Wellorder relay: `wss://nostr-pub.wellorder.net`
  static const String snort = 'wss://nostr-pub.wellorder.net';

  /// Nostr.wine relay: `wss://nostr.wine`
  static const String wine = 'wss://nostr.wine';

  /// Offchain.pub relay: `wss://offchain.pub`
  static const String offchain = 'wss://offchain.pub';
}
