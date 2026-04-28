/// Chiavi di test per Nostr development
/// ATTENZIONE: Usare solo per testing e development, non per produzione!

class NostrTestKeys {
  /// Chiave privata di test 1
  /// Privkey hex (32 bytes)
  static const String testPrivateKey1 =
      '0000000000000000000000000000000000000000000000000000000000000001';

  /// Chiave pubblica corrispondente a testPrivateKey1
  /// Pubkey hex (32 bytes) - Corretta derivazione BIP340
  static const String testPublicKey1 =
      '79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798';

  /// Chiave privata di test 2 (random, non-sequential)
  static const String testPrivateKey2 =
      'd624e64db378fe3cd13fa9f562b176a46b3afc837b0ff294b7c4dd41297eb44b';

  /// Chiave pubblica corrispondente a testPrivateKey2
  static const String testPublicKey2 =
      '59f6054fde4d37f43d539f6b128e0116cf30718adff96224291c68ec46dc3aa1';

  /// Chiave privata di test 3 (random, non-sequential)
  static const String testPrivateKey3 =
      '088af2d17d8c507f69bc9d1e727ca3ace683c5d13a453e5489712920afa2e43e';

  /// Chiave pubblica corrispondente a testPrivateKey3
  static const String testPublicKey3 =
      'ffa8f33bc30bee0152260b34f24b850d257b97ceb4ae51ef0157e0a6a9e27d4f';

  /// Chiave privata di test Luca Gualandi
  /// Generata da: luca@omniagroup.it
  static const String testPrivateKeyLuca =
      '009d7edc1c7b89f2e3d4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6';

  /// Chiave pubblica corrispondente a testPrivateKeyLuca
  static const String testPublicKeyLuca =
      'fda9d4784c194d7ac520f915b1d238160e7d24bb51b3db4a5cb64d051f113716';
}

/// Relay di default per testing
class NostrTestRelays {
  static const String damus = 'wss://relay.damus.io';
  static const String nostr = 'wss://relay.nostr.info';
  static const String nos = 'wss://nos.lol';
  static const String primal = 'wss://relay.primal.net';
  static const String startr = 'wss://nostr-relay.wlvs.space';
}
