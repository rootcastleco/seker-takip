import 'package:drift/drift.dart';
import '../app_db.dart';

/// İlaç kayıtları DAO.
class MedicationDao {
  MedicationDao(this._db);
  final AppDatabase _db;

  /// Tüm ilaçları getirir.
  Future<List<Medication>> getAll() {
    return (_db.select(_db.medications)..orderBy([
          (t) => OrderingTerm(expression: t.ilacAdi, mode: OrderingMode.asc),
        ]))
        .get();
  }

  /// Aktif ilaçları getirir.
  Future<List<Medication>> getActive() {
    return (_db.select(_db.medications)
          ..where((t) => t.aktif.equals(true))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.hatirlatmaSaati,
              mode: OrderingMode.asc,
            ),
          ]))
        .get();
  }

  /// Tek ilaç getirir.
  Future<Medication?> getById(int id) {
    return (_db.select(
      _db.medications,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// İlaç ekler.
  Future<int> insertMedication(MedicationsCompanion medication) {
    return _db.into(_db.medications).insert(medication);
  }

  /// İlaç günceller.
  Future<bool> updateMedication(MedicationsCompanion medication) {
    return (_db.update(_db.medications)
          ..where((t) => t.id.equals(medication.id.value)))
        .write(medication)
        .then((rows) => rows > 0);
  }

  /// İlaç siler.
  Future<int> deleteMedication(int id) {
    return (_db.delete(_db.medications)..where((t) => t.id.equals(id))).go();
  }

  /// Tüm ilaçları siler.
  Future<int> deleteAll() {
    return _db.delete(_db.medications).go();
  }

  /// İlaç sayısı.
  Future<int> count() async {
    final countExpr = _db.medications.id.count();
    final query = _db.selectOnly(_db.medications)..addColumns([countExpr]);
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }
}
