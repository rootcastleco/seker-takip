import 'package:drift/drift.dart';
import '../../domain/entities/medication.dart';
import '../db/app_db.dart';
import '../db/daos/medication_dao.dart';

/// İlaç repository — domain entity ↔ drift dönüşüm katmanı.
class MedicationRepository {
  MedicationRepository(this._dao);
  final MedicationDao _dao;

  Future<List<MedicationEntity>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map(_toDomain).toList();
  }

  Future<List<MedicationEntity>> getActive() async {
    final rows = await _dao.getActive();
    return rows.map(_toDomain).toList();
  }

  Future<MedicationEntity?> getById(int id) async {
    final row = await _dao.getById(id);
    return row != null ? _toDomain(row) : null;
  }

  Future<int> save(MedicationEntity entity) async {
    return _dao.insertMedication(_toCompanion(entity));
  }

  Future<bool> update(MedicationEntity entity) async {
    return _dao.updateMedication(_toCompanionUpdate(entity));
  }

  Future<int> delete(int id) => _dao.deleteMedication(id);

  Future<int> deleteAll() => _dao.deleteAll();

  Future<int> count() => _dao.count();

  // ─── Dönüşüm ────────────────────────────────────────────

  MedicationEntity _toDomain(Medication row) {
    return MedicationEntity(
      id: row.id,
      ilacAdi: row.ilacAdi,
      doz: row.doz,
      hatirlatmaSaati: row.hatirlatmaSaati,
      aktif: row.aktif,
      notlar: row.notlar,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  MedicationsCompanion _toCompanion(MedicationEntity entity) {
    return MedicationsCompanion(
      ilacAdi: Value(entity.ilacAdi),
      doz: Value(entity.doz),
      hatirlatmaSaati: Value(entity.hatirlatmaSaati),
      aktif: Value(entity.aktif),
      notlar: Value(entity.notlar),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }

  MedicationsCompanion _toCompanionUpdate(MedicationEntity entity) {
    return MedicationsCompanion(
      id: Value(entity.id!),
      ilacAdi: Value(entity.ilacAdi),
      doz: Value(entity.doz),
      hatirlatmaSaati: Value(entity.hatirlatmaSaati),
      aktif: Value(entity.aktif),
      notlar: Value(entity.notlar),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }
}
