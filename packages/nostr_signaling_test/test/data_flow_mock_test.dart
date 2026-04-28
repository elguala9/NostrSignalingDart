import 'dart:async';
import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';

class DebugSharedRelay implements INostrRelay {
  final List<NostrEvent> publishedEvents = [];
  final Map<String, List<RelayEventCallback>> subscriptions = {};
  bool _isConnected = false;

  @override
  Future<void> connect() async {
    _isConnected = true;
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    subscriptions.clear();
    publishedEvents.clear();
  }

  @override
  bool isConnected() => _isConnected;

  @override
  Future<String> publishEvent(NostrEvent event) async {
    print('📤 Relay: publishEvent ricevuto');
    print('   Event ID: ${event.id}');
    print('   Pubkey: ${event.pubkey}');
    print('   Content: ${event.content}');
    print('   Subscribers: ${subscriptions.length}');

    publishedEvents.add(event);

    // Invia l'evento a tutti i subscriber
    for (final subId in subscriptions.keys) {
      final callbacks = subscriptions[subId]!;
      print('   → Notificando $subId con ${callbacks.length} callbacks');
      for (final callback in callbacks) {
        Future.microtask(() {
          print('   ✓ Callback eseguito per $subId');
          callback(event);
        });
      }
    }

    return event.id;
  }

  @override
  Future<String> subscribe(
    Map<String, dynamic> filter,
    RelayEventCallback onEvent,
  ) async {
    final subId = 'sub_${subscriptions.length + 1}';
    print('📥 Relay: subscribe ricevuto');
    print('   SubID: $subId');
    print('   Filter: $filter');

    subscriptions.putIfAbsent(subId, () => []).add(onEvent);

    // Invia gli eventi già pubblicati che corrispondono al filtro
    final authors = filter['authors'] as List<String>?;
    if (authors != null) {
      print('   Cercando eventi degli autori: $authors');
      for (final event in publishedEvents) {
        if (authors.contains(event.pubkey)) {
          print('   ✓ Trovato evento di ${event.pubkey}, inviando...');
          Future.microtask(() => onEvent(event));
        }
      }
    }

    return subId;
  }

  @override
  Future<void> unsubscribe(String subscriptionId) async {
    subscriptions.remove(subscriptionId);
  }
}

void main() {
  group('Data Flow Test con Mock Relay', () {
    late DebugSharedRelay debugRelay;
    late NostrSignalingImpl peer1;
    late NostrSignalingImpl peer2;

    setUp(() {
      debugRelay = DebugSharedRelay();

      peer1 = NostrSignalingImpl(
        pubkey: NostrTestKeys.testPublicKey1,
        privkey: NostrTestKeys.testPrivateKey1,
        relay: debugRelay,
        useCompression: false,
      );

      peer2 = NostrSignalingImpl(
        pubkey: NostrTestKeys.testPublicKey2,
        privkey: NostrTestKeys.testPrivateKey2,
        relay: debugRelay,
        useCompression: false,
      );
    });

    test('Peer1 pubblica e Peer2 riceve con debug completo', () async {
      print('\n=== Debug Data Flow ===');

      final testData = [1, 2, 3, 4, 5];
      late List<int> receivedData;
      final completer = Completer<void>();

      print('1️⃣ Connessione al relay...');
      await debugRelay.connect();
      print('✓ Relay connesso');

      print('\n2️⃣ Peer2 si sottoscrive ai dati di Peer1...');
      print('   Peer1 pubkey: ${peer1.pubkey}');
      print('   Peer2 pubkey: ${peer2.pubkey}');

      await peer2.subscribe(
        peer1.pubkey,
        (id, data) {
          print('📨 CALLBACK: Peer2 ha ricevuto dati da $id');
          print('   Data: $data');
          receivedData = data;
          completer.complete();
        },
      );
      print('✓ Peer2 iscritto');

      print('\n3️⃣ Peer1 pubblica dati: $testData');
      final eventId = await peer1.publish(testData);
      print('✓ Evento pubblicato con ID: $eventId');

      print('\n4️⃣ In attesa della ricezione...');
      await completer.future.timeout(Duration(seconds: 5));
      print('✓ Dati ricevuti!');

      print('\n5️⃣ Verifica:');
      print('   Inviato:  $testData');
      print('   Ricevuto: $receivedData');
      expect(receivedData, equals(testData));
      print('✓ SUCCESSO: I dati sono identici!\n');
    });
  });
}
