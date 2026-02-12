import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:seker_takip/data/db/app_db.dart';
import 'package:seker_takip/data/db/daos/profile_dao.dart';
import 'package:seker_takip/data/db/daos/glucose_dao.dart';
import 'package:seker_takip/data/repositories/profile_repository.dart';
import 'package:seker_takip/data/repositories/glucose_repository.dart';
import 'package:seker_takip/domain/entities/profile.dart';
import 'package:seker_takip/domain/entities/glucose_record.dart';

void main() {
  late AppDatabase db;
  late ProfileRepository profileRepo;
  late GlucoseRepository glucoseRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    profileRepo = ProfileRepository(ProfileDao(db));
    glucoseRepo = GlucoseRepository(GlucoseDao(db));
  });

  tearDown(() async {
    await db.close();
  });

  group('ProfileRepository', () {
    test('boş veritabanında varsayılan profil döner', () async {
      final profile = await profileRepo.getProfile();
      expect(profile.id, 1);
      expect(profile.isimSoyisim, '');
    });

    test('profil kaydet ve oku', () async {
      final now = DateTime.now();
      final profile = ProfileEntity(
        id: 1,
        isimSoyisim: 'Test Kişi',
        yas: 45,
        kilo: 80,
        doktor: 'Dr. Ahmet',
        diyabetEgitimHemsiresi: 'Hemşire Ayşe',
        cepTelefonu: '+905551234567',
        adres: 'Test Adres',
        createdAt: now,
        updatedAt: now,
      );
      await profileRepo.saveProfile(profile);

      final loaded = await profileRepo.getProfile();
      expect(loaded.isimSoyisim, 'Test Kişi');
      expect(loaded.yas, 45);
      expect(loaded.kilo, 80);
      expect(loaded.doktor, 'Dr. Ahmet');
    });

    test('profil güncelle (singleton id=1)', () async {
      final now = DateTime.now();
      final p1 = ProfileEntity(
        isimSoyisim: 'İlk',
        createdAt: now,
        updatedAt: now,
      );
      await profileRepo.saveProfile(p1);

      final p2 = ProfileEntity(
        isimSoyisim: 'Güncellenmiş',
        createdAt: now,
        updatedAt: now,
      );
      await profileRepo.saveProfile(p2);

      final loaded = await profileRepo.getProfile();
      expect(loaded.isimSoyisim, 'Güncellenmiş');
    });
  });

  group('GlucoseRepository', () {
    test('boş veritabanında boş liste döner', () async {
      final records = await glucoseRepo.getAll();
      expect(records, isEmpty);
    });

    test('kayıt ekle ve oku', () async {
      final now = DateTime.now();
      final record = GlucoseRecordEntity(
        tarih: DateTime(2025, 1, 15),
        sabahAc: 95,
        sabahTok: 130,
        createdAt: now,
        updatedAt: now,
      );
      final id = await glucoseRepo.save(record);
      expect(id, greaterThan(0));

      final all = await glucoseRepo.getAll();
      expect(all.length, 1);
      expect(all.first.sabahAc, 95);
    });

    test('kayıt sil', () async {
      final now = DateTime.now();
      final record = GlucoseRecordEntity(
        tarih: DateTime(2025, 1, 15),
        sabahAc: 100,
        createdAt: now,
        updatedAt: now,
      );
      final id = await glucoseRepo.save(record);
      await glucoseRepo.delete(id);

      final all = await glucoseRepo.getAll();
      expect(all, isEmpty);
    });

    test('kayıt güncelle', () async {
      final now = DateTime.now();
      final record = GlucoseRecordEntity(
        tarih: DateTime(2025, 1, 15),
        sabahAc: 100,
        createdAt: now,
        updatedAt: now,
      );
      final id = await glucoseRepo.save(record);

      final updated = GlucoseRecordEntity(
        id: id,
        tarih: DateTime(2025, 1, 15),
        sabahAc: 110,
        createdAt: now,
        updatedAt: now,
      );
      await glucoseRepo.update(updated);

      final all = await glucoseRepo.getAll();
      expect(all.first.sabahAc, 110);
    });

    test('tarih aralığı filtresi', () async {
      final now = DateTime.now();
      for (var i = 1; i <= 10; i++) {
        await glucoseRepo.save(
          GlucoseRecordEntity(
            tarih: DateTime(2025, 1, i),
            sabahAc: 90 + i,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      final filtered = await glucoseRepo.getByDateRange(
        DateTime(2025, 1, 3),
        DateTime(2025, 1, 7),
      );
      expect(filtered.length, 5);
    });

    test('tümünü sil', () async {
      final now = DateTime.now();
      for (var i = 0; i < 5; i++) {
        await glucoseRepo.save(
          GlucoseRecordEntity(
            tarih: DateTime(2025, 1, i + 1),
            sabahAc: 90,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      final deleted = await glucoseRepo.deleteAll();
      expect(deleted, 5);
      expect(await glucoseRepo.count(), 0);
    });

    test('kayıt sayısı', () async {
      final now = DateTime.now();
      for (var i = 0; i < 3; i++) {
        await glucoseRepo.save(
          GlucoseRecordEntity(
            tarih: DateTime(2025, 1, i + 1),
            sabahAc: 90,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      expect(await glucoseRepo.count(), 3);
    });
  });
}
