import 'dart:async';
import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';

void main() {
  group('Real Relay Integration - Data Flow Verification', () {
    late NostrRelayImpl relay;
    late NostrSignalingImpl peer1;
    late NostrSignalingImpl peer2;

    setUp(() {
      relay = NostrRelayImpl(relayUrl: 'wss://nos.lol');

      peer1 = NostrSignalingImpl(
        pubkey: NostrTestKeys.testPublicKey1,
        privkey: NostrTestKeys.testPrivateKey1,
        relay: relay,
        useCompression: false,
      );

      peer2 = NostrSignalingImpl(
        pubkey: NostrTestKeys.testPublicKey2,
        privkey: NostrTestKeys.testPrivateKey2,
        relay: relay,
        useCompression: false,
      );
    });

    tearDown(() async {
      try {
        if (relay.isConnected()) {
          await relay.disconnect();
        }
      } catch (e) {
        // Ignore
      }
    });

    test('Peer1 pubblica dati e Peer2 li riceve dal relay reale', () async {
      print('\n=== Test: Data Flow Through Real Relay ===');

      // Setup
      final testData = [1, 2, 3, 4, 5];
      late List<int> receivedData;
      final dataReceivedCompleter = Completer<void>();

      print('Connessione al relay...');
      final connectStart = DateTime.now();
      await peer1.connect().timeout(Duration(seconds: 15));
      final connectTime = DateTime.now().difference(connectStart);
      print('✓ Connesso al relay in ${connectTime.inMilliseconds}ms');

      // Peer2 si sottoscrive ai dati di Peer1
      print('Peer2 si sottoscrive ai dati di Peer1...');
      final subscribeStart = DateTime.now();
      await peer2.subscribe(
        NostrTestKeys.testPublicKey1,
        (id, data) {
          print('✓ Peer2 ha ricevuto dati: $data');
          receivedData = data;
          dataReceivedCompleter.complete();
        },
      ).timeout(Duration(seconds: 15));
      final subscribeTime = DateTime.now().difference(subscribeStart);
      print('✓ Sottoscritto in ${subscribeTime.inMilliseconds}ms');

      // Peer1 pubblica dati
      print('Peer1 pubblica dati: $testData');
      final publishStart = DateTime.now();
      final eventId = await peer1.publish(testData).timeout(Duration(seconds: 15));
      final publishTime = DateTime.now().difference(publishStart);
      print('✓ Evento pubblicato con ID: $eventId in ${publishTime.inMilliseconds}ms');

      // Attendi la ricezione dei dati
      print('In attesa della ricezione dei dati...');
      await dataReceivedCompleter.future.timeout(Duration(seconds: 10));
      final totalTime = DateTime.now().difference(publishStart);
      print('✓ Dati ricevuti in ${totalTime.inMilliseconds}ms dalla pubblicazione');

      // Verifica
      print('\n=== Verifica Dati ===');
      print('Dati inviati:  $testData');
      print('Dati ricevuti: $receivedData');
      expect(receivedData, equals(testData), reason: 'I dati devono essere identici');
      print('✓ I dati sono identici!');

      print('\n=== Tempi di Risposta ===');
      print('Connessione:        ${connectTime.inMilliseconds}ms');
      print('Sottoscrizione:     ${subscribeTime.inMilliseconds}ms');
      print('Pubblicazione:      ${publishTime.inMilliseconds}ms');
      print('Ricezione:          ${totalTime.inMilliseconds}ms');
      print('==================\n');
    });

    test('Scambio bidirezionale: Peer1 ↔ Peer2', () async {
      print('\n=== Test: Bidirectional Data Exchange ===');

      final data1 = [10, 20, 30];
      final data2 = [40, 50, 60];
      late List<int> peer2ReceivedFromPeer1;
      late List<int> peer1ReceivedFromPeer2;
      final peer2Completer = Completer<void>();
      final peer1Completer = Completer<void>();

      print('Setup delle sottoscrizioni...');
      final setupStart = DateTime.now();

      await peer1.connect().timeout(Duration(seconds: 15));
      await peer2.connect().timeout(Duration(seconds: 15));

      await peer1.subscribe(
        NostrTestKeys.testPublicKey2,
        (id, data) {
          print('✓ Peer1 riceve da Peer2: $data');
          peer1ReceivedFromPeer2 = data;
          peer1Completer.complete();
        },
      ).timeout(Duration(seconds: 15));

      await peer2.subscribe(
        NostrTestKeys.testPublicKey1,
        (id, data) {
          print('✓ Peer2 riceve da Peer1: $data');
          peer2ReceivedFromPeer1 = data;
          peer2Completer.complete();
        },
      ).timeout(Duration(seconds: 15));

      final setupTime = DateTime.now().difference(setupStart);
      print('✓ Setup completato in ${setupTime.inMilliseconds}ms');

      // Scambio dati
      print('\nScambio dati...');
      final exchangeStart = DateTime.now();

      print('Peer1 pubblica: $data1');
      await peer1.publish(data1).timeout(Duration(seconds: 15));

      print('Peer2 pubblica: $data2');
      await peer2.publish(data2).timeout(Duration(seconds: 15));

      // Attendi ricezione
      print('In attesa della ricezione...');
      await Future.wait([
        peer1Completer.future.timeout(Duration(seconds: 10)),
        peer2Completer.future.timeout(Duration(seconds: 10)),
      ]);

      final exchangeTime = DateTime.now().difference(exchangeStart);
      print('✓ Scambio completato in ${exchangeTime.inMilliseconds}ms');

      // Verifica
      print('\n=== Verifica Scambio Bidirezionale ===');
      print('Peer1: invia $data1, riceve $peer1ReceivedFromPeer2');
      print('Peer2: invia $data2, riceve $peer2ReceivedFromPeer1');
      expect(peer2ReceivedFromPeer1, equals(data1));
      expect(peer1ReceivedFromPeer2, equals(data2));
      print('✓ Lo scambio bidirezionale è corretto!');

      print('\n=== Tempi ===');
      print('Setup:     ${setupTime.inMilliseconds}ms');
      print('Scambio:   ${exchangeTime.inMilliseconds}ms');
      print('Totale:    ${DateTime.now().difference(setupStart).inMilliseconds}ms\n');
    });

    test('Multipli messaggi successivi mantengono ordine e integrità', () async {
      print('\n=== Test: Multiple Messages Integrity ===');

      await peer1.connect().timeout(Duration(seconds: 15));

      final receivedMessages = <List<int>>[];
      final completer = Completer<void>();
      int messagesExpected = 3;

      await peer2.subscribe(
        NostrTestKeys.testPublicKey1,
        (id, data) {
          receivedMessages.add(data);
          print('✓ Messaggio ${receivedMessages.length} ricevuto: $data');
          if (receivedMessages.length == messagesExpected) {
            completer.complete();
          }
        },
      ).timeout(Duration(seconds: 15));

      print('Invio di $messagesExpected messaggi...');
      final startTime = DateTime.now();

      final messages = [
        [1, 1, 1],
        [2, 2, 2],
        [3, 3, 3],
      ];

      for (int i = 0; i < messages.length; i++) {
        print('Invio messaggio ${i + 1}: ${messages[i]}');
        await peer1.publish(messages[i]).timeout(Duration(seconds: 15));
        await Future.delayed(Duration(milliseconds: 200));
      }

      print('In attesa della ricezione di tutti i messaggi...');
      await completer.future.timeout(Duration(seconds: 10));
      final totalTime = DateTime.now().difference(startTime);

      print('\n=== Verifica Integrità ===');
      for (int i = 0; i < messages.length; i++) {
        print('Messaggio ${i + 1}: inviato ${messages[i]}, ricevuto ${receivedMessages[i]}');
        expect(receivedMessages[i], equals(messages[i]));
      }
      print('✓ Tutti i messaggi sono arrivati intatti e nell\'ordine corretto!');
      print('Tempo totale: ${totalTime.inMilliseconds}ms\n');
    });
  });
}
