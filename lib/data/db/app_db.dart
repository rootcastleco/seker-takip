import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';

part 'app_db.g.dart';

@DriftDatabase(tables: [Profiles, GlucoseRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Test/in-memory kullanımı için.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Gelecek migration adımları burada tanımlanacak.
      // Örnek:
      // if (from < 2) {
      //   await m.addColumn(glucoseRecords, glucoseRecords.yeniAlan);
      // }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'seker_takip.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
