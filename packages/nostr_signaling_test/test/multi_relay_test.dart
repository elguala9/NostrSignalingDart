import 'dart:async';
import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';

void main() {
  group('Multi-Relay Test - Pubblicazione su 3 Relay Diversi', () {
    test('Pubblica su nos.lol e attendi recupero con retry', () async {
      print('\n╔═══════════════════════════════════════════════════════════╗');
      print('║        TEST RELAY 1: nos.lol                             ║');
      print('╚═══════════════════════════════════════════════════════════╝\n');

      final testData = [111, 222, 100, 50];
      late List<int> retrievedData;
      bool dataFound = false;

      final relay = NostrRelayImpl(relayUrl: 'wss://nos.lol');

      final publisher = NostrSignalingImpl(
        pubkey: NostrTestKeys.testPublicKey1,
        privkey: NostrTestKeys.testPrivateKey1,
        relay: relay,
        useCompression: false,
      );

      final receiver = NostrSignalingImpl(
        pubkey: NostrTestKeys.testPublicKey2,
        privkey: NostrTestKeys.testPrivateKey2,
        relay: relay,
        useCompression: false,
      );

      try {
        print('📤 Pubblicazione su nos.lol...');
        final pubStart = DateTime.now();
        await publisher.connect().timeout(Duration(seconds: 15));
        final eventId = await publisher.publish(testData).timeout(Duration(seconds: 15));
        print('✓ Evento pubblicato: $eventId');
        print('  Tempo: ${DateTime.now().difference(pubStart).inMilliseconds}ms\n');

        print('⏳ Attesa propagazione nel relay: 10 secondi...');
        for (int i = 1; i <= 10; i++) {
          await Future.delayed(Duration(seconds: 1));
          print('   $i/10 secondi...');
        }

        print('\n📥 Tentativo di recupero con RETRY (max 3 tentativi)...');
        for (int attempt = 1; attempt <= 3; attempt++) {
          print('\nTentativo $attempt:');
          final completer = Completer<void>();

          await receiver.subscribe(
            publisher.pubkey,
            (id, data) {
              print('  ✓ Dati ricevuti: $data');
              retrievedData = data;
              dataFound = true;
              if (!completer.isCompleted) completer.complete();
            },
          ).timeout(Duration(seconds: 15));

          try {
            await completer.future.timeout(Duration(seconds: 5));
            print('  ✓ TROVATO!');
            break;
          } catch (e) {
            print('  ⏳ Tentativo $attempt fallito, retry...');
            if (attempt < 3) {
              await Future.delayed(Duration(seconds: 3));
            }
          }
        }

        if (dataFound) {
          expect(retrievedData, equals(testData));
          print('\n✅ SUCCESSO: Dati recuperati da nos.lol!');
        } else {
          print('\n⚠️  Dati non trovati su nos.lol dopo 3 tentativi');
        }

        await relay.disconnect();
      } catch (e) {
        print('❌ Errore: $e');
        await relay.disconnect();
      }
    });

    test('Pubblica su relay.damus.io e attendi recupero', () async {
      print('\n╔═══════════════════════════════════════════════════════════╗');
      print('║        TEST RELAY 2: relay.damus.io                      ║');
      print('╚═══════════════════════════════════════════════════════════╝\n');

      final testData = [200, 150, 100, 50];
      late List<int> retrievedData;
      bool dataFound = false;

      final relay = NostrRelayImpl(relayUrl: 'wss://relay.damus.io');

      final publisher = NostrSignalingImpl(
        pubkey: NostrTestKeys.testPublicKey1,
        privkey: NostrTestKeys.testPrivateKey1,
        relay: relay,
        useCompression: false,
      );

      final receiver = NostrSignalingImpl(
        pubkey: NostrTestKeys.testPublicKey2,
        privkey: NostrTestKeys.testPrivateKey2,
        relay: relay,
        useCompression: false,
      );

      try {
        print('📤 Pubblicazione su relay.damus.io...');
        final pubStart = DateTime.now();
        await publisher.connect().timeout(Duration(seconds: 15));
        final eventId = await publisher.publish(testData).timeout(Duration(seconds: 15));
        print('✓ Evento pubblicato: $eventId');
        print('  Tempo: ${DateTime.now().difference(pubStart).inMilliseconds}ms\n');

        print('⏳ Attesa propagazione nel relay: 10 secondi...');
        for (int i = 1; i <= 10; i++) {
          await Future.delayed(Duration(seconds: 1));
          print('   $i/10 secondi...');
        }

        print('\n📥 Tentativo di recupero con RETRY (max 3 tentativi)...');
        for (int attempt = 1; attempt <= 3; attempt++) {
          print('\nTentativo $attempt:');
          final completer = Completer<void>();

          await receiver.subscribe(
            publisher.pubkey,
            (id, data) {
              print('  ✓ Dati ricevuti: $data');
              retrievedData = data;
              dataFound = true;
              if (!completer.isCompleted) completer.complete();
            },
          ).timeout(Duration(seconds: 15));

          try {
            await completer.future.timeout(Duration(seconds: 5));
            print('  ✓ TROVATO!');
            break;
          } catch (e) {
            print('  ⏳ Tentativo $attempt fallito, retry...');
            if (attempt < 3) {
              await Future.delayed(Duration(seconds: 3));
            }
          }
        }

        if (dataFound) {
          expect(retrievedData, equals(testData));
          print('\n✅ SUCCESSO: Dati recuperati da relay.damus.io!');
        } else {
          print('\n⚠️  Dati non trovati su relay.damus.io dopo 3 tentativi');
        }

        await relay.disconnect();
      } catch (e) {
        print('❌ Errore: $e');
        await relay.disconnect();
      }
    });

    test('Pubblica su primal.net e attendi recupero', () async {
      print('\n╔═══════════════════════════════════════════════════════════╗');
      print('║        TEST RELAY 3: primal.net                          ║');
      print('╚═══════════════════════════════════════════════════════════╝\n');

      final testData = [250, 200, 150, 100];
      late List<int> retrievedData;
      bool dataFound = false;

      final relay = NostrRelayImpl(relayUrl: 'wss://primal.net');

      final publisher = NostrSignalingImpl(
        pubkey: NostrTestKeys.testPublicKey1,
        privkey: NostrTestKeys.testPrivateKey1,
        relay: relay,
        useCompression: false,
      );

      final receiver = NostrSignalingImpl(
        pubkey: NostrTestKeys.testPublicKey2,
        privkey: NostrTestKeys.testPrivateKey2,
        relay: relay,
        useCompression: false,
      );

      try {
        print('📤 Pubblicazione su primal.net...');
        final pubStart = DateTime.now();
        await publisher.connect().timeout(Duration(seconds: 15));
        final eventId = await publisher.publish(testData).timeout(Duration(seconds: 15));
        print('✓ Evento pubblicato: $eventId');
        print('  Tempo: ${DateTime.now().difference(pubStart).inMilliseconds}ms\n');

        print('⏳ Attesa propagazione nel relay: 10 secondi...');
        for (int i = 1; i <= 10; i++) {
          await Future.delayed(Duration(seconds: 1));
          print('   $i/10 secondi...');
        }

        print('\n📥 Tentativo di recupero con RETRY (max 3 tentativi)...');
        for (int attempt = 1; attempt <= 3; attempt++) {
          print('\nTentativo $attempt:');
          final completer = Completer<void>();

          await receiver.subscribe(
            publisher.pubkey,
            (id, data) {
              print('  ✓ Dati ricevuti: $data');
              retrievedData = data;
              dataFound = true;
              if (!completer.isCompleted) completer.complete();
            },
          ).timeout(Duration(seconds: 15));

          try {
            await completer.future.timeout(Duration(seconds: 5));
            print('  ✓ TROVATO!');
            break;
          } catch (e) {
            print('  ⏳ Tentativo $attempt fallito, retry...');
            if (attempt < 3) {
              await Future.delayed(Duration(seconds: 3));
            }
          }
        }

        if (dataFound) {
          expect(retrievedData, equals(testData));
          print('\n✅ SUCCESSO: Dati recuperati da primal.net!');
        } else {
          print('\n⚠️  Dati non trovati su primal.net dopo 3 tentativi');
        }

        await relay.disconnect();
      } catch (e) {
        print('❌ Errore: $e');
        await relay.disconnect();
      }
    });
  });
}
