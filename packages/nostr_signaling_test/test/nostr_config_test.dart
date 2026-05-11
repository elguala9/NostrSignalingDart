import 'dart:convert';
import 'dart:io';

import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';

void main() {
  group('NostrConfig.load()', () {
    test('legge un file esistente con keyPair', () async {
      final path = '${Directory.systemTemp.path}\\cfg_load_existing_1.json';
      addTearDown(() => File(path).deleteSync());

      final original = NostrConfig(
        relays: [NostrStandardRelays.damus],
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
      );
      await original.save(path);

      final loaded = await NostrConfig.load(path);

      expect(loaded.relays, [NostrStandardRelays.damus]);
      expect(loaded.keyPair?.privateKey, NostrTestKeys.testPrivateKey1);
      expect(loaded.keyPair?.publicKey, NostrTestKeys.testPublicKey1);
      expect(loaded.collection, defaultEventCallbackCollection);
    });

    test('legge un file esistente senza keyPair', () async {
      final path = '${Directory.systemTemp.path}\\cfg_load_existing_no_kp.json';
      addTearDown(() => File(path).deleteSync());

      final original = NostrConfig(
        relays: [NostrStandardRelays.nos],
      );
      await original.save(path);

      final loaded = await NostrConfig.load(path);

      expect(loaded.relays, [NostrStandardRelays.nos]);
      expect(loaded.keyPair, isNull);
    });

    test('crea file con relays di default se non esiste', () async {
      final path = '${Directory.systemTemp.path}\\cfg_load_auto_1.json';
      addTearDown(() => File(path).deleteSync());

      await NostrConfig.load(path);

      expect(File(path).existsSync(), isTrue);
      final raw = jsonDecode(File(path).readAsStringSync());
      expect(raw['relays'], isA<List>());
      expect(raw['privateKey'], isA<String>());
      expect(raw['publicKey'], isA<String>());
      expect(raw['collection'], defaultEventCallbackCollection);
    });

    test('crea un keyPair valido quando il file non esiste', () async {
      final path = '${Directory.systemTemp.path}\\cfg_load_auto_kp.json';
      addTearDown(() => File(path).deleteSync());

      final config = await NostrConfig.load(path);
      final kp = config.keyPair;

      expect(kp, isNotNull);
      expect(kp!.privateKey.length, 64);
      expect(kp.publicKey.length, 64);
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(kp.privateKey), isTrue);
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(kp.publicKey), isTrue);
      expect(kp.isValid(), isTrue);
    });

    test('crea file con relays di default standard', () async {
      final path = '${Directory.systemTemp.path}\\cfg_load_auto_relays.json';
      addTearDown(() => File(path).deleteSync());

      final config = await NostrConfig.load(path);

      expect(config.relays, unorderedEquals(standardRelays));
    });

    test('il file creato è persistente e ricaricabile', () async {
      final path = '${Directory.systemTemp.path}\\cfg_load_reload.json';
      addTearDown(() => File(path).deleteSync());

      final first = await NostrConfig.load(path);

      final second = await NostrConfig.load(path);

      expect(second.relays, first.relays);
      expect(second.keyPair?.privateKey, first.keyPair?.privateKey);
      expect(second.keyPair?.publicKey, first.keyPair?.publicKey);
      expect(second.collection, first.collection);
    });

    test('usa il path di default se non specificato', () async {
      const path = NostrConfig.defaultConfigPath;
      addTearDown(() => File(path).deleteSync());

      final config = await NostrConfig.load();

      expect(config, isA<NostrConfig>());
    });
  });

  group('NostrConfig.loadSync()', () {
    test('legge un file esistente con keyPair', () {
      final path = '${Directory.systemTemp.path}\\cfg_loadsync_existing.json';
      addTearDown(() => File(path).deleteSync());

      final original = NostrConfig(
        relays: [NostrStandardRelays.damus],
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
      );
      File(path).writeAsStringSync(jsonEncode(original.toJson()));

      final loaded = NostrConfig.loadSync(path);

      expect(loaded.relays, [NostrStandardRelays.damus]);
      expect(loaded.keyPair?.privateKey, NostrTestKeys.testPrivateKey1);
    });

    test('crea file se non esiste', () {
      final path = '${Directory.systemTemp.path}\\cfg_loadsync_auto.json';
      addTearDown(() => File(path).deleteSync());

      final config = NostrConfig.loadSync(path);

      expect(File(path).existsSync(), isTrue);
      expect(config.keyPair, isNotNull);
      expect(config.keyPair!.isValid(), isTrue);
      expect(config.relays, unorderedEquals(standardRelays));
    });

    test('il file creato da loadSync è persistente', () {
      final path = '${Directory.systemTemp.path}\\cfg_loadsync_reload.json';
      addTearDown(() => File(path).deleteSync());

      final first = NostrConfig.loadSync(path);
      final second = NostrConfig.loadSync(path);

      expect(second.keyPair?.privateKey, first.keyPair?.privateKey);
      expect(second.keyPair?.publicKey, first.keyPair?.publicKey);
    });

    test('legge un file senza keyPair', () {
      final path = '${Directory.systemTemp.path}\\cfg_loadsync_no_kp.json';
      addTearDown(() => File(path).deleteSync());

      File(path).writeAsStringSync(jsonEncode({
        'relays': [NostrStandardRelays.damus],
        'collection': 'test_collection',
      }));

      final loaded = NostrConfig.loadSync(path);

      expect(loaded.keyPair, isNull);
      expect(loaded.collection, 'test_collection');
    });
  });

  group('NostrConfig compatibilità', () {
    test('carica un file salvato con keyPair tramite load() e loadSync()', () async {
      final path = '${Directory.systemTemp.path}\\cfg_compat_save.json';
      addTearDown(() => File(path).deleteSync());

      final config = NostrConfig(
        relays: [NostrStandardRelays.damus, NostrStandardRelays.nos],
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey2,
          publicKey: NostrTestKeys.testPublicKey2,
        ),
        collection: 'custom_collection',
      );
      await config.save(path);

      final asyncLoaded = await NostrConfig.load(path);
      final syncLoaded = NostrConfig.loadSync(path);

      expect(asyncLoaded.relays, syncLoaded.relays);
      expect(asyncLoaded.keyPair?.privateKey, syncLoaded.keyPair?.privateKey);
      expect(asyncLoaded.keyPair?.publicKey, syncLoaded.keyPair?.publicKey);
      expect(asyncLoaded.collection, syncLoaded.collection);
    });

    test('carica un file con relays custom', () async {
      final path = '${Directory.systemTemp.path}\\cfg_custom_relays.json';
      addTearDown(() => File(path).deleteSync());

      final customRelays = ['wss://relay.one.com', 'wss://relay.two.com'];
      await NostrConfig(relays: customRelays).save(path);

      final loaded = await NostrConfig.load(path);

      expect(loaded.relays, customRelays);
    });
  });
}
