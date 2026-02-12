import 'package:drift/drift.dart';
import '../app_db.dart';

/// Kan şekeri kayıtları DAO.
class GlucoseDao {
  GlucoseDao(this._db);
  final AppDatabase _db;

  /// Tüm kayıtları tarih desc sırasıyla getirir.
  Future<List<GlucoseRecord>> getAll() {
    return (_db.select(_db.glucoseRecords)..orderBy([
          (t) => OrderingTerm(expression: t.tarih, mode: OrderingMode.desc),
        ]))
        .get();
  }

  /// Tarih aralığına göre filtreler.
  Future<List<GlucoseRecord>> getByDateRange(DateTime start, DateTime end) {
    return (_db.select(_db.glucoseRecords)
          ..where(
            (t) =>
                t.tarih.isBiggerOrEqualValue(start) &
                t.tarih.isSmallerOrEqualValue(end),
          )
          ..orderBy([
            (t) => OrderingTerm(expression: t.tarih, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Bugünün kayıtlarını getirir.
  Future<List<GlucoseRecord>> getToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getByDateRange(startOfDay, endOfDay);
  }

  /// Son N günün kayıtlarını getirir.
  Future<List<GlucoseRecord>> getLastDays(int days) {
    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1));
    final end = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    return getByDateRange(start, end);
  }

  /// Tek kayıt ekler.
  Future<int> insertRecord(GlucoseRecordsCompanion record) {
    return _db.into(_db.glucoseRecords).insert(record);
  }

  /// Kayıt günceller.
  Future<bool> updateRecord(GlucoseRecordsCompanion record) {
    return (_db.update(_db.glucoseRecords)
          ..where((t) => t.id.equals(record.id.value)))
        .write(record)
        .then((rows) => rows > 0);
  }

  /// Kayıt siler.
  Future<int> deleteRecord(int id) {
    return (_db.delete(_db.glucoseRecords)..where((t) => t.id.equals(id))).go();
  }

  /// Tüm kayıtları siler (replace import için).
  Future<int> deleteAll() {
    return _db.delete(_db.glucoseRecords).go();
  }

  /// Kayıt sayısını döner.
  Future<int> count() async {
    final countExpr = _db.glucoseRecords.id.count();
    final query = _db.selectOnly(_db.glucoseRecords)..addColumns([countExpr]);
    final result = await query.getSingle();
    return result.read(countExpr) ?? 0;
  }
}
