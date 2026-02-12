// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isimSoyisimMeta = const VerificationMeta(
    'isimSoyisim',
  );
  @override
  late final GeneratedColumn<String> isimSoyisim = GeneratedColumn<String>(
    'isim_soyisim',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _yasMeta = const VerificationMeta('yas');
  @override
  late final GeneratedColumn<int> yas = GeneratedColumn<int>(
    'yas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _kiloMeta = const VerificationMeta('kilo');
  @override
  late final GeneratedColumn<double> kilo = GeneratedColumn<double>(
    'kilo',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _doktorMeta = const VerificationMeta('doktor');
  @override
  late final GeneratedColumn<String> doktor = GeneratedColumn<String>(
    'doktor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _diyabetEgitimHemsiresiMeta =
      const VerificationMeta('diyabetEgitimHemsiresi');
  @override
  late final GeneratedColumn<String> diyabetEgitimHemsiresi =
      GeneratedColumn<String>(
        'diyabet_egitim_hemsiresi',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _cepTelefonuMeta = const VerificationMeta(
    'cepTelefonu',
  );
  @override
  late final GeneratedColumn<String> cepTelefonu = GeneratedColumn<String>(
    'cep_telefonu',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _adresMeta = const VerificationMeta('adres');
  @override
  late final GeneratedColumn<String> adres = GeneratedColumn<String>(
    'adres',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    isimSoyisim,
    yas,
    kilo,
    doktor,
    diyabetEgitimHemsiresi,
    cepTelefonu,
    adres,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('isim_soyisim')) {
      context.handle(
        _isimSoyisimMeta,
        isimSoyisim.isAcceptableOrUnknown(
          data['isim_soyisim']!,
          _isimSoyisimMeta,
        ),
      );
    }
    if (data.containsKey('yas')) {
      context.handle(
        _yasMeta,
        yas.isAcceptableOrUnknown(data['yas']!, _yasMeta),
      );
    }
    if (data.containsKey('kilo')) {
      context.handle(
        _kiloMeta,
        kilo.isAcceptableOrUnknown(data['kilo']!, _kiloMeta),
      );
    }
    if (data.containsKey('doktor')) {
      context.handle(
        _doktorMeta,
        doktor.isAcceptableOrUnknown(data['doktor']!, _doktorMeta),
      );
    }
    if (data.containsKey('diyabet_egitim_hemsiresi')) {
      context.handle(
        _diyabetEgitimHemsiresiMeta,
        diyabetEgitimHemsiresi.isAcceptableOrUnknown(
          data['diyabet_egitim_hemsiresi']!,
          _diyabetEgitimHemsiresiMeta,
        ),
      );
    }
    if (data.containsKey('cep_telefonu')) {
      context.handle(
        _cepTelefonuMeta,
        cepTelefonu.isAcceptableOrUnknown(
          data['cep_telefonu']!,
          _cepTelefonuMeta,
        ),
      );
    }
    if (data.containsKey('adres')) {
      context.handle(
        _adresMeta,
        adres.isAcceptableOrUnknown(data['adres']!, _adresMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      isimSoyisim: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isim_soyisim'],
      )!,
      yas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}yas'],
      )!,
      kilo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kilo'],
      )!,
      doktor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doktor'],
      )!,
      diyabetEgitimHemsiresi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diyabet_egitim_hemsiresi'],
      )!,
      cepTelefonu: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cep_telefonu'],
      )!,
      adres: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adres'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String isimSoyisim;
  final int yas;
  final double kilo;
  final String doktor;
  final String diyabetEgitimHemsiresi;
  final String cepTelefonu;
  final String adres;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Profile({
    required this.id,
    required this.isimSoyisim,
    required this.yas,
    required this.kilo,
    required this.doktor,
    required this.diyabetEgitimHemsiresi,
    required this.cepTelefonu,
    required this.adres,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['isim_soyisim'] = Variable<String>(isimSoyisim);
    map['yas'] = Variable<int>(yas);
    map['kilo'] = Variable<double>(kilo);
    map['doktor'] = Variable<String>(doktor);
    map['diyabet_egitim_hemsiresi'] = Variable<String>(diyabetEgitimHemsiresi);
    map['cep_telefonu'] = Variable<String>(cepTelefonu);
    map['adres'] = Variable<String>(adres);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      isimSoyisim: Value(isimSoyisim),
      yas: Value(yas),
      kilo: Value(kilo),
      doktor: Value(doktor),
      diyabetEgitimHemsiresi: Value(diyabetEgitimHemsiresi),
      cepTelefonu: Value(cepTelefonu),
      adres: Value(adres),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      isimSoyisim: serializer.fromJson<String>(json['isimSoyisim']),
      yas: serializer.fromJson<int>(json['yas']),
      kilo: serializer.fromJson<double>(json['kilo']),
      doktor: serializer.fromJson<String>(json['doktor']),
      diyabetEgitimHemsiresi: serializer.fromJson<String>(
        json['diyabetEgitimHemsiresi'],
      ),
      cepTelefonu: serializer.fromJson<String>(json['cepTelefonu']),
      adres: serializer.fromJson<String>(json['adres']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'isimSoyisim': serializer.toJson<String>(isimSoyisim),
      'yas': serializer.toJson<int>(yas),
      'kilo': serializer.toJson<double>(kilo),
      'doktor': serializer.toJson<String>(doktor),
      'diyabetEgitimHemsiresi': serializer.toJson<String>(
        diyabetEgitimHemsiresi,
      ),
      'cepTelefonu': serializer.toJson<String>(cepTelefonu),
      'adres': serializer.toJson<String>(adres),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Profile copyWith({
    int? id,
    String? isimSoyisim,
    int? yas,
    double? kilo,
    String? doktor,
    String? diyabetEgitimHemsiresi,
    String? cepTelefonu,
    String? adres,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Profile(
    id: id ?? this.id,
    isimSoyisim: isimSoyisim ?? this.isimSoyisim,
    yas: yas ?? this.yas,
    kilo: kilo ?? this.kilo,
    doktor: doktor ?? this.doktor,
    diyabetEgitimHemsiresi:
        diyabetEgitimHemsiresi ?? this.diyabetEgitimHemsiresi,
    cepTelefonu: cepTelefonu ?? this.cepTelefonu,
    adres: adres ?? this.adres,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      isimSoyisim: data.isimSoyisim.present
          ? data.isimSoyisim.value
          : this.isimSoyisim,
      yas: data.yas.present ? data.yas.value : this.yas,
      kilo: data.kilo.present ? data.kilo.value : this.kilo,
      doktor: data.doktor.present ? data.doktor.value : this.doktor,
      diyabetEgitimHemsiresi: data.diyabetEgitimHemsiresi.present
          ? data.diyabetEgitimHemsiresi.value
          : this.diyabetEgitimHemsiresi,
      cepTelefonu: data.cepTelefonu.present
          ? data.cepTelefonu.value
          : this.cepTelefonu,
      adres: data.adres.present ? data.adres.value : this.adres,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('isimSoyisim: $isimSoyisim, ')
          ..write('yas: $yas, ')
          ..write('kilo: $kilo, ')
          ..write('doktor: $doktor, ')
          ..write('diyabetEgitimHemsiresi: $diyabetEgitimHemsiresi, ')
          ..write('cepTelefonu: $cepTelefonu, ')
          ..write('adres: $adres, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    isimSoyisim,
    yas,
    kilo,
    doktor,
    diyabetEgitimHemsiresi,
    cepTelefonu,
    adres,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.isimSoyisim == this.isimSoyisim &&
          other.yas == this.yas &&
          other.kilo == this.kilo &&
          other.doktor == this.doktor &&
          other.diyabetEgitimHemsiresi == this.diyabetEgitimHemsiresi &&
          other.cepTelefonu == this.cepTelefonu &&
          other.adres == this.adres &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> isimSoyisim;
  final Value<int> yas;
  final Value<double> kilo;
  final Value<String> doktor;
  final Value<String> diyabetEgitimHemsiresi;
  final Value<String> cepTelefonu;
  final Value<String> adres;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.isimSoyisim = const Value.absent(),
    this.yas = const Value.absent(),
    this.kilo = const Value.absent(),
    this.doktor = const Value.absent(),
    this.diyabetEgitimHemsiresi = const Value.absent(),
    this.cepTelefonu = const Value.absent(),
    this.adres = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.isimSoyisim = const Value.absent(),
    this.yas = const Value.absent(),
    this.kilo = const Value.absent(),
    this.doktor = const Value.absent(),
    this.diyabetEgitimHemsiresi = const Value.absent(),
    this.cepTelefonu = const Value.absent(),
    this.adres = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? isimSoyisim,
    Expression<int>? yas,
    Expression<double>? kilo,
    Expression<String>? doktor,
    Expression<String>? diyabetEgitimHemsiresi,
    Expression<String>? cepTelefonu,
    Expression<String>? adres,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (isimSoyisim != null) 'isim_soyisim': isimSoyisim,
      if (yas != null) 'yas': yas,
      if (kilo != null) 'kilo': kilo,
      if (doktor != null) 'doktor': doktor,
      if (diyabetEgitimHemsiresi != null)
        'diyabet_egitim_hemsiresi': diyabetEgitimHemsiresi,
      if (cepTelefonu != null) 'cep_telefonu': cepTelefonu,
      if (adres != null) 'adres': adres,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? isimSoyisim,
    Value<int>? yas,
    Value<double>? kilo,
    Value<String>? doktor,
    Value<String>? diyabetEgitimHemsiresi,
    Value<String>? cepTelefonu,
    Value<String>? adres,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      isimSoyisim: isimSoyisim ?? this.isimSoyisim,
      yas: yas ?? this.yas,
      kilo: kilo ?? this.kilo,
      doktor: doktor ?? this.doktor,
      diyabetEgitimHemsiresi:
          diyabetEgitimHemsiresi ?? this.diyabetEgitimHemsiresi,
      cepTelefonu: cepTelefonu ?? this.cepTelefonu,
      adres: adres ?? this.adres,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (isimSoyisim.present) {
      map['isim_soyisim'] = Variable<String>(isimSoyisim.value);
    }
    if (yas.present) {
      map['yas'] = Variable<int>(yas.value);
    }
    if (kilo.present) {
      map['kilo'] = Variable<double>(kilo.value);
    }
    if (doktor.present) {
      map['doktor'] = Variable<String>(doktor.value);
    }
    if (diyabetEgitimHemsiresi.present) {
      map['diyabet_egitim_hemsiresi'] = Variable<String>(
        diyabetEgitimHemsiresi.value,
      );
    }
    if (cepTelefonu.present) {
      map['cep_telefonu'] = Variable<String>(cepTelefonu.value);
    }
    if (adres.present) {
      map['adres'] = Variable<String>(adres.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('isimSoyisim: $isimSoyisim, ')
          ..write('yas: $yas, ')
          ..write('kilo: $kilo, ')
          ..write('doktor: $doktor, ')
          ..write('diyabetEgitimHemsiresi: $diyabetEgitimHemsiresi, ')
          ..write('cepTelefonu: $cepTelefonu, ')
          ..write('adres: $adres, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $GlucoseRecordsTable extends GlucoseRecords
    with TableInfo<$GlucoseRecordsTable, GlucoseRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GlucoseRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tarihMeta = const VerificationMeta('tarih');
  @override
  late final GeneratedColumn<DateTime> tarih = GeneratedColumn<DateTime>(
    'tarih',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ilacInsulinAdiMeta = const VerificationMeta(
    'ilacInsulinAdi',
  );
  @override
  late final GeneratedColumn<String> ilacInsulinAdi = GeneratedColumn<String>(
    'ilac_insulin_adi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sabahAcMeta = const VerificationMeta(
    'sabahAc',
  );
  @override
  late final GeneratedColumn<int> sabahAc = GeneratedColumn<int>(
    'sabah_ac',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sabahTokMeta = const VerificationMeta(
    'sabahTok',
  );
  @override
  late final GeneratedColumn<int> sabahTok = GeneratedColumn<int>(
    'sabah_tok',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oglenAcMeta = const VerificationMeta(
    'oglenAc',
  );
  @override
  late final GeneratedColumn<int> oglenAc = GeneratedColumn<int>(
    'oglen_ac',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oglenTokMeta = const VerificationMeta(
    'oglenTok',
  );
  @override
  late final GeneratedColumn<int> oglenTok = GeneratedColumn<int>(
    'oglen_tok',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aksamAcMeta = const VerificationMeta(
    'aksamAc',
  );
  @override
  late final GeneratedColumn<int> aksamAc = GeneratedColumn<int>(
    'aksam_ac',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aksamTokMeta = const VerificationMeta(
    'aksamTok',
  );
  @override
  late final GeneratedColumn<int> aksamTok = GeneratedColumn<int>(
    'aksam_tok',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yatmadanOnceMeta = const VerificationMeta(
    'yatmadanOnce',
  );
  @override
  late final GeneratedColumn<int> yatmadanOnce = GeneratedColumn<int>(
    'yatmadan_once',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gece03Meta = const VerificationMeta('gece03');
  @override
  late final GeneratedColumn<int> gece03 = GeneratedColumn<int>(
    'gece03',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notlarMeta = const VerificationMeta('notlar');
  @override
  late final GeneratedColumn<String> notlar = GeneratedColumn<String>(
    'notlar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tarih,
    ilacInsulinAdi,
    sabahAc,
    sabahTok,
    oglenAc,
    oglenTok,
    aksamAc,
    aksamTok,
    yatmadanOnce,
    gece03,
    notlar,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'glucose_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<GlucoseRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tarih')) {
      context.handle(
        _tarihMeta,
        tarih.isAcceptableOrUnknown(data['tarih']!, _tarihMeta),
      );
    } else if (isInserting) {
      context.missing(_tarihMeta);
    }
    if (data.containsKey('ilac_insulin_adi')) {
      context.handle(
        _ilacInsulinAdiMeta,
        ilacInsulinAdi.isAcceptableOrUnknown(
          data['ilac_insulin_adi']!,
          _ilacInsulinAdiMeta,
        ),
      );
    }
    if (data.containsKey('sabah_ac')) {
      context.handle(
        _sabahAcMeta,
        sabahAc.isAcceptableOrUnknown(data['sabah_ac']!, _sabahAcMeta),
      );
    }
    if (data.containsKey('sabah_tok')) {
      context.handle(
        _sabahTokMeta,
        sabahTok.isAcceptableOrUnknown(data['sabah_tok']!, _sabahTokMeta),
      );
    }
    if (data.containsKey('oglen_ac')) {
      context.handle(
        _oglenAcMeta,
        oglenAc.isAcceptableOrUnknown(data['oglen_ac']!, _oglenAcMeta),
      );
    }
    if (data.containsKey('oglen_tok')) {
      context.handle(
        _oglenTokMeta,
        oglenTok.isAcceptableOrUnknown(data['oglen_tok']!, _oglenTokMeta),
      );
    }
    if (data.containsKey('aksam_ac')) {
      context.handle(
        _aksamAcMeta,
        aksamAc.isAcceptableOrUnknown(data['aksam_ac']!, _aksamAcMeta),
      );
    }
    if (data.containsKey('aksam_tok')) {
      context.handle(
        _aksamTokMeta,
        aksamTok.isAcceptableOrUnknown(data['aksam_tok']!, _aksamTokMeta),
      );
    }
    if (data.containsKey('yatmadan_once')) {
      context.handle(
        _yatmadanOnceMeta,
        yatmadanOnce.isAcceptableOrUnknown(
          data['yatmadan_once']!,
          _yatmadanOnceMeta,
        ),
      );
    }
    if (data.containsKey('gece03')) {
      context.handle(
        _gece03Meta,
        gece03.isAcceptableOrUnknown(data['gece03']!, _gece03Meta),
      );
    }
    if (data.containsKey('notlar')) {
      context.handle(
        _notlarMeta,
        notlar.isAcceptableOrUnknown(data['notlar']!, _notlarMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GlucoseRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GlucoseRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tarih: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tarih'],
      )!,
      ilacInsulinAdi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ilac_insulin_adi'],
      ),
      sabahAc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sabah_ac'],
      ),
      sabahTok: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sabah_tok'],
      ),
      oglenAc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}oglen_ac'],
      ),
      oglenTok: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}oglen_tok'],
      ),
      aksamAc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}aksam_ac'],
      ),
      aksamTok: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}aksam_tok'],
      ),
      yatmadanOnce: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}yatmadan_once'],
      ),
      gece03: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gece03'],
      ),
      notlar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notlar'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GlucoseRecordsTable createAlias(String alias) {
    return $GlucoseRecordsTable(attachedDatabase, alias);
  }
}

class GlucoseRecord extends DataClass implements Insertable<GlucoseRecord> {
  final int id;
  final DateTime tarih;
  final String? ilacInsulinAdi;
  final int? sabahAc;
  final int? sabahTok;
  final int? oglenAc;
  final int? oglenTok;
  final int? aksamAc;
  final int? aksamTok;
  final int? yatmadanOnce;
  final int? gece03;
  final String? notlar;
  final DateTime createdAt;
  final DateTime updatedAt;
  const GlucoseRecord({
    required this.id,
    required this.tarih,
    this.ilacInsulinAdi,
    this.sabahAc,
    this.sabahTok,
    this.oglenAc,
    this.oglenTok,
    this.aksamAc,
    this.aksamTok,
    this.yatmadanOnce,
    this.gece03,
    this.notlar,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tarih'] = Variable<DateTime>(tarih);
    if (!nullToAbsent || ilacInsulinAdi != null) {
      map['ilac_insulin_adi'] = Variable<String>(ilacInsulinAdi);
    }
    if (!nullToAbsent || sabahAc != null) {
      map['sabah_ac'] = Variable<int>(sabahAc);
    }
    if (!nullToAbsent || sabahTok != null) {
      map['sabah_tok'] = Variable<int>(sabahTok);
    }
    if (!nullToAbsent || oglenAc != null) {
      map['oglen_ac'] = Variable<int>(oglenAc);
    }
    if (!nullToAbsent || oglenTok != null) {
      map['oglen_tok'] = Variable<int>(oglenTok);
    }
    if (!nullToAbsent || aksamAc != null) {
      map['aksam_ac'] = Variable<int>(aksamAc);
    }
    if (!nullToAbsent || aksamTok != null) {
      map['aksam_tok'] = Variable<int>(aksamTok);
    }
    if (!nullToAbsent || yatmadanOnce != null) {
      map['yatmadan_once'] = Variable<int>(yatmadanOnce);
    }
    if (!nullToAbsent || gece03 != null) {
      map['gece03'] = Variable<int>(gece03);
    }
    if (!nullToAbsent || notlar != null) {
      map['notlar'] = Variable<String>(notlar);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GlucoseRecordsCompanion toCompanion(bool nullToAbsent) {
    return GlucoseRecordsCompanion(
      id: Value(id),
      tarih: Value(tarih),
      ilacInsulinAdi: ilacInsulinAdi == null && nullToAbsent
          ? const Value.absent()
          : Value(ilacInsulinAdi),
      sabahAc: sabahAc == null && nullToAbsent
          ? const Value.absent()
          : Value(sabahAc),
      sabahTok: sabahTok == null && nullToAbsent
          ? const Value.absent()
          : Value(sabahTok),
      oglenAc: oglenAc == null && nullToAbsent
          ? const Value.absent()
          : Value(oglenAc),
      oglenTok: oglenTok == null && nullToAbsent
          ? const Value.absent()
          : Value(oglenTok),
      aksamAc: aksamAc == null && nullToAbsent
          ? const Value.absent()
          : Value(aksamAc),
      aksamTok: aksamTok == null && nullToAbsent
          ? const Value.absent()
          : Value(aksamTok),
      yatmadanOnce: yatmadanOnce == null && nullToAbsent
          ? const Value.absent()
          : Value(yatmadanOnce),
      gece03: gece03 == null && nullToAbsent
          ? const Value.absent()
          : Value(gece03),
      notlar: notlar == null && nullToAbsent
          ? const Value.absent()
          : Value(notlar),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory GlucoseRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GlucoseRecord(
      id: serializer.fromJson<int>(json['id']),
      tarih: serializer.fromJson<DateTime>(json['tarih']),
      ilacInsulinAdi: serializer.fromJson<String?>(json['ilacInsulinAdi']),
      sabahAc: serializer.fromJson<int?>(json['sabahAc']),
      sabahTok: serializer.fromJson<int?>(json['sabahTok']),
      oglenAc: serializer.fromJson<int?>(json['oglenAc']),
      oglenTok: serializer.fromJson<int?>(json['oglenTok']),
      aksamAc: serializer.fromJson<int?>(json['aksamAc']),
      aksamTok: serializer.fromJson<int?>(json['aksamTok']),
      yatmadanOnce: serializer.fromJson<int?>(json['yatmadanOnce']),
      gece03: serializer.fromJson<int?>(json['gece03']),
      notlar: serializer.fromJson<String?>(json['notlar']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tarih': serializer.toJson<DateTime>(tarih),
      'ilacInsulinAdi': serializer.toJson<String?>(ilacInsulinAdi),
      'sabahAc': serializer.toJson<int?>(sabahAc),
      'sabahTok': serializer.toJson<int?>(sabahTok),
      'oglenAc': serializer.toJson<int?>(oglenAc),
      'oglenTok': serializer.toJson<int?>(oglenTok),
      'aksamAc': serializer.toJson<int?>(aksamAc),
      'aksamTok': serializer.toJson<int?>(aksamTok),
      'yatmadanOnce': serializer.toJson<int?>(yatmadanOnce),
      'gece03': serializer.toJson<int?>(gece03),
      'notlar': serializer.toJson<String?>(notlar),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GlucoseRecord copyWith({
    int? id,
    DateTime? tarih,
    Value<String?> ilacInsulinAdi = const Value.absent(),
    Value<int?> sabahAc = const Value.absent(),
    Value<int?> sabahTok = const Value.absent(),
    Value<int?> oglenAc = const Value.absent(),
    Value<int?> oglenTok = const Value.absent(),
    Value<int?> aksamAc = const Value.absent(),
    Value<int?> aksamTok = const Value.absent(),
    Value<int?> yatmadanOnce = const Value.absent(),
    Value<int?> gece03 = const Value.absent(),
    Value<String?> notlar = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => GlucoseRecord(
    id: id ?? this.id,
    tarih: tarih ?? this.tarih,
    ilacInsulinAdi: ilacInsulinAdi.present
        ? ilacInsulinAdi.value
        : this.ilacInsulinAdi,
    sabahAc: sabahAc.present ? sabahAc.value : this.sabahAc,
    sabahTok: sabahTok.present ? sabahTok.value : this.sabahTok,
    oglenAc: oglenAc.present ? oglenAc.value : this.oglenAc,
    oglenTok: oglenTok.present ? oglenTok.value : this.oglenTok,
    aksamAc: aksamAc.present ? aksamAc.value : this.aksamAc,
    aksamTok: aksamTok.present ? aksamTok.value : this.aksamTok,
    yatmadanOnce: yatmadanOnce.present ? yatmadanOnce.value : this.yatmadanOnce,
    gece03: gece03.present ? gece03.value : this.gece03,
    notlar: notlar.present ? notlar.value : this.notlar,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  GlucoseRecord copyWithCompanion(GlucoseRecordsCompanion data) {
    return GlucoseRecord(
      id: data.id.present ? data.id.value : this.id,
      tarih: data.tarih.present ? data.tarih.value : this.tarih,
      ilacInsulinAdi: data.ilacInsulinAdi.present
          ? data.ilacInsulinAdi.value
          : this.ilacInsulinAdi,
      sabahAc: data.sabahAc.present ? data.sabahAc.value : this.sabahAc,
      sabahTok: data.sabahTok.present ? data.sabahTok.value : this.sabahTok,
      oglenAc: data.oglenAc.present ? data.oglenAc.value : this.oglenAc,
      oglenTok: data.oglenTok.present ? data.oglenTok.value : this.oglenTok,
      aksamAc: data.aksamAc.present ? data.aksamAc.value : this.aksamAc,
      aksamTok: data.aksamTok.present ? data.aksamTok.value : this.aksamTok,
      yatmadanOnce: data.yatmadanOnce.present
          ? data.yatmadanOnce.value
          : this.yatmadanOnce,
      gece03: data.gece03.present ? data.gece03.value : this.gece03,
      notlar: data.notlar.present ? data.notlar.value : this.notlar,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GlucoseRecord(')
          ..write('id: $id, ')
          ..write('tarih: $tarih, ')
          ..write('ilacInsulinAdi: $ilacInsulinAdi, ')
          ..write('sabahAc: $sabahAc, ')
          ..write('sabahTok: $sabahTok, ')
          ..write('oglenAc: $oglenAc, ')
          ..write('oglenTok: $oglenTok, ')
          ..write('aksamAc: $aksamAc, ')
          ..write('aksamTok: $aksamTok, ')
          ..write('yatmadanOnce: $yatmadanOnce, ')
          ..write('gece03: $gece03, ')
          ..write('notlar: $notlar, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tarih,
    ilacInsulinAdi,
    sabahAc,
    sabahTok,
    oglenAc,
    oglenTok,
    aksamAc,
    aksamTok,
    yatmadanOnce,
    gece03,
    notlar,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GlucoseRecord &&
          other.id == this.id &&
          other.tarih == this.tarih &&
          other.ilacInsulinAdi == this.ilacInsulinAdi &&
          other.sabahAc == this.sabahAc &&
          other.sabahTok == this.sabahTok &&
          other.oglenAc == this.oglenAc &&
          other.oglenTok == this.oglenTok &&
          other.aksamAc == this.aksamAc &&
          other.aksamTok == this.aksamTok &&
          other.yatmadanOnce == this.yatmadanOnce &&
          other.gece03 == this.gece03 &&
          other.notlar == this.notlar &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GlucoseRecordsCompanion extends UpdateCompanion<GlucoseRecord> {
  final Value<int> id;
  final Value<DateTime> tarih;
  final Value<String?> ilacInsulinAdi;
  final Value<int?> sabahAc;
  final Value<int?> sabahTok;
  final Value<int?> oglenAc;
  final Value<int?> oglenTok;
  final Value<int?> aksamAc;
  final Value<int?> aksamTok;
  final Value<int?> yatmadanOnce;
  final Value<int?> gece03;
  final Value<String?> notlar;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const GlucoseRecordsCompanion({
    this.id = const Value.absent(),
    this.tarih = const Value.absent(),
    this.ilacInsulinAdi = const Value.absent(),
    this.sabahAc = const Value.absent(),
    this.sabahTok = const Value.absent(),
    this.oglenAc = const Value.absent(),
    this.oglenTok = const Value.absent(),
    this.aksamAc = const Value.absent(),
    this.aksamTok = const Value.absent(),
    this.yatmadanOnce = const Value.absent(),
    this.gece03 = const Value.absent(),
    this.notlar = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  GlucoseRecordsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime tarih,
    this.ilacInsulinAdi = const Value.absent(),
    this.sabahAc = const Value.absent(),
    this.sabahTok = const Value.absent(),
    this.oglenAc = const Value.absent(),
    this.oglenTok = const Value.absent(),
    this.aksamAc = const Value.absent(),
    this.aksamTok = const Value.absent(),
    this.yatmadanOnce = const Value.absent(),
    this.gece03 = const Value.absent(),
    this.notlar = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : tarih = Value(tarih),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<GlucoseRecord> custom({
    Expression<int>? id,
    Expression<DateTime>? tarih,
    Expression<String>? ilacInsulinAdi,
    Expression<int>? sabahAc,
    Expression<int>? sabahTok,
    Expression<int>? oglenAc,
    Expression<int>? oglenTok,
    Expression<int>? aksamAc,
    Expression<int>? aksamTok,
    Expression<int>? yatmadanOnce,
    Expression<int>? gece03,
    Expression<String>? notlar,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tarih != null) 'tarih': tarih,
      if (ilacInsulinAdi != null) 'ilac_insulin_adi': ilacInsulinAdi,
      if (sabahAc != null) 'sabah_ac': sabahAc,
      if (sabahTok != null) 'sabah_tok': sabahTok,
      if (oglenAc != null) 'oglen_ac': oglenAc,
      if (oglenTok != null) 'oglen_tok': oglenTok,
      if (aksamAc != null) 'aksam_ac': aksamAc,
      if (aksamTok != null) 'aksam_tok': aksamTok,
      if (yatmadanOnce != null) 'yatmadan_once': yatmadanOnce,
      if (gece03 != null) 'gece03': gece03,
      if (notlar != null) 'notlar': notlar,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  GlucoseRecordsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? tarih,
    Value<String?>? ilacInsulinAdi,
    Value<int?>? sabahAc,
    Value<int?>? sabahTok,
    Value<int?>? oglenAc,
    Value<int?>? oglenTok,
    Value<int?>? aksamAc,
    Value<int?>? aksamTok,
    Value<int?>? yatmadanOnce,
    Value<int?>? gece03,
    Value<String?>? notlar,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return GlucoseRecordsCompanion(
      id: id ?? this.id,
      tarih: tarih ?? this.tarih,
      ilacInsulinAdi: ilacInsulinAdi ?? this.ilacInsulinAdi,
      sabahAc: sabahAc ?? this.sabahAc,
      sabahTok: sabahTok ?? this.sabahTok,
      oglenAc: oglenAc ?? this.oglenAc,
      oglenTok: oglenTok ?? this.oglenTok,
      aksamAc: aksamAc ?? this.aksamAc,
      aksamTok: aksamTok ?? this.aksamTok,
      yatmadanOnce: yatmadanOnce ?? this.yatmadanOnce,
      gece03: gece03 ?? this.gece03,
      notlar: notlar ?? this.notlar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tarih.present) {
      map['tarih'] = Variable<DateTime>(tarih.value);
    }
    if (ilacInsulinAdi.present) {
      map['ilac_insulin_adi'] = Variable<String>(ilacInsulinAdi.value);
    }
    if (sabahAc.present) {
      map['sabah_ac'] = Variable<int>(sabahAc.value);
    }
    if (sabahTok.present) {
      map['sabah_tok'] = Variable<int>(sabahTok.value);
    }
    if (oglenAc.present) {
      map['oglen_ac'] = Variable<int>(oglenAc.value);
    }
    if (oglenTok.present) {
      map['oglen_tok'] = Variable<int>(oglenTok.value);
    }
    if (aksamAc.present) {
      map['aksam_ac'] = Variable<int>(aksamAc.value);
    }
    if (aksamTok.present) {
      map['aksam_tok'] = Variable<int>(aksamTok.value);
    }
    if (yatmadanOnce.present) {
      map['yatmadan_once'] = Variable<int>(yatmadanOnce.value);
    }
    if (gece03.present) {
      map['gece03'] = Variable<int>(gece03.value);
    }
    if (notlar.present) {
      map['notlar'] = Variable<String>(notlar.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GlucoseRecordsCompanion(')
          ..write('id: $id, ')
          ..write('tarih: $tarih, ')
          ..write('ilacInsulinAdi: $ilacInsulinAdi, ')
          ..write('sabahAc: $sabahAc, ')
          ..write('sabahTok: $sabahTok, ')
          ..write('oglenAc: $oglenAc, ')
          ..write('oglenTok: $oglenTok, ')
          ..write('aksamAc: $aksamAc, ')
          ..write('aksamTok: $aksamTok, ')
          ..write('yatmadanOnce: $yatmadanOnce, ')
          ..write('gece03: $gece03, ')
          ..write('notlar: $notlar, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, Medication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ilacAdiMeta = const VerificationMeta(
    'ilacAdi',
  );
  @override
  late final GeneratedColumn<String> ilacAdi = GeneratedColumn<String>(
    'ilac_adi',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dozMeta = const VerificationMeta('doz');
  @override
  late final GeneratedColumn<String> doz = GeneratedColumn<String>(
    'doz',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _hatirlatmaSaatiMeta = const VerificationMeta(
    'hatirlatmaSaati',
  );
  @override
  late final GeneratedColumn<String> hatirlatmaSaati = GeneratedColumn<String>(
    'hatirlatma_saati',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _aktifMeta = const VerificationMeta('aktif');
  @override
  late final GeneratedColumn<bool> aktif = GeneratedColumn<bool>(
    'aktif',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("aktif" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notlarMeta = const VerificationMeta('notlar');
  @override
  late final GeneratedColumn<String> notlar = GeneratedColumn<String>(
    'notlar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ilacAdi,
    doz,
    hatirlatmaSaati,
    aktif,
    notlar,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medication> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ilac_adi')) {
      context.handle(
        _ilacAdiMeta,
        ilacAdi.isAcceptableOrUnknown(data['ilac_adi']!, _ilacAdiMeta),
      );
    } else if (isInserting) {
      context.missing(_ilacAdiMeta);
    }
    if (data.containsKey('doz')) {
      context.handle(
        _dozMeta,
        doz.isAcceptableOrUnknown(data['doz']!, _dozMeta),
      );
    }
    if (data.containsKey('hatirlatma_saati')) {
      context.handle(
        _hatirlatmaSaatiMeta,
        hatirlatmaSaati.isAcceptableOrUnknown(
          data['hatirlatma_saati']!,
          _hatirlatmaSaatiMeta,
        ),
      );
    }
    if (data.containsKey('aktif')) {
      context.handle(
        _aktifMeta,
        aktif.isAcceptableOrUnknown(data['aktif']!, _aktifMeta),
      );
    }
    if (data.containsKey('notlar')) {
      context.handle(
        _notlarMeta,
        notlar.isAcceptableOrUnknown(data['notlar']!, _notlarMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medication(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ilacAdi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ilac_adi'],
      )!,
      doz: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doz'],
      )!,
      hatirlatmaSaati: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hatirlatma_saati'],
      )!,
      aktif: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}aktif'],
      )!,
      notlar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notlar'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }
}

class Medication extends DataClass implements Insertable<Medication> {
  final int id;
  final String ilacAdi;
  final String doz;

  /// Hatırlatma saati — "HH:mm" formatında saklanır (ör: "08:30").
  final String hatirlatmaSaati;

  /// İlaç hatırlatıcısı aktif mi?
  final bool aktif;
  final String? notlar;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Medication({
    required this.id,
    required this.ilacAdi,
    required this.doz,
    required this.hatirlatmaSaati,
    required this.aktif,
    this.notlar,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ilac_adi'] = Variable<String>(ilacAdi);
    map['doz'] = Variable<String>(doz);
    map['hatirlatma_saati'] = Variable<String>(hatirlatmaSaati);
    map['aktif'] = Variable<bool>(aktif);
    if (!nullToAbsent || notlar != null) {
      map['notlar'] = Variable<String>(notlar);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      ilacAdi: Value(ilacAdi),
      doz: Value(doz),
      hatirlatmaSaati: Value(hatirlatmaSaati),
      aktif: Value(aktif),
      notlar: notlar == null && nullToAbsent
          ? const Value.absent()
          : Value(notlar),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Medication.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medication(
      id: serializer.fromJson<int>(json['id']),
      ilacAdi: serializer.fromJson<String>(json['ilacAdi']),
      doz: serializer.fromJson<String>(json['doz']),
      hatirlatmaSaati: serializer.fromJson<String>(json['hatirlatmaSaati']),
      aktif: serializer.fromJson<bool>(json['aktif']),
      notlar: serializer.fromJson<String?>(json['notlar']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ilacAdi': serializer.toJson<String>(ilacAdi),
      'doz': serializer.toJson<String>(doz),
      'hatirlatmaSaati': serializer.toJson<String>(hatirlatmaSaati),
      'aktif': serializer.toJson<bool>(aktif),
      'notlar': serializer.toJson<String?>(notlar),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Medication copyWith({
    int? id,
    String? ilacAdi,
    String? doz,
    String? hatirlatmaSaati,
    bool? aktif,
    Value<String?> notlar = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Medication(
    id: id ?? this.id,
    ilacAdi: ilacAdi ?? this.ilacAdi,
    doz: doz ?? this.doz,
    hatirlatmaSaati: hatirlatmaSaati ?? this.hatirlatmaSaati,
    aktif: aktif ?? this.aktif,
    notlar: notlar.present ? notlar.value : this.notlar,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Medication copyWithCompanion(MedicationsCompanion data) {
    return Medication(
      id: data.id.present ? data.id.value : this.id,
      ilacAdi: data.ilacAdi.present ? data.ilacAdi.value : this.ilacAdi,
      doz: data.doz.present ? data.doz.value : this.doz,
      hatirlatmaSaati: data.hatirlatmaSaati.present
          ? data.hatirlatmaSaati.value
          : this.hatirlatmaSaati,
      aktif: data.aktif.present ? data.aktif.value : this.aktif,
      notlar: data.notlar.present ? data.notlar.value : this.notlar,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medication(')
          ..write('id: $id, ')
          ..write('ilacAdi: $ilacAdi, ')
          ..write('doz: $doz, ')
          ..write('hatirlatmaSaati: $hatirlatmaSaati, ')
          ..write('aktif: $aktif, ')
          ..write('notlar: $notlar, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ilacAdi,
    doz,
    hatirlatmaSaati,
    aktif,
    notlar,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.ilacAdi == this.ilacAdi &&
          other.doz == this.doz &&
          other.hatirlatmaSaati == this.hatirlatmaSaati &&
          other.aktif == this.aktif &&
          other.notlar == this.notlar &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<int> id;
  final Value<String> ilacAdi;
  final Value<String> doz;
  final Value<String> hatirlatmaSaati;
  final Value<bool> aktif;
  final Value<String?> notlar;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.ilacAdi = const Value.absent(),
    this.doz = const Value.absent(),
    this.hatirlatmaSaati = const Value.absent(),
    this.aktif = const Value.absent(),
    this.notlar = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MedicationsCompanion.insert({
    this.id = const Value.absent(),
    required String ilacAdi,
    this.doz = const Value.absent(),
    this.hatirlatmaSaati = const Value.absent(),
    this.aktif = const Value.absent(),
    this.notlar = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : ilacAdi = Value(ilacAdi),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Medication> custom({
    Expression<int>? id,
    Expression<String>? ilacAdi,
    Expression<String>? doz,
    Expression<String>? hatirlatmaSaati,
    Expression<bool>? aktif,
    Expression<String>? notlar,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ilacAdi != null) 'ilac_adi': ilacAdi,
      if (doz != null) 'doz': doz,
      if (hatirlatmaSaati != null) 'hatirlatma_saati': hatirlatmaSaati,
      if (aktif != null) 'aktif': aktif,
      if (notlar != null) 'notlar': notlar,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MedicationsCompanion copyWith({
    Value<int>? id,
    Value<String>? ilacAdi,
    Value<String>? doz,
    Value<String>? hatirlatmaSaati,
    Value<bool>? aktif,
    Value<String?>? notlar,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return MedicationsCompanion(
      id: id ?? this.id,
      ilacAdi: ilacAdi ?? this.ilacAdi,
      doz: doz ?? this.doz,
      hatirlatmaSaati: hatirlatmaSaati ?? this.hatirlatmaSaati,
      aktif: aktif ?? this.aktif,
      notlar: notlar ?? this.notlar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ilacAdi.present) {
      map['ilac_adi'] = Variable<String>(ilacAdi.value);
    }
    if (doz.present) {
      map['doz'] = Variable<String>(doz.value);
    }
    if (hatirlatmaSaati.present) {
      map['hatirlatma_saati'] = Variable<String>(hatirlatmaSaati.value);
    }
    if (aktif.present) {
      map['aktif'] = Variable<bool>(aktif.value);
    }
    if (notlar.present) {
      map['notlar'] = Variable<String>(notlar.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('ilacAdi: $ilacAdi, ')
          ..write('doz: $doz, ')
          ..write('hatirlatmaSaati: $hatirlatmaSaati, ')
          ..write('aktif: $aktif, ')
          ..write('notlar: $notlar, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $GlucoseRecordsTable glucoseRecords = $GlucoseRecordsTable(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final Index idxGlucoseTarih = Index(
    'idx_glucose_tarih',
    'CREATE INDEX idx_glucose_tarih ON glucose_records (tarih)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    glucoseRecords,
    medications,
    idxGlucoseTarih,
  ];
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String> isimSoyisim,
      Value<int> yas,
      Value<double> kilo,
      Value<String> doktor,
      Value<String> diyabetEgitimHemsiresi,
      Value<String> cepTelefonu,
      Value<String> adres,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String> isimSoyisim,
      Value<int> yas,
      Value<double> kilo,
      Value<String> doktor,
      Value<String> diyabetEgitimHemsiresi,
      Value<String> cepTelefonu,
      Value<String> adres,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isimSoyisim => $composableBuilder(
    column: $table.isimSoyisim,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yas => $composableBuilder(
    column: $table.yas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kilo => $composableBuilder(
    column: $table.kilo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doktor => $composableBuilder(
    column: $table.doktor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diyabetEgitimHemsiresi => $composableBuilder(
    column: $table.diyabetEgitimHemsiresi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cepTelefonu => $composableBuilder(
    column: $table.cepTelefonu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adres => $composableBuilder(
    column: $table.adres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isimSoyisim => $composableBuilder(
    column: $table.isimSoyisim,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yas => $composableBuilder(
    column: $table.yas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kilo => $composableBuilder(
    column: $table.kilo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doktor => $composableBuilder(
    column: $table.doktor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diyabetEgitimHemsiresi => $composableBuilder(
    column: $table.diyabetEgitimHemsiresi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cepTelefonu => $composableBuilder(
    column: $table.cepTelefonu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adres => $composableBuilder(
    column: $table.adres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get isimSoyisim => $composableBuilder(
    column: $table.isimSoyisim,
    builder: (column) => column,
  );

  GeneratedColumn<int> get yas =>
      $composableBuilder(column: $table.yas, builder: (column) => column);

  GeneratedColumn<double> get kilo =>
      $composableBuilder(column: $table.kilo, builder: (column) => column);

  GeneratedColumn<String> get doktor =>
      $composableBuilder(column: $table.doktor, builder: (column) => column);

  GeneratedColumn<String> get diyabetEgitimHemsiresi => $composableBuilder(
    column: $table.diyabetEgitimHemsiresi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cepTelefonu => $composableBuilder(
    column: $table.cepTelefonu,
    builder: (column) => column,
  );

  GeneratedColumn<String> get adres =>
      $composableBuilder(column: $table.adres, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> isimSoyisim = const Value.absent(),
                Value<int> yas = const Value.absent(),
                Value<double> kilo = const Value.absent(),
                Value<String> doktor = const Value.absent(),
                Value<String> diyabetEgitimHemsiresi = const Value.absent(),
                Value<String> cepTelefonu = const Value.absent(),
                Value<String> adres = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                isimSoyisim: isimSoyisim,
                yas: yas,
                kilo: kilo,
                doktor: doktor,
                diyabetEgitimHemsiresi: diyabetEgitimHemsiresi,
                cepTelefonu: cepTelefonu,
                adres: adres,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> isimSoyisim = const Value.absent(),
                Value<int> yas = const Value.absent(),
                Value<double> kilo = const Value.absent(),
                Value<String> doktor = const Value.absent(),
                Value<String> diyabetEgitimHemsiresi = const Value.absent(),
                Value<String> cepTelefonu = const Value.absent(),
                Value<String> adres = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => ProfilesCompanion.insert(
                id: id,
                isimSoyisim: isimSoyisim,
                yas: yas,
                kilo: kilo,
                doktor: doktor,
                diyabetEgitimHemsiresi: diyabetEgitimHemsiresi,
                cepTelefonu: cepTelefonu,
                adres: adres,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;
typedef $$GlucoseRecordsTableCreateCompanionBuilder =
    GlucoseRecordsCompanion Function({
      Value<int> id,
      required DateTime tarih,
      Value<String?> ilacInsulinAdi,
      Value<int?> sabahAc,
      Value<int?> sabahTok,
      Value<int?> oglenAc,
      Value<int?> oglenTok,
      Value<int?> aksamAc,
      Value<int?> aksamTok,
      Value<int?> yatmadanOnce,
      Value<int?> gece03,
      Value<String?> notlar,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$GlucoseRecordsTableUpdateCompanionBuilder =
    GlucoseRecordsCompanion Function({
      Value<int> id,
      Value<DateTime> tarih,
      Value<String?> ilacInsulinAdi,
      Value<int?> sabahAc,
      Value<int?> sabahTok,
      Value<int?> oglenAc,
      Value<int?> oglenTok,
      Value<int?> aksamAc,
      Value<int?> aksamTok,
      Value<int?> yatmadanOnce,
      Value<int?> gece03,
      Value<String?> notlar,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$GlucoseRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $GlucoseRecordsTable> {
  $$GlucoseRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tarih => $composableBuilder(
    column: $table.tarih,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ilacInsulinAdi => $composableBuilder(
    column: $table.ilacInsulinAdi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sabahAc => $composableBuilder(
    column: $table.sabahAc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sabahTok => $composableBuilder(
    column: $table.sabahTok,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get oglenAc => $composableBuilder(
    column: $table.oglenAc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get oglenTok => $composableBuilder(
    column: $table.oglenTok,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get aksamAc => $composableBuilder(
    column: $table.aksamAc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get aksamTok => $composableBuilder(
    column: $table.aksamTok,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yatmadanOnce => $composableBuilder(
    column: $table.yatmadanOnce,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gece03 => $composableBuilder(
    column: $table.gece03,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notlar => $composableBuilder(
    column: $table.notlar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GlucoseRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $GlucoseRecordsTable> {
  $$GlucoseRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tarih => $composableBuilder(
    column: $table.tarih,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ilacInsulinAdi => $composableBuilder(
    column: $table.ilacInsulinAdi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sabahAc => $composableBuilder(
    column: $table.sabahAc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sabahTok => $composableBuilder(
    column: $table.sabahTok,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get oglenAc => $composableBuilder(
    column: $table.oglenAc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get oglenTok => $composableBuilder(
    column: $table.oglenTok,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get aksamAc => $composableBuilder(
    column: $table.aksamAc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get aksamTok => $composableBuilder(
    column: $table.aksamTok,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yatmadanOnce => $composableBuilder(
    column: $table.yatmadanOnce,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gece03 => $composableBuilder(
    column: $table.gece03,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notlar => $composableBuilder(
    column: $table.notlar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GlucoseRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GlucoseRecordsTable> {
  $$GlucoseRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get tarih =>
      $composableBuilder(column: $table.tarih, builder: (column) => column);

  GeneratedColumn<String> get ilacInsulinAdi => $composableBuilder(
    column: $table.ilacInsulinAdi,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sabahAc =>
      $composableBuilder(column: $table.sabahAc, builder: (column) => column);

  GeneratedColumn<int> get sabahTok =>
      $composableBuilder(column: $table.sabahTok, builder: (column) => column);

  GeneratedColumn<int> get oglenAc =>
      $composableBuilder(column: $table.oglenAc, builder: (column) => column);

  GeneratedColumn<int> get oglenTok =>
      $composableBuilder(column: $table.oglenTok, builder: (column) => column);

  GeneratedColumn<int> get aksamAc =>
      $composableBuilder(column: $table.aksamAc, builder: (column) => column);

  GeneratedColumn<int> get aksamTok =>
      $composableBuilder(column: $table.aksamTok, builder: (column) => column);

  GeneratedColumn<int> get yatmadanOnce => $composableBuilder(
    column: $table.yatmadanOnce,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gece03 =>
      $composableBuilder(column: $table.gece03, builder: (column) => column);

  GeneratedColumn<String> get notlar =>
      $composableBuilder(column: $table.notlar, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GlucoseRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GlucoseRecordsTable,
          GlucoseRecord,
          $$GlucoseRecordsTableFilterComposer,
          $$GlucoseRecordsTableOrderingComposer,
          $$GlucoseRecordsTableAnnotationComposer,
          $$GlucoseRecordsTableCreateCompanionBuilder,
          $$GlucoseRecordsTableUpdateCompanionBuilder,
          (
            GlucoseRecord,
            BaseReferences<_$AppDatabase, $GlucoseRecordsTable, GlucoseRecord>,
          ),
          GlucoseRecord,
          PrefetchHooks Function()
        > {
  $$GlucoseRecordsTableTableManager(
    _$AppDatabase db,
    $GlucoseRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GlucoseRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GlucoseRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GlucoseRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> tarih = const Value.absent(),
                Value<String?> ilacInsulinAdi = const Value.absent(),
                Value<int?> sabahAc = const Value.absent(),
                Value<int?> sabahTok = const Value.absent(),
                Value<int?> oglenAc = const Value.absent(),
                Value<int?> oglenTok = const Value.absent(),
                Value<int?> aksamAc = const Value.absent(),
                Value<int?> aksamTok = const Value.absent(),
                Value<int?> yatmadanOnce = const Value.absent(),
                Value<int?> gece03 = const Value.absent(),
                Value<String?> notlar = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => GlucoseRecordsCompanion(
                id: id,
                tarih: tarih,
                ilacInsulinAdi: ilacInsulinAdi,
                sabahAc: sabahAc,
                sabahTok: sabahTok,
                oglenAc: oglenAc,
                oglenTok: oglenTok,
                aksamAc: aksamAc,
                aksamTok: aksamTok,
                yatmadanOnce: yatmadanOnce,
                gece03: gece03,
                notlar: notlar,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime tarih,
                Value<String?> ilacInsulinAdi = const Value.absent(),
                Value<int?> sabahAc = const Value.absent(),
                Value<int?> sabahTok = const Value.absent(),
                Value<int?> oglenAc = const Value.absent(),
                Value<int?> oglenTok = const Value.absent(),
                Value<int?> aksamAc = const Value.absent(),
                Value<int?> aksamTok = const Value.absent(),
                Value<int?> yatmadanOnce = const Value.absent(),
                Value<int?> gece03 = const Value.absent(),
                Value<String?> notlar = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => GlucoseRecordsCompanion.insert(
                id: id,
                tarih: tarih,
                ilacInsulinAdi: ilacInsulinAdi,
                sabahAc: sabahAc,
                sabahTok: sabahTok,
                oglenAc: oglenAc,
                oglenTok: oglenTok,
                aksamAc: aksamAc,
                aksamTok: aksamTok,
                yatmadanOnce: yatmadanOnce,
                gece03: gece03,
                notlar: notlar,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GlucoseRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GlucoseRecordsTable,
      GlucoseRecord,
      $$GlucoseRecordsTableFilterComposer,
      $$GlucoseRecordsTableOrderingComposer,
      $$GlucoseRecordsTableAnnotationComposer,
      $$GlucoseRecordsTableCreateCompanionBuilder,
      $$GlucoseRecordsTableUpdateCompanionBuilder,
      (
        GlucoseRecord,
        BaseReferences<_$AppDatabase, $GlucoseRecordsTable, GlucoseRecord>,
      ),
      GlucoseRecord,
      PrefetchHooks Function()
    >;
typedef $$MedicationsTableCreateCompanionBuilder =
    MedicationsCompanion Function({
      Value<int> id,
      required String ilacAdi,
      Value<String> doz,
      Value<String> hatirlatmaSaati,
      Value<bool> aktif,
      Value<String?> notlar,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$MedicationsTableUpdateCompanionBuilder =
    MedicationsCompanion Function({
      Value<int> id,
      Value<String> ilacAdi,
      Value<String> doz,
      Value<String> hatirlatmaSaati,
      Value<bool> aktif,
      Value<String?> notlar,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$MedicationsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ilacAdi => $composableBuilder(
    column: $table.ilacAdi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doz => $composableBuilder(
    column: $table.doz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hatirlatmaSaati => $composableBuilder(
    column: $table.hatirlatmaSaati,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get aktif => $composableBuilder(
    column: $table.aktif,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notlar => $composableBuilder(
    column: $table.notlar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ilacAdi => $composableBuilder(
    column: $table.ilacAdi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doz => $composableBuilder(
    column: $table.doz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hatirlatmaSaati => $composableBuilder(
    column: $table.hatirlatmaSaati,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get aktif => $composableBuilder(
    column: $table.aktif,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notlar => $composableBuilder(
    column: $table.notlar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ilacAdi =>
      $composableBuilder(column: $table.ilacAdi, builder: (column) => column);

  GeneratedColumn<String> get doz =>
      $composableBuilder(column: $table.doz, builder: (column) => column);

  GeneratedColumn<String> get hatirlatmaSaati => $composableBuilder(
    column: $table.hatirlatmaSaati,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get aktif =>
      $composableBuilder(column: $table.aktif, builder: (column) => column);

  GeneratedColumn<String> get notlar =>
      $composableBuilder(column: $table.notlar, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MedicationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationsTable,
          Medication,
          $$MedicationsTableFilterComposer,
          $$MedicationsTableOrderingComposer,
          $$MedicationsTableAnnotationComposer,
          $$MedicationsTableCreateCompanionBuilder,
          $$MedicationsTableUpdateCompanionBuilder,
          (
            Medication,
            BaseReferences<_$AppDatabase, $MedicationsTable, Medication>,
          ),
          Medication,
          PrefetchHooks Function()
        > {
  $$MedicationsTableTableManager(_$AppDatabase db, $MedicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> ilacAdi = const Value.absent(),
                Value<String> doz = const Value.absent(),
                Value<String> hatirlatmaSaati = const Value.absent(),
                Value<bool> aktif = const Value.absent(),
                Value<String?> notlar = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MedicationsCompanion(
                id: id,
                ilacAdi: ilacAdi,
                doz: doz,
                hatirlatmaSaati: hatirlatmaSaati,
                aktif: aktif,
                notlar: notlar,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String ilacAdi,
                Value<String> doz = const Value.absent(),
                Value<String> hatirlatmaSaati = const Value.absent(),
                Value<bool> aktif = const Value.absent(),
                Value<String?> notlar = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => MedicationsCompanion.insert(
                id: id,
                ilacAdi: ilacAdi,
                doz: doz,
                hatirlatmaSaati: hatirlatmaSaati,
                aktif: aktif,
                notlar: notlar,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationsTable,
      Medication,
      $$MedicationsTableFilterComposer,
      $$MedicationsTableOrderingComposer,
      $$MedicationsTableAnnotationComposer,
      $$MedicationsTableCreateCompanionBuilder,
      $$MedicationsTableUpdateCompanionBuilder,
      (
        Medication,
        BaseReferences<_$AppDatabase, $MedicationsTable, Medication>,
      ),
      Medication,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$GlucoseRecordsTableTableManager get glucoseRecords =>
      $$GlucoseRecordsTableTableManager(_db, _db.glucoseRecords);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
}
