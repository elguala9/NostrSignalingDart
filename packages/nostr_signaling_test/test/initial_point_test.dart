import 'dart:io';

import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:singleton_manager/singleton_manager.dart';
import 'package:test/test.dart';

void main() {
  final testKeyPair1 = NostrKeyPair(
    privateKey: NostrTestKeys.testPrivateKey1,
    publicKey: NostrTestKeys.testPublicKey1,
  );

  final testKeyPair2 = NostrKeyPair(
    privateKey: NostrTestKeys.testPrivateKey2,
    publicKey: NostrTestKeys.testPublicKey2,
  );

  tearDown(() {
    SingletonManager.instance.destroyAll();
    RegistryAccess.destroyAll();
  });

  group('initialPointNostrSignaling (Singleton DI)', () {
    test('creates and registers a NostrSignalingImpl', () async {
      await initialPointNostrSignaling(keyPair: testKeyPair1);

      expect(SingletonDIAccess.exists<INostrSignaling>(), isTrue);
      final instance = SingletonDIAccess.get<INostrSignaling>();
      expect(instance, isA<INostrSignaling>());
      expect(instance, isA<NostrSignalingImpl>());
    });

    test('registers instance with correct key pair', () async {
      await initialPointNostrSignaling(keyPair: testKeyPair1);

      final instance =
          SingletonDIAccess.get<INostrSignaling>() as NostrSignalingImpl;
      expect(instance.pubkey, equals(NostrTestKeys.testPublicKey1));
      expect(instance.privkey, equals(NostrTestKeys.testPrivateKey1));
    });

    test('getINostrSignaling retrieves the registered instance', () async {
      await initialPointNostrSignaling(keyPair: testKeyPair1);

      final instance = getINostrSignaling();
      expect(instance, isA<INostrSignaling>());
      expect(instance, isA<NostrSignalingImpl>());
    });

    test('getINostrSignaling returns instance with correct key pair', () async {
      await initialPointNostrSignaling(keyPair: testKeyPair1);

      final instance = getINostrSignaling() as NostrSignalingImpl;
      expect(instance.pubkey, equals(NostrTestKeys.testPublicKey1));
    });

    test('replaces previous instance on second call', () async {
      await initialPointNostrSignaling(keyPair: testKeyPair1);

      final instance1 =
          SingletonDIAccess.get<INostrSignaling>() as NostrSignalingImpl;
      expect(instance1.pubkey, equals(NostrTestKeys.testPublicKey1));

      await initialPointNostrSignaling(keyPair: testKeyPair2);

      final instance2 =
          SingletonDIAccess.get<INostrSignaling>() as NostrSignalingImpl;
      expect(instance2.pubkey, equals(NostrTestKeys.testPublicKey2));
    });

    test('works with default relay URL (single relay)', () async {
      await initialPointNostrSignaling(keyPair: testKeyPair1);

      expect(SingletonDIAccess.exists<INostrSignaling>(), isTrue);
    });

    test('works with custom relay URLs', () async {
      await initialPointNostrSignaling(
        keyPair: testKeyPair1,
        relayUrls: ['wss://relay.custom.com'],
      );

      expect(SingletonDIAccess.exists<INostrSignaling>(), isTrue);
    });

    test('works with multiple custom relay URLs', () async {
      await initialPointNostrSignaling(
        keyPair: testKeyPair1,
        relayUrls: [
          'wss://relay.one.com',
          'wss://relay.two.com',
          'wss://relay.three.com',
        ],
      );

      expect(SingletonDIAccess.exists<INostrSignaling>(), isTrue);
    });

    test('works with compression enabled', () async {
      await initialPointNostrSignaling(
        keyPair: testKeyPair1,
        useCompression: true,
      );

      expect(SingletonDIAccess.exists<INostrSignaling>(), isTrue);
    });

    test('uses GzipCompressionEngine when compression is enabled', () async {
      await initialPointNostrSignaling(
        keyPair: testKeyPair1,
        useCompression: true,
      );

      final instance = SingletonDIAccess.get<INostrSignaling>();
      expect(instance, isA<INostrSignaling>());
    });

    test('works with custom compression engine', () async {
      final engine = GzipCompressionEngine();
      await initialPointNostrSignaling(
        keyPair: testKeyPair1,
        useCompression: true,
        compressionEngine: engine,
      );

      expect(SingletonDIAccess.exists<INostrSignaling>(), isTrue);
    });

    test('works without compression engine when compression is disabled',
        () async {
      await initialPointNostrSignaling(
        keyPair: testKeyPair1,
        useCompression: false,
      );

      expect(SingletonDIAccess.exists<INostrSignaling>(), isTrue);
    });

    test(
        'does not register in RegistryAccess (only in SingletonDIAccess)',
        () async {
      await initialPointNostrSignaling(keyPair: testKeyPair1);

      expect(RegistryAccess.contains<INostrSignaling>('default'), isFalse);
    });

    test('accepts onEventCallbacks parameter', () async {
      final callback = EventCallback((id, data) {});
      await initialPointNostrSignaling(
        keyPair: testKeyPair1,
        onEventCallbacks: {'target-user': callback},
      );

      expect(SingletonDIAccess.exists<INostrSignaling>(), isTrue);
    });

    test('accepts onEventCallbacks with multiple entries', () async {
      final callback1 = EventCallback((id, data) {});
      final callback2 = EventCallback((id, data) {});
      await initialPointNostrSignaling(
        keyPair: testKeyPair1,
        onEventCallbacks: {
          'user-one': callback1,
          'user-two': callback2,
        },
      );

      expect(SingletonDIAccess.exists<INostrSignaling>(), isTrue);
    });
  });

  group('initialPointNostrSignalingDefault (Singleton convenience)', () {
    test('creates and registers using default config relays', () async {
      await initialPointNostrSignalingDefault(keyPair: testKeyPair1);

      expect(SingletonDIAccess.exists<INostrSignaling>(), isTrue);
    });

    test('registers instance with correct key pair', () async {
      await initialPointNostrSignalingDefault(keyPair: testKeyPair1);

      final instance =
          SingletonDIAccess.get<INostrSignaling>() as NostrSignalingImpl;
      expect(instance.pubkey, equals(NostrTestKeys.testPublicKey1));
      expect(instance.privkey, equals(NostrTestKeys.testPrivateKey1));
    });

    test('getINostrSignaling retrieves the registered instance', () async {
      await initialPointNostrSignalingDefault(keyPair: testKeyPair1);

      final instance = getINostrSignaling();
      expect(instance, isA<INostrSignaling>());
    });

    test('accepts onEventCallbacks parameter', () async {
      final callback = EventCallback((id, data) {});
      await initialPointNostrSignalingDefault(
        keyPair: testKeyPair1,
        onEventCallbacks: {'target-user': callback},
      );

      expect(SingletonDIAccess.exists<INostrSignaling>(), isTrue);
    });
  });

  group('getINostrSignaling (Singleton retrieval)', () {
    test('returns a NostrSignalingImpl', () async {
      await initialPointNostrSignaling(keyPair: testKeyPair1);

      final instance = getINostrSignaling();
      expect(instance, isA<NostrSignalingImpl>());
    });

    test('returns INostrSignaling interface type', () async {
      await initialPointNostrSignaling(keyPair: testKeyPair1);

      final instance = getINostrSignaling();
      expect(instance, isA<INostrSignaling>());
    });
  });

  group('initialPointNostrSignalingRegistry (Registry DI)', () {
    test('registers with default key', () {
      initialPointNostrSignalingRegistry(keyPair: testKeyPair1);

      expect(RegistryAccess.contains<INostrSignaling>('default'), isTrue);
      final instance = RegistryAccess.getInstance<INostrSignaling>('default');
      expect(instance, isA<INostrSignaling>());
    });

    test('registers with custom registry key', () {
      initialPointNostrSignalingRegistry(
        registryKey: 'custom-key',
        keyPair: testKeyPair1,
      );

      expect(RegistryAccess.contains<INostrSignaling>('custom-key'), isTrue);
    });

    test('registers instance with correct key pair', () {
      initialPointNostrSignalingRegistry(
        registryKey: 'test',
        keyPair: testKeyPair1,
      );

      final instance =
          RegistryAccess.getInstance<INostrSignaling>('test') as NostrSignalingImpl;
      expect(instance.pubkey, equals(NostrTestKeys.testPublicKey1));
      expect(instance.privkey, equals(NostrTestKeys.testPrivateKey1));
    });

    test('supports multiple named instances', () {
      initialPointNostrSignalingRegistry(
        registryKey: 'alice',
        keyPair: testKeyPair1,
      );
      initialPointNostrSignalingRegistry(
        registryKey: 'bob',
        keyPair: testKeyPair2,
      );

      expect(RegistryAccess.contains<INostrSignaling>('alice'), isTrue);
      expect(RegistryAccess.contains<INostrSignaling>('bob'), isTrue);

      final alice =
          RegistryAccess.getInstance<INostrSignaling>('alice') as NostrSignalingImpl;
      final bob =
          RegistryAccess.getInstance<INostrSignaling>('bob') as NostrSignalingImpl;

      expect(alice.pubkey, equals(NostrTestKeys.testPublicKey1));
      expect(bob.pubkey, equals(NostrTestKeys.testPublicKey2));
    });

    test('different keys return different instances', () {
      initialPointNostrSignalingRegistry(
        registryKey: 'alice',
        keyPair: testKeyPair1,
      );
      initialPointNostrSignalingRegistry(
        registryKey: 'bob',
        keyPair: testKeyPair2,
      );

      final alice = RegistryAccess.getInstance<INostrSignaling>('alice');
      final bob = RegistryAccess.getInstance<INostrSignaling>('bob');

      expect(identical(alice, bob), isFalse);
    });

    test('works with custom relay URLs', () {
      initialPointNostrSignalingRegistry(
        registryKey: 'custom_relay',
        keyPair: testKeyPair1,
        relayUrls: ['wss://relay.custom.com'],
      );

      expect(
        RegistryAccess.contains<INostrSignaling>('custom_relay'),
        isTrue,
      );
    });

    test('works with compression enabled', () {
      initialPointNostrSignalingRegistry(
        registryKey: 'compressed',
        keyPair: testKeyPair1,
        useCompression: true,
      );

      expect(RegistryAccess.contains<INostrSignaling>('compressed'), isTrue);
    });

    test('works with custom compression engine', () {
      final engine = GzipCompressionEngine();
      initialPointNostrSignalingRegistry(
        registryKey: 'custom_engine',
        keyPair: testKeyPair1,
        useCompression: true,
        compressionEngine: engine,
      );

      expect(
        RegistryAccess.contains<INostrSignaling>('custom_engine'),
        isTrue,
      );
    });

    test('does not register in SingletonDIAccess (only in RegistryAccess)',
        () {
      initialPointNostrSignalingRegistry(keyPair: testKeyPair1);

      expect(SingletonDIAccess.exists<INostrSignaling>(), isFalse);
    });

    test('getINostrSignalingFromRegistry retrieves with default key', () {
      initialPointNostrSignalingRegistry(keyPair: testKeyPair1);

      final instance = getINostrSignalingFromRegistry();
      expect(instance, isA<INostrSignaling>());
    });

    test('getINostrSignalingFromRegistry retrieves with custom key', () {
      initialPointNostrSignalingRegistry(
        registryKey: 'my-key',
        keyPair: testKeyPair1,
      );

      final instance = getINostrSignalingFromRegistry(key: 'my-key');
      expect(instance, isA<INostrSignaling>());
    });

    test('getINostrSignalingFromRegistry returns correct type', () {
      initialPointNostrSignalingRegistry(keyPair: testKeyPair1);

      final instance = getINostrSignalingFromRegistry();
      expect(instance, isA<NostrSignalingImpl>());
    });

    test('getINostrSignalingFromRegistry preserves key pair', () {
      initialPointNostrSignalingRegistry(keyPair: testKeyPair1);

      final instance =
          getINostrSignalingFromRegistry() as NostrSignalingImpl;
      expect(instance.pubkey, equals(NostrTestKeys.testPublicKey1));
    });

    test('accepts onEventCallbacks parameter', () {
      final callback = EventCallback((id, data) {});
      initialPointNostrSignalingRegistry(
        keyPair: testKeyPair1,
        onEventCallbacks: {'target-user': callback},
      );

      expect(RegistryAccess.contains<INostrSignaling>('default'), isTrue);
    });

    test('accepts onEventCallbacks with multiple entries', () {
      final callback1 = EventCallback((id, data) {});
      final callback2 = EventCallback((id, data) {});
      initialPointNostrSignalingRegistry(
        keyPair: testKeyPair1,
        onEventCallbacks: {
          'user-one': callback1,
          'user-two': callback2,
        },
      );

      expect(RegistryAccess.contains<INostrSignaling>('default'), isTrue);
    });
  });

  group('initialPointNostrSignalingRegistryDefault (Registry convenience)',
      () {
    test('registers with default key using config relays', () {
      initialPointNostrSignalingRegistryDefault(keyPair: testKeyPair1);

      expect(RegistryAccess.contains<INostrSignaling>('default'), isTrue);
      final instance = RegistryAccess.getInstance<INostrSignaling>('default');
      expect(instance, isA<INostrSignaling>());
    });

    test('registers with custom key', () {
      initialPointNostrSignalingRegistryDefault(
        key: 'custom-key',
        keyPair: testKeyPair1,
      );

      expect(RegistryAccess.contains<INostrSignaling>('custom-key'), isTrue);
    });

    test('registers instance with correct key pair', () {
      initialPointNostrSignalingRegistryDefault(keyPair: testKeyPair1);

      final instance =
          RegistryAccess.getInstance<INostrSignaling>('default') as NostrSignalingImpl;
      expect(instance.pubkey, equals(NostrTestKeys.testPublicKey1));
    });

    test('getINostrSignalingFromRegistry retrieves the instance', () {
      initialPointNostrSignalingRegistryDefault(keyPair: testKeyPair1);

      final instance = getINostrSignalingFromRegistry();
      expect(instance, isA<INostrSignaling>());
    });

    test('accepts onEventCallbacks parameter', () {
      final callback = EventCallback((id, data) {});
      initialPointNostrSignalingRegistryDefault(
        keyPair: testKeyPair1,
        onEventCallbacks: {'target-user': callback},
      );

      expect(RegistryAccess.contains<INostrSignaling>('default'), isTrue);
    });
  });

  group('getINostrSignalingFromRegistry (Registry retrieval)', () {
    test('returns NostrSignalingImpl', () {
      initialPointNostrSignalingRegistry(keyPair: testKeyPair1);

      final instance = getINostrSignalingFromRegistry();
      expect(instance, isA<NostrSignalingImpl>());
    });

    test('returns INostrSignaling interface type', () {
      initialPointNostrSignalingRegistry(keyPair: testKeyPair1);

      final instance = getINostrSignalingFromRegistry();
      expect(instance, isA<INostrSignaling>());
    });
  });

  group('Error cases', () {
    test('duplicate registry key throws DuplicateRegistrationError', () {
      initialPointNostrSignalingRegistry(
        registryKey: 'dup',
        keyPair: testKeyPair1,
      );

      expect(
        () => initialPointNostrSignalingRegistry(
          registryKey: 'dup',
          keyPair: testKeyPair1,
        ),
        throwsA(isA<DuplicateRegistrationError>()),
      );
    });

    test('getINostrSignalingFromRegistry with unregistered key throws',
        () {
      expect(
        () => getINostrSignalingFromRegistry(key: 'nonexistent'),
        throwsA(isA<RegistryNotFoundError>()),
      );
    });

    test('getINostrSignaling without prior registration throws', () {
      expect(
        getINostrSignaling,
        throwsA(isA<StateError>()),
      );
    });

    test('SingletonDIAccess.get without prior registration throws', () {
      expect(
        () => SingletonDIAccess.get<INostrSignaling>(),
        throwsA(isA<StateError>()),
      );
    });

    test('empty relay list throws ArgumentError', () async {
      expect(
        () => NostrRelayList([]),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('initialPointNostrSignalingFromConfig (Singleton from config)', () {
    var counter = 0;

    String tempPath() {
      counter++;
      return '${Directory.systemTemp.path}\\nostr_test_config_$counter.json';
    }

    tearDown(() {
      SingletonManager.instance.destroyAll();
      RegistryAccess.destroyAll();
    });

    test('loads keyPair from config file and registers signaling', () async {
      final path = tempPath();
      addTearDown(() {
        if (File(path).existsSync()) File(path).deleteSync();
      });

      await NostrConfig(keyPair: testKeyPair1).save(path);
      await initialPointNostrSignalingFromConfig(configPath: path);

      expect(SingletonDIAccess.exists<INostrSignaling>(), isTrue);
      final instance =
          SingletonDIAccess.get<INostrSignaling>() as NostrSignalingImpl;
      expect(instance.pubkey, equals(NostrTestKeys.testPublicKey1));
      expect(instance.privkey, equals(NostrTestKeys.testPrivateKey1));
    });

    test('uses relays from config file', () async {
      final path = tempPath();
      addTearDown(() {
        if (File(path).existsSync()) File(path).deleteSync();
      });

      final customRelays = ['wss://relay.custom.com'];
      await NostrConfig(relays: customRelays, keyPair: testKeyPair1).save(path);
      await initialPointNostrSignalingFromConfig(configPath: path);

      expect(SingletonDIAccess.exists<INostrSignaling>(), isTrue);
    });

    test('getINostrSignaling retrieves instance loaded from config', () async {
      final path = tempPath();
      addTearDown(() {
        if (File(path).existsSync()) File(path).deleteSync();
      });

      await NostrConfig(keyPair: testKeyPair1).save(path);
      await initialPointNostrSignalingFromConfig(configPath: path);

      final instance = getINostrSignaling();
      expect(instance, isA<INostrSignaling>());
    });

    test('throws StateError when config file does not exist', () async {
      final path = '${Directory.systemTemp.path}\\nostr_nonexistent_$counter.json';

      await expectLater(
        () => initialPointNostrSignalingFromConfig(configPath: path),
        throwsA(isA<StateError>()),
      );
    });

    test('throws StateError when config has no keyPair', () async {
      final path = tempPath();
      addTearDown(() {
        if (File(path).existsSync()) File(path).deleteSync();
      });

      await NostrConfig().save(path);

      await expectLater(
        () => initialPointNostrSignalingFromConfig(configPath: path),
        throwsA(isA<StateError>()),
      );
    });

    test('accepts onEventCallbacks parameter', () async {
      final path = tempPath();
      addTearDown(() {
        if (File(path).existsSync()) File(path).deleteSync();
      });

      final callback = EventCallback((id, data) {});
      await NostrConfig(keyPair: testKeyPair1).save(path);
      await initialPointNostrSignalingFromConfig(
        configPath: path,
        onEventCallbacks: {'target-user': callback},
      );

      expect(SingletonDIAccess.exists<INostrSignaling>(), isTrue);
    });
  });

  group('initialPointNostrSignalingRegistryFromConfig (Registry from config)',
      () {
    var counter = 0;

    String tempPath() {
      counter++;
      return '${Directory.systemTemp.path}\\nostr_test_reg_config_$counter.json';
    }

    tearDown(() {
      SingletonManager.instance.destroyAll();
      RegistryAccess.destroyAll();
    });

    test('loads keyPair from config file and registers signaling', () async {
      final path = tempPath();
      addTearDown(() {
        if (File(path).existsSync()) File(path).deleteSync();
      });

      await NostrConfig(keyPair: testKeyPair1).save(path);
      initialPointNostrSignalingRegistryFromConfig(configPath: path);

      expect(RegistryAccess.contains<INostrSignaling>('default'), isTrue);
      final instance =
          RegistryAccess.getInstance<INostrSignaling>('default') as NostrSignalingImpl;
      expect(instance.pubkey, equals(NostrTestKeys.testPublicKey1));
      expect(instance.privkey, equals(NostrTestKeys.testPrivateKey1));
    });

    test('registers with custom registry key', () async {
      final path = tempPath();
      addTearDown(() {
        if (File(path).existsSync()) File(path).deleteSync();
      });

      await NostrConfig(keyPair: testKeyPair1).save(path);
      initialPointNostrSignalingRegistryFromConfig(
        key: 'my-key',
        configPath: path,
      );

      expect(RegistryAccess.contains<INostrSignaling>('my-key'), isTrue);
    });

    test('uses relays from config file', () async {
      final path = tempPath();
      addTearDown(() {
        if (File(path).existsSync()) File(path).deleteSync();
      });

      final customRelays = ['wss://relay.custom.com'];
      await NostrConfig(relays: customRelays, keyPair: testKeyPair1).save(path);
      initialPointNostrSignalingRegistryFromConfig(configPath: path);

      expect(RegistryAccess.contains<INostrSignaling>('default'), isTrue);
    });

    test('getINostrSignalingFromRegistry retrieves instance loaded from config',
        () async {
      final path = tempPath();
      addTearDown(() {
        if (File(path).existsSync()) File(path).deleteSync();
      });

      await NostrConfig(keyPair: testKeyPair1).save(path);
      initialPointNostrSignalingRegistryFromConfig(configPath: path);

      final instance = getINostrSignalingFromRegistry();
      expect(instance, isA<INostrSignaling>());
    });

    test('throws StateError when config file does not exist', () {
      final path =
          '${Directory.systemTemp.path}\\nostr_nonexistent_reg_$counter.json';

      expect(
        () => initialPointNostrSignalingRegistryFromConfig(configPath: path),
        throwsA(isA<StateError>()),
      );
    });

    test('throws StateError when config has no keyPair', () async {
      final path = tempPath();
      addTearDown(() {
        if (File(path).existsSync()) File(path).deleteSync();
      });

      await NostrConfig().save(path);

      expect(
        () => initialPointNostrSignalingRegistryFromConfig(configPath: path),
        throwsA(isA<StateError>()),
      );
    });

    test('accepts onEventCallbacks parameter', () async {
      final path = tempPath();
      addTearDown(() {
        if (File(path).existsSync()) File(path).deleteSync();
      });

      final callback = EventCallback((id, data) {});
      await NostrConfig(keyPair: testKeyPair1).save(path);
      initialPointNostrSignalingRegistryFromConfig(
        configPath: path,
        onEventCallbacks: {'target-user': callback},
      );

      expect(RegistryAccess.contains<INostrSignaling>('default'), isTrue);
    });
  });
}
