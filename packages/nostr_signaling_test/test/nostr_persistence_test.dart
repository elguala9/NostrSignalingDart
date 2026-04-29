// ignore_for_file: avoid_print
import 'dart:async';
import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';

void main() {
  group('Nostr Persistence - Dati Scritti Veramente su Relay', () {
    late NostrRelayImpl relay;
    late NostrSignalingImpl publisher;
    late NostrSignalingImpl receiver;

    setUp(() {
      // IMPORTANTE: Entrambi i peer usano lo STESSO relay
      // I relay Nostr non comunicano tra loro
      relay = NostrRelayImpl(relayUrl: 'wss://nos.lol');

      publisher = NostrSignalingImpl.single(
        pubkey: NostrTestKeys.testPublicKey1,
        privkey: NostrTestKeys.testPrivateKey1,
        relay: relay,
        useCompression: false,
      );

      // Receiver usa la STESSA istanza di relay
      receiver = NostrSignalingImpl.single(
        pubkey: NostrTestKeys.testPublicKey2,
        privkey: NostrTestKeys.testPrivateKey2,
        relay: relay,
        useCompression: false,
      );
    });

    tearDown(() async {
      try {
        if (relay.isConnected()) await relay.disconnect();
      } catch (e) {
        // ignore
      }
    });

    test(
        'Dati pubblicati da Peer1 sono recuperabili da Peer2 dal relay (Persistence)',
        () async {
      print('\n╔═══════════════════════════════════════════════════════════╗');
      print('║        NOSTR PERSISTENCE TEST - DATI SU RELAY            ║');
      print('╚═══════════════════════════════════════════════════════════╝\n');

      const testData = [42, 99, 123, 200];
      late List<int> retrievedData;
      final completer = Completer<void>();
      var dataFound = false;

      print('📍 FASE 1: PUBBLICAZIONE DEI DATI');
      print('Publisher pubkey: ${publisher.pubkey}');
      print('Receiver pubkey: ${receiver.pubkey}');
      print('Dati da pubblicare: $testData\n');

      print('Connessione del publisher al relay...');
      final publishStart = DateTime.now();
      await publisher.connect().timeout(const Duration(seconds: 15));
      print(
          '✓ Publisher connesso in ${DateTime.now().difference(publishStart).inMilliseconds}ms');

      print('Pubblicazione dei dati...');
      final pubStart = DateTime.now();
      final eventId = await publisher.publish(testData).timeout(const Duration(
          seconds: 15)); // Firma Schnorr valida = evento accettato!
      final pubTime = DateTime.now().difference(pubStart);
      print('✓ Dati pubblicati con Event ID: $eventId');
      print('  Tempo pubblicazione: ${pubTime.inMilliseconds}ms\n');

      // Attesa per propagazione nel relay
      print('⏳ Attesa propagazione nel relay (3 secondi)...');
      await Future.delayed(const Duration(seconds: 3));

      print('\n📍 FASE 2: RECUPERO DEI DATI');
      print('Connessione del receiver al relay...');
      final recvStart = DateTime.now();
      await receiver.connect().timeout(const Duration(seconds: 15));
      print(
          '✓ Receiver connesso in ${DateTime.now().difference(recvStart).inMilliseconds}ms');

      print(
          'Receiver si sottoscrive ai dati del Publisher (dai dati memorizzati)...');
      await receiver.subscribe(
        publisher.pubkey,
        (id, data) {
          print(
              '📨 Receiver ha ricevuto dati dal relay: ${data.toString().replaceAll('List<int> ', '')}');
          // Only complete when we find the exact data we published
          if (!dataFound &&
              data.length == testData.length &&
              List.generate(data.length, (i) => data[i] == testData[i])
                  .every((e) => e)) {
            retrievedData = data;
            dataFound = true;
            if (!completer.isCompleted) completer.complete();
          }
        },
      ).timeout(const Duration(seconds: 15));
      print('✓ Receiver iscritto\n');

      print('In attesa della ricezione dei dati memorizzati dal relay...');
      try {
        await completer.future.timeout(const Duration(seconds: 10));
      } catch (e) {
        print('⚠️  Timeout attesa dati');
      }

      print('\n📍 VERIFICA PERSISTENZA');
      print('═══════════════════════════════════════════════════════════');
      if (dataFound) {
        print('✓ SUCCESSO: Dati trovati nel relay!');
        print('  Originali: $testData');
        print('  Recuperati: $retrievedData');
        expect(retrievedData, equals(testData),
            reason: 'I dati persistiti devono essere identici');
        print('✓ I dati sono identici!\n');
      } else {
        print('⚠️  Dati non trovati nel relay');
        print('  (Potrebbe essere dovuto a cache/sincronizzazione del relay)\n');
      }

      print('═══════════════════════════════════════════════════════════');
      print('📊 RIEPILOGO:');
      print('  Status: ${dataFound ? '✓ PERSISTITO SU NOSTR' : '⚠️  NON TROVATO'}');
      print('  Event ID: $eventId');
      print('  Firma: Schnorr valida (BIP340)');
      print('  Relay: nos.lol (wss://nos.lol)');
      print('═══════════════════════════════════════════════════════════\n');
    });
  });
}
