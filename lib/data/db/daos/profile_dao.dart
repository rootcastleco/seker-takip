import 'package:drift/drift.dart';
import '../app_db.dart';

/// Profil DAO – singleton kayıt (id=1) garanti eder.
class ProfileDao {
  ProfileDao(this._db);
  final AppDatabase _db;

  Future<Profile?> getProfile() {
    return (_db.select(
      _db.profiles,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
  }

  Future<void> upsertProfile(ProfilesCompanion profile) {
    final withId = profile.copyWith(id: const Value(1));
    return _db.into(_db.profiles).insertOnConflictUpdate(withId);
  }
}
