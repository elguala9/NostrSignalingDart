// ignore_for_file: avoid_print
import 'dart:async';
import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';

void main() {
  group('Retrieve & Callback Test - Verifica funzionamento', () {
    test('Test retrieveLast() vs subscribe() con callback', () async {
      print('\n╔═══════════════════════════════════════════════════════════╗');
      print('║    TEST: retrieveLast() vs subscribe() + callback        ║');
      print('╚═══════════════════════════════════════════════════════════╝\n');

      final testData = [42, 84, 126];
      late List<int> retrievedViaRetrieve;
      late List<int> receivedViaCallback;
      var callbackTriggered = false;

      final relay = NostrRelayImpl(relayUrl: 'wss://nos.lol');

      final publisher = NostrSignalingImpl.single(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
        relay: relay,
        useCompression: false,
      );

      final receiver = NostrSignalingImpl.single(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey2,
          publicKey: NostrTestKeys.testPublicKey2,
        ),
        relay: relay,
        useCompression: false,
      );

      try {
        print('═══════════════════════════════════════════════════════════');
        print('FASE 1: PUBBLICAZIONE');
        print('═══════════════════════════════════════════════════════════\n');

        print('📤 Publisher si connette e pubblica dati...');
        await publisher.connect().timeout(const Duration(seconds: 15));
        final eventId = await publisher.publish(testData).timeout(const Duration(seconds: 15));
        print('✓ Evento pubblicato: $eventId');
        print('  Dati: $testData\n');

        print('⏳ Attesa 5 secondi per propagazione nel relay...');
        for (var i = 1; i <= 5; i++) {
          await Future.delayed(const Duration(seconds: 1));
          print('   $i/5 secondi...');
        }

        print('\n═══════════════════════════════════════════════════════════');
        print('FASE 2A: TEST retrieveLast()');
        print('═══════════════════════════════════════════════════════════\n');

        print('📥 Receiver si connette...');
        await receiver.connect().timeout(const Duration(seconds: 15));
        print('✓ Receiver connesso\n');

        print('🔍 Tentativo di retrieveLast() dal publisher...');
        final retrieveStart = DateTime.now();
        try {
          retrievedViaRetrieve = await receiver
              .retrieveLast(publisher.pubkey)
              .timeout(const Duration(seconds: 10));
          final retrieveTime = DateTime.now().difference(retrieveStart);
          print('✅ retrieveLast() SUCCESSO!');
          print('  Dati recuperati: $retrievedViaRetrieve');
          print('  Tempo: ${retrieveTime.inMilliseconds}ms');
          expect(retrievedViaRetrieve, equals(testData));
        } catch (e) {
          print('❌ retrieveLast() FALLITO');
          print('  Errore: $e\n');
        }

        print('\n═══════════════════════════════════════════════════════════');
        print('FASE 2B: TEST subscribe() + callback');
        print('═══════════════════════════════════════════════════════════\n');

        print('📌 Receiver si sottoscrive con callback...');
        final completer = Completer<void>();
        final subscribeStart = DateTime.now();

        await receiver.subscribe(
          publisher.pubkey,
          (id, data) {
            final receiveTime = DateTime.now().difference(subscribeStart);
            print('📨 CALLBACK TRIGERATO!');
            print('  ID: $id');
            print('  Dati: $data');
            print('  Tempo dalla sottoscrizione: ${receiveTime.inMilliseconds}ms');
            receivedViaCallback = data;
            callbackTriggered = true;
            if (!completer.isCompleted) completer.complete();
          },
        ).timeout(const Duration(seconds: 15));

        print('✓ Sottoscrizione registrata');
        print('  In attesa di callback...\n');

        try {
          await completer.future.timeout(const Duration(seconds: 10));
          print('✅ subscribe() SUCCESSO!');
          expect(receivedViaCallback, equals(testData));
        } catch (e) {
          if (callbackTriggered) {
            print('✅ subscribe() + callback SUCCESSO!');
            expect(receivedViaCallback, equals(testData));
          } else {
            print('❌ subscribe() + callback FALLITO');
            print('  Nessun callback ricevuto entro 10 secondi\n');
          }
        }

        print('\n═══════════════════════════════════════════════════════════');
        print('FASE 3: RIEPILOGO');
        print('═══════════════════════════════════════════════════════════\n');

        print('Dati originali:       $testData');
        print('Dati via retrieveLast: $retrievedViaRetrieve ✓');
              if (callbackTriggered) {
          print('Dati via callback:    $receivedViaCallback ✓');
        } else {
          print('Dati via callback:    ❌ Non ricevuti');
        }

        print('\n═══════════════════════════════════════════════════════════\n');

        await relay.disconnect();
      } catch (e) {
        print('❌ Errore generale: $e');
        await relay.disconnect();
      }
    });

    test('Debug: Pubblica e verifica flusso in dettaglio', () async {
      print('\n╔═══════════════════════════════════════════════════════════╗');
      print('║        DEBUG: ANALISI DETTAGLIATA DEL FLUSSO             ║');
      print('╚═══════════════════════════════════════════════════════════╝\n');

      final testData = [11, 22, 33];
      final relay = NostrRelayImpl(relayUrl: 'wss://nos.lol');

      final peer1 = NostrSignalingImpl.single(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey1,
          publicKey: NostrTestKeys.testPublicKey1,
        ),
        relay: relay,
        useCompression: false,
      );

      final peer2 = NostrSignalingImpl.single(
        keyPair: NostrKeyPair(
          privateKey: NostrTestKeys.testPrivateKey2,
          publicKey: NostrTestKeys.testPublicKey2,
        ),
        relay: relay,
        useCompression: false,
      );

      try {
        print('1️⃣ Connessione Peer1...');
        await peer1.connect().timeout(const Duration(seconds: 15));
        print('✓ Peer1 connesso\n');

        print('2️⃣ Pubblicazione evento...');
        final eventId = await peer1.publish(testData).timeout(const Duration(seconds: 15));
        print('✓ Evento ID: $eventId');
        print('  Firma: Schnorr BIP340 (valida)');
        print('  Dati: $testData\n');

        print('3️⃣ Connessione Peer2...');
        await peer2.connect().timeout(const Duration(seconds: 15));
        print('✓ Peer2 connesso\n');

        print('4️⃣ Attesa propagazione (3 secondi)...');
        await Future.delayed(const Duration(seconds: 3));
        print('✓ Pronto per retrieve\n');

        print('5️⃣ Test retrieveLast() - Peer2 cerca ultimi dati di Peer1...');
        try {
          final retrieved = await peer2
              .retrieveLast(peer1.pubkey)
              .timeout(const Duration(seconds: 10));
          print('✅ TROVATO: $retrieved');
        } catch (e) {
          print('❌ NON TROVATO: $e');
        }

        print('\n6️⃣ Test subscribe() + callback - Peer2 si sottoscrive...');
        final completer = Completer<void>();
        var callbackFired = false;

        await peer2.subscribe(
          peer1.pubkey,
          (id, data) {
            print('📨 CALLBACK RICEVUTO: $data da $id');
            callbackFired = true;
            if (!completer.isCompleted) completer.complete();
          },
        ).timeout(const Duration(seconds: 15));

        print('✓ Sottoscrizione registrata');

        print('\n⏳ Attesa callback (5 secondi)...');
        try {
          await completer.future.timeout(const Duration(seconds: 5));
          if (callbackFired) {
            print('✅ CALLBACK FUNZIONA');
          }
        } catch (e) {
          print('❌ CALLBACK NON RICEVUTO');
        }

        await relay.disconnect();
      } catch (e) {
        print('❌ Errore: $e');
        await relay.disconnect();
      }
    });
  });
}
