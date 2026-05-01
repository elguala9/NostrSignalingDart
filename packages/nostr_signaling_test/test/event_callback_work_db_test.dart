import 'dart:io';

import 'package:nostr_signaling/nostr_signaling.dart';
import 'package:test/test.dart';
import 'package:work_db/work_db.dart';

void main() {
  group('EventCallback work_db dedup', () {
    test('default memory db dedup come prima (backward compat)', () {
      int callCount = 0;
      final cb = EventCallback((id, data) { callCount++; });

      cb('peer', [1, 2], hash: 'abc');
      cb('peer', [3, 4], hash: 'abc');

      expect(callCount, equals(1));
    });

    test('default memory db pass-through per hash diversi', () {
      int callCount = 0;
      final cb = EventCallback((id, data) { callCount++; });

      cb('peer', [1], hash: 'h1');
      cb('peer', [2], hash: 'h2');
      cb('peer', [3], hash: 'h3');

      expect(callCount, equals(3));
    });

    test('chiamate senza hash bypassano il db', () {
      int callCount = 0;
      final cb = EventCallback((id, data) { callCount++; });

      cb('peer', [1]);
      cb('peer', [2]);
      cb('peer', [3]);

      expect(callCount, equals(3));
    });

    test('collection di default è "nostr_signaling_seen_hashes"', () {
      final db = WorkDb.memory() as ClientWorkDb;
      final cb = EventCallback((id, data) {}, database: db);

      cb('peer', [1, 2], hash: 'hash-uno');
      cb('peer', [3, 4], hash: 'hash-due');

      final collections = db.getCollectionsSync();
      expect(collections, contains('nostr_signaling_seen_hashes'));

      final items = db.getItemsInCollectionSync('nostr_signaling_seen_hashes');
      expect(items, hasLength(2));
      expect(items, containsAll(['hash-uno', 'hash-due']));
    });

    test('custom collection name', () {
      final db = WorkDb.memory() as ClientWorkDb;
      final cb = EventCallback(
        (id, data) {},
        database: db,
        collection: 'custom-collection',
      );

      cb('peer', [1], hash: 'h1');

      final collections = db.getCollectionsSync();
      expect(collections, contains('custom-collection'));
      expect(collections, isNot(contains('nostr_signaling_seen_hashes')));
    });

    test('database condiviso persiste dedup tra istanze', () {
      final db = WorkDb.memory();
      int count1 = 0;
      final cb1 = EventCallback((id, data) { count1++; }, database: db);
      cb1('peer', [1], hash: 'shared-hash');
      expect(count1, equals(1));

      int count2 = 0;
      final cb2 = EventCallback((id, data) { count2++; }, database: db);
      cb2('peer', [99], hash: 'shared-hash');

      expect(count2, equals(0));
    });

    test('database condiviso: hash nuovi passano in seconda istanza', () {
      final db = WorkDb.memory();
      final cb1 = EventCallback((id, data) {}, database: db);
      cb1('peer', [1], hash: 'old-hash');

      final received = <List<int>>[];
      final cb2 = EventCallback((id, data) { received.add(data); }, database: db);
      cb2('peer', [2], hash: 'old-hash');
      cb2('peer', [3], hash: 'new-hash');

      expect(received, hasLength(1));
      expect(received[0], equals([3]));
    });

    test('maxRecordsPerCollection = 1: solo l\'ultimo hash sopravvive', () {
      final db = WorkDb.memory(maxRecordsPerCollection: 1) as ClientWorkDb;
      final cb = EventCallback((id, data) {}, database: db);

      cb('peer', [1], hash: 'first');
      cb('peer', [2], hash: 'second');

      final items = db.getItemsInCollectionSync('nostr_signaling_seen_hashes');
      expect(items, hasLength(1));
      expect(items, contains('second'));
      expect(items, isNot(contains('first')));
    });

    test('maxRecordsPerCollection = 3: eviction del più vecchio', () {
      final db = WorkDb.memory(maxRecordsPerCollection: 3) as ClientWorkDb;
      final cb = EventCallback((id, data) {}, database: db);

      cb('peer', [1], hash: 'a');
      cb('peer', [2], hash: 'b');
      cb('peer', [3], hash: 'c');
      expect(db.getItemsInCollectionSync('nostr_signaling_seen_hashes'), hasLength(3));

      cb('peer', [4], hash: 'd');
      final items = db.getItemsInCollectionSync('nostr_signaling_seen_hashes');
      expect(items, hasLength(3));
      expect(items, isNot(contains('a')));
      expect(items, containsAll(['b', 'c', 'd']));
    });

    test('maxRecordsPerCollection = 0: nessun record salvato', () {
      final db = WorkDb.memory(maxRecordsPerCollection: 0) as ClientWorkDb;
      int callCount = 0;
      final cb = EventCallback(
        (id, data) { callCount++; },
        database: db,
      );

      cb('peer', [1], hash: 'h1');
      cb('peer', [2], hash: 'h1');

      expect(callCount, equals(2));
      expect(db.getItemsInCollectionSync('nostr_signaling_seen_hashes'), hasLength(0));
    });

    test('maxRecords = 1000 default non evitta prematuramente', () {
      final db = WorkDb.memory() as ClientWorkDb;
      final cb = EventCallback((id, data) {}, database: db);

      for (var i = 0; i < 100; i++) {
        cb('peer', [i], hash: 'hash-$i');
      }

      expect(db.getItemsInCollectionSync('nostr_signaling_seen_hashes'), hasLength(100));
    });

    test('maxRecords su default db evitta dopo il limite', () {
      int callCount = 0;
      final cb = EventCallback(
        (id, data) { callCount++; },
        maxRecords: 5,
      );

      for (var i = 0; i < 5; i++) {
        cb('peer', [i], hash: 'h$i');
      }
      expect(callCount, equals(5));

      cb('peer', [99], hash: 'h5');
      expect(callCount, equals(6));

      cb('peer', [99], hash: 'h0');
      expect(callCount, equals(7));

      cb('peer', [99], hash: 'h5');
      expect(callCount, equals(7));
    });

    test('database IoWorkDb persistente funziona cross-istanza', () {
      final dir = Directory.systemTemp.createTempSync('work_db_test_');
      try {
        final factory = WorkDbFactory();
        final ioDb = factory.create(IoWorkDbFactoryInput(
          dataPath: dir.path,
          maxRecordsPerCollection: 10,
        ));

        int count1 = 0;
        final cb1 = EventCallback((id, data) { count1++; }, database: ioDb);
        cb1('peer', [1], hash: 'persistent-hash');
        expect(count1, equals(1));

        int count2 = 0;
        final cb2 = EventCallback((id, data) { count2++; }, database: ioDb);
        cb2('peer', [2], hash: 'persistent-hash');
        expect(count2, equals(0));

        int count3 = 0;
        final cb3 = EventCallback((id, data) { count3++; }, database: ioDb);
        cb3('peer', [3], hash: 'fresh-hash');
        expect(count3, equals(1));
      } finally {
        dir.deleteSync(recursive: true);
      }
    });

    test('database null usa memory di default (maxRecords=1000)', () {
      int callCount = 0;
      final cb = EventCallback((id, data) { callCount++; });

      for (var i = 0; i < 10; i++) {
        cb('peer', [i], hash: 'h$i');
      }
      expect(callCount, equals(10));

      cb('peer', [99], hash: 'h0');
      cb('peer', [99], hash: 'h5');
      expect(callCount, equals(10));

      cb('peer', [100], hash: 'new-hash');
      expect(callCount, equals(11));
    });

    test('dedup non interferisce con id mittente diverso', () {
      final db = WorkDb.memory();
      int callCount = 0;
      final cb = EventCallback((id, data) { callCount++; }, database: db);

      cb('alice', [1], hash: 'same-hash');
      cb('bob', [2], hash: 'same-hash');

      expect(callCount, equals(1));
    });

    test('stesso hash con dati diversi viene deduplicato', () {
      int callCount = 0;
      final cb = EventCallback((id, data) { callCount++; });

      cb('peer', [1, 2, 3], hash: 'dup');
      cb('peer', [99, 100, 101], hash: 'dup');

      expect(callCount, equals(1));
    });
  });
}
