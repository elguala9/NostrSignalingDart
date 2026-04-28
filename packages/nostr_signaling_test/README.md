# Nostr Signaling Test Package

Test suite completa per la libreria `nostr_signaling`.

## Struttura dei Test

- **`constants_test.dart`** — Test per le chiavi di test e i relay
- **`gzip_compression_engine_test.dart`** — Test per la compressione GZip
- **`interfaces_test.dart`** — Test per le interfacce Nostr
- **`nostr_signaling_factory_test.dart`** — Test per la factory
- **`nostr_signaling_impl_test.dart`** — Test per l'implementazione di signaling

## Come eseguire i test

### Eseguire tutti i test
```bash
dart test
```

### Eseguire un singolo test file
```bash
dart test test/constants_test.dart
```

### Eseguire test con verbose output
```bash
dart test --verbose
```

### Generare coverage report
```bash
dart test --coverage=coverage
dart pub global activate coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info
```

## Chiavi di Test

Il package include chiavi di test pre-generate in `lib/src/constants.dart`:

- **testPrivateKey1 / testPublicKey1** — Coppia chiavi di test 1
- **testPrivateKey2 / testPublicKey2** — Coppia chiavi di test 2
- **testPrivateKey3 / testPublicKey3** — Coppia chiavi di test 3
- **testPrivateKeyLuca / testPublicKeyLuca** — Coppia chiavi per Luca Gualandi

## Relay di Test

Relay pre-configurati in `lib/src/constants.dart`:

- `NostrTestRelays.damus` — wss://relay.damus.io
- `NostrTestRelays.nostr` — wss://relay.nostr.info
- `NostrTestRelays.nos` — wss://nos.lol
- `NostrTestRelays.primal` — wss://primal.net
- `NostrTestRelays.startr` — wss://nostr-relay.wlvs.space

## Note Importanti

⚠️ **Queste chiavi sono SOLO per testing!** Non usare per produzione.

I test utilizzano mock objects per evitare connessioni reali ai relay durante l'esecuzione.
