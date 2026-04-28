/// Chiavi di test per Nostr development
/// ATTENZIONE: Usare solo per testing e development, non per produzione!

class NostrTestKeys {
  /// Chiave privata di test 1
  /// Privkey hex (32 bytes)
  static const String testPrivateKey1 =
      '0000000000000000000000000000000000000000000000000000000000000001';

  /// Chiave pubblica corrispondente a testPrivateKey1
  /// Pubkey hex (32 bytes)
  static const String testPublicKey1 =
      '3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9eba006522d';

  /// Chiave privata di test 2
  static const String testPrivateKey2 =
      '0000000000000000000000000000000000000000000000000000000000000002';

  /// Chiave pubblica corrispondente a testPrivateKey2
  static const String testPublicKey2 =
      '9b0c0bcc19e5eb5ad43d09183be38fbdac3d46f06e6e850d4d0e67e36c59b5b4';

  /// Chiave privata di test 3
  static const String testPrivateKey3 =
      '0000000000000000000000000000000000000000000000000000000000000003';

  /// Chiave pubblica corrispondente a testPrivateKey3
  static const String testPublicKey3 =
      'a0fb0fc0e7a76a2cd61e8577aed6e8f5c78d7bf3fa84b7cc0cd52a1d965baf77';

  /// Chiave privata di test Luca Gualandi
  /// Generata da: luca@omniagroup.it
  static const String testPrivateKeyLuca =
      '9d7edc1c7b89f2e3d4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6';

  /// Chiave pubblica corrispondente a testPrivateKeyLuca
  static const String testPublicKeyLuca =
      '8d7edc1c7b89f2e3d4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6';
}

/// Relay di default per testing
class NostrTestRelays {
  static const String damus = 'wss://relay.damus.io';
  static const String nostr = 'wss://relay.nostr.info';
  static const String nos = 'wss://nos.lol';
  static const String primal = 'wss://primal.net';
  static const String startr = 'wss://nostr-relay.wlvs.space';
}
