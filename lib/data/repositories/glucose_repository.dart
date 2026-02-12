import 'package:drift/drift.dart';
import '../../domain/entities/glucose_record.dart';
import '../db/app_db.dart';
import '../db/daos/glucose_dao.dart';

/// Kan şekeri kayıt repository.
class GlucoseRepository {
  GlucoseRepository(this._dao);
  final GlucoseDao _dao;

  Future<List<GlucoseRecordEntity>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map(_toDomain).toList();
  }

  Future<List<GlucoseRecordEntity>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _dao.getByDateRange(start, end);
    return rows.map(_toDomain).toList();
  }

  Future<List<GlucoseRecordEntity>> getToday() async {
    final rows = await _dao.getToday();
    return rows.map(_toDomain).toList();
  }

  Future<List<GlucoseRecordEntity>> getLastDays(int days) async {
    final rows = await _dao.getLastDays(days);
    return rows.map(_toDomain).toList();
  }

  Future<int> save(GlucoseRecordEntity entity) async {
    return _dao.insertRecord(_toCompanion(entity));
  }

  Future<bool> update(GlucoseRecordEntity entity) async {
    return _dao.updateRecord(_toCompanionUpdate(entity));
  }

  Future<int> delete(int id) => _dao.deleteRecord(id);

  Future<int> deleteAll() => _dao.deleteAll();

  Future<int> count() => _dao.count();

  // ─── Dönüşüm ────────────────────────────────────────────

  GlucoseRecordEntity _toDomain(GlucoseRecord row) {
    return GlucoseRecordEntity(
      id: row.id,
      tarih: row.tarih,
      ilacInsulinAdi: row.ilacInsulinAdi,
      sabahAc: row.sabahAc,
      sabahTok: row.sabahTok,
      oglenAc: row.oglenAc,
      oglenTok: row.oglenTok,
      aksamAc: row.aksamAc,
      aksamTok: row.aksamTok,
      yatmadanOnce: row.yatmadanOnce,
      gece03: row.gece03,
      notlar: row.notlar,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  GlucoseRecordsCompanion _toCompanion(GlucoseRecordEntity entity) {
    return GlucoseRecordsCompanion(
      tarih: Value(entity.tarih),
      ilacInsulinAdi: Value(entity.ilacInsulinAdi),
      sabahAc: Value(entity.sabahAc),
      sabahTok: Value(entity.sabahTok),
      oglenAc: Value(entity.oglenAc),
      oglenTok: Value(entity.oglenTok),
      aksamAc: Value(entity.aksamAc),
      aksamTok: Value(entity.aksamTok),
      yatmadanOnce: Value(entity.yatmadanOnce),
      gece03: Value(entity.gece03),
      notlar: Value(entity.notlar),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }

  GlucoseRecordsCompanion _toCompanionUpdate(GlucoseRecordEntity entity) {
    return GlucoseRecordsCompanion(
      id: Value(entity.id!),
      tarih: Value(entity.tarih),
      ilacInsulinAdi: Value(entity.ilacInsulinAdi),
      sabahAc: Value(entity.sabahAc),
      sabahTok: Value(entity.sabahTok),
      oglenAc: Value(entity.oglenAc),
      oglenTok: Value(entity.oglenTok),
      aksamAc: Value(entity.aksamAc),
      aksamTok: Value(entity.aksamTok),
      yatmadanOnce: Value(entity.yatmadanOnce),
      gece03: Value(entity.gece03),
      notlar: Value(entity.notlar),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }
}
