// ignore_for_file: avoid_print
import 'dart:async';
import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';

void main() {
  group('Multi-Relay Test - Pubblicazione su 3 Relay Diversi', () {
    // Helper per testare un relay: subscribe PRIMA, poi publish, poi attendi callback live
    Future<void> testRelay({
      required String relayUrl,
      required String relayName,
      required List<int> testData,
    }) async {
      print('\n╔═══════════════════════════════════════════════════════════╗');
      print('║        TEST RELAY: $relayName');
      print('╚═══════════════════════════════════════════════════════════╝\n');

      final relay = NostrRelayImpl(relayUrl: relayUrl);
      final pubKeys = NostrKeys.generate();
      final recvKeys = NostrKeys.generate();

      final publisher = NostrSignalingImpl.single(
        keyPair: pubKeys,
        relay: relay,
        useCompression: false,
      );

      final receiver = NostrSignalingImpl.single(
        keyPair: recvKeys,
        relay: relay,
        useCompression: false,
      );

      try {
        print('🔌 Connessione...');
        await publisher.connect().timeout(const Duration(seconds: 15));
        print('✓ Connesso\n');

        // Subscribe PRIMA (live subscription - pattern provato funzionante)
        final completer = Completer<void>();
        late List<int> retrievedData;

        print('📡 Sottoscrizione (subscribe prima del publish)...');
        await receiver.subscribe(
          publisher.pubkey,
          EventCallback((id, data) {
            print('  ✓ Dati ricevuti: $data');
            retrievedData = data;
            if (!completer.isCompleted) completer.complete();
          }),
        ).timeout(const Duration(seconds: 15));
        print('✓ Sottoscrizione attiva\n');

        print('📤 Pubblicazione...');
        final eventId = await publisher.publish(testData).timeout(const Duration(seconds: 15));
        print('✓ Evento pubblicato: $eventId\n');

        print('⏳ Attesa ricezione callback...');
        await completer.future.timeout(const Duration(seconds: 10));

        print('\n✅ SUCCESSO: Dati ricevuti da $relayName!');
        print('  Originali: $testData');
        print('  Ricevuti:  $retrievedData');
        expect(retrievedData, equals(testData));

        await relay.disconnect();
      } catch (e) {
        print('❌ Errore: $e');
        await relay.disconnect();
        rethrow;
      }
    }

    test('Pubblica su nos.lol e attendi recupero', () async {
      await testRelay(
        relayUrl: 'wss://nos.lol',
        relayName: 'nos.lol',
        testData: [111, 222, 100, 50],
      );
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('Pubblica su relay.damus.io e attendi recupero', () async {
      await testRelay(
        relayUrl: 'wss://relay.damus.io',
        relayName: 'relay.damus.io',
        testData: [200, 150, 100, 50],
      );
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('Pubblica su relay.primal.net e attendi recupero', () async {
      await testRelay(
        relayUrl: 'wss://relay.primal.net',
        relayName: 'relay.primal.net',
        testData: [250, 200, 150, 100],
      );
    }, timeout: const Timeout(Duration(seconds: 60)));
  });
}
