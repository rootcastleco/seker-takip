import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_db.dart';
import '../../data/db/daos/profile_dao.dart';
import '../../data/db/daos/glucose_dao.dart';
import '../../data/db/daos/medication_dao.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/glucose_repository.dart';
import '../../data/repositories/medication_repository.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/glucose_record.dart';
import '../../domain/entities/medication.dart';

// ─── Database ────────────────────────────────────────────
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// ─── DAOs ────────────────────────────────────────────────
final profileDaoProvider = Provider<ProfileDao>((ref) {
  return ProfileDao(ref.watch(databaseProvider));
});

final glucoseDaoProvider = Provider<GlucoseDao>((ref) {
  return GlucoseDao(ref.watch(databaseProvider));
});

final medicationDaoProvider = Provider<MedicationDao>((ref) {
  return MedicationDao(ref.watch(databaseProvider));
});

// ─── Repositories ────────────────────────────────────────
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(profileDaoProvider));
});

final glucoseRepositoryProvider = Provider<GlucoseRepository>((ref) {
  return GlucoseRepository(ref.watch(glucoseDaoProvider));
});

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepository(ref.watch(medicationDaoProvider));
});

// ─── Profil State ────────────────────────────────────────
final profileProvider = AsyncNotifierProvider<ProfileNotifier, ProfileEntity>(
  ProfileNotifier.new,
);

class ProfileNotifier extends AsyncNotifier<ProfileEntity> {
  @override
  Future<ProfileEntity> build() async {
    final repo = ref.read(profileRepositoryProvider);
    return repo.getProfile();
  }

  Future<void> save(ProfileEntity profile) async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.saveProfile(profile);
    state = AsyncData(profile);
  }
}

// ─── Kayıtlar State ─────────────────────────────────────
final glucoseRecordsProvider =
    AsyncNotifierProvider<GlucoseRecordsNotifier, List<GlucoseRecordEntity>>(
      GlucoseRecordsNotifier.new,
    );

class GlucoseRecordsNotifier extends AsyncNotifier<List<GlucoseRecordEntity>> {
  @override
  Future<List<GlucoseRecordEntity>> build() async {
    final repo = ref.read(glucoseRepositoryProvider);
    return repo.getAll();
  }

  Future<void> refresh() async {
    final repo = ref.read(glucoseRepositoryProvider);
    state = AsyncData(await repo.getAll());
  }

  Future<int> save(GlucoseRecordEntity record) async {
    final repo = ref.read(glucoseRepositoryProvider);
    final id = await repo.save(record);
    await refresh();
    return id;
  }

  Future<void> updateRecord(GlucoseRecordEntity record) async {
    final repo = ref.read(glucoseRepositoryProvider);
    await repo.update(record);
    await refresh();
  }

  Future<void> delete(int id) async {
    final repo = ref.read(glucoseRepositoryProvider);
    await repo.delete(id);
    await refresh();
  }
}

// ─── Bugün ───────────────────────────────────────────────
final todayRecordsProvider = FutureProvider<List<GlucoseRecordEntity>>((
  ref,
) async {
  final repo = ref.watch(glucoseRepositoryProvider);
  return repo.getToday();
});

// ─── Son 7 gün ──────────────────────────────────────────
final last7DaysRecordsProvider = FutureProvider<List<GlucoseRecordEntity>>((
  ref,
) async {
  final repo = ref.watch(glucoseRepositoryProvider);
  return repo.getLastDays(7);
});

// ─── Son 90 gün (eA1c + SD) ─────────────────────────────
final last90DaysRecordsProvider = FutureProvider<List<GlucoseRecordEntity>>((
  ref,
) async {
  final repo = ref.watch(glucoseRepositoryProvider);
  return repo.getLastDays(90);
});

// ─── İlaç State ──────────────────────────────────────────
final medicationsProvider =
    AsyncNotifierProvider<MedicationsNotifier, List<MedicationEntity>>(
      MedicationsNotifier.new,
    );

class MedicationsNotifier extends AsyncNotifier<List<MedicationEntity>> {
  @override
  Future<List<MedicationEntity>> build() async {
    final repo = ref.read(medicationRepositoryProvider);
    return repo.getAll();
  }

  Future<void> refresh() async {
    final repo = ref.read(medicationRepositoryProvider);
    state = AsyncData(await repo.getAll());
  }

  Future<int> save(MedicationEntity medication) async {
    final repo = ref.read(medicationRepositoryProvider);
    final id = await repo.save(medication);
    await refresh();
    return id;
  }

  Future<void> updateMedication(MedicationEntity medication) async {
    final repo = ref.read(medicationRepositoryProvider);
    await repo.update(medication);
    await refresh();
  }

  Future<void> delete(int id) async {
    final repo = ref.read(medicationRepositoryProvider);
    await repo.delete(id);
    await refresh();
  }
}

// ─── Aktif İlaçlar ───────────────────────────────────────
final activeMedicationsProvider = FutureProvider<List<MedicationEntity>>((
  ref,
) async {
  final repo = ref.watch(medicationRepositoryProvider);
  return repo.getActive();
});
