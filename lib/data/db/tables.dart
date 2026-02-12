import 'package:drift/drift.dart';

/// Profil tablosu — singleton (id=1).
class Profiles extends Table {
  IntColumn get id => integer()();
  TextColumn get isimSoyisim => text().withDefault(const Constant(''))();
  IntColumn get yas => integer().withDefault(const Constant(0))();
  RealColumn get kilo => real().withDefault(const Constant(0.0))();
  TextColumn get doktor => text().withDefault(const Constant(''))();
  TextColumn get diyabetEgitimHemsiresi =>
      text().withDefault(const Constant(''))();
  TextColumn get cepTelefonu => text().withDefault(const Constant(''))();
  TextColumn get adres => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Kan şekeri kayıtları tablosu.
@TableIndex(name: 'idx_glucose_tarih', columns: {#tarih})
class GlucoseRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get tarih => dateTime()();
  TextColumn get ilacInsulinAdi => text().nullable()();
  IntColumn get sabahAc => integer().nullable()();
  IntColumn get sabahTok => integer().nullable()();
  IntColumn get oglenAc => integer().nullable()();
  IntColumn get oglenTok => integer().nullable()();
  IntColumn get aksamAc => integer().nullable()();
  IntColumn get aksamTok => integer().nullable()();
  IntColumn get yatmadanOnce => integer().nullable()();
  IntColumn get gece03 => integer().nullable()();
  TextColumn get notlar => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// İlaç tablosu — kullanıcı ilaçlarını ve hatırlatma saatlerini tutar.
class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ilacAdi => text()();
  TextColumn get doz => text().withDefault(const Constant(''))();

  /// Hatırlatma saati — "HH:mm" formatında saklanır (ör: "08:30").
  TextColumn get hatirlatmaSaati => text().withDefault(const Constant(''))();

  /// İlaç hatırlatıcısı aktif mi?
  BoolColumn get aktif => boolean().withDefault(const Constant(true))();
  TextColumn get notlar => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
