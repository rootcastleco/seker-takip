import 'package:drift/drift.dart';
import '../../domain/entities/profile.dart';
import '../db/app_db.dart';
import '../db/daos/profile_dao.dart';

/// Profil repository — domain entity ↔ drift dönüşüm katmanı.
class ProfileRepository {
  ProfileRepository(this._dao);
  final ProfileDao _dao;

  Future<ProfileEntity> getProfile() async {
    final row = await _dao.getProfile();
    if (row == null) return ProfileEntity.empty();
    return _toDomain(row);
  }

  Future<void> saveProfile(ProfileEntity entity) async {
    await _dao.upsertProfile(_toCompanion(entity));
  }

  ProfileEntity _toDomain(Profile row) {
    return ProfileEntity(
      id: row.id,
      isimSoyisim: row.isimSoyisim,
      yas: row.yas,
      kilo: row.kilo,
      doktor: row.doktor,
      diyabetEgitimHemsiresi: row.diyabetEgitimHemsiresi,
      cepTelefonu: row.cepTelefonu,
      adres: row.adres,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  ProfilesCompanion _toCompanion(ProfileEntity entity) {
    return ProfilesCompanion(
      id: Value(entity.id),
      isimSoyisim: Value(entity.isimSoyisim),
      yas: Value(entity.yas),
      kilo: Value(entity.kilo),
      doktor: Value(entity.doktor),
      diyabetEgitimHemsiresi: Value(entity.diyabetEgitimHemsiresi),
      cepTelefonu: Value(entity.cepTelefonu),
      adres: Value(entity.adres),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }
}
