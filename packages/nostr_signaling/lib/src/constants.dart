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

  /// Chiave privata di test 2
  static const String testPrivateKey2 =
      '0000000000000000000000000000000000000000000000000000000000000002';

  /// Chiave pubblica corrispondente a testPrivateKey2
  static const String testPublicKey2 =
      'c6047f9441ed7d6d3045406e95c07cd85c778e4b8cef3ca7abac09b95c709ee5';

  /// Chiave privata di test 3
  static const String testPrivateKey3 =
      '0000000000000000000000000000000000000000000000000000000000000003';

  /// Chiave pubblica corrispondente a testPrivateKey3
  static const String testPublicKey3 =
      'f9308a019258c31049344f85f89d5229b531c845836f99b08601f113bce036f9';

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
  static const String primal = 'wss://primal.net';
  static const String startr = 'wss://nostr-relay.wlvs.space';
}
