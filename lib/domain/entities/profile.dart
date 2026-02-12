/// Profil domain entity.
class ProfileEntity {
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

  const ProfileEntity({
    this.id = 1,
    this.isimSoyisim = '',
    this.yas = 0,
    this.kilo = 0.0,
    this.doktor = '',
    this.diyabetEgitimHemsiresi = '',
    this.cepTelefonu = '',
    this.adres = '',
    required this.createdAt,
    required this.updatedAt,
  });

  ProfileEntity copyWith({
    String? isimSoyisim,
    int? yas,
    double? kilo,
    String? doktor,
    String? diyabetEgitimHemsiresi,
    String? cepTelefonu,
    String? adres,
    DateTime? updatedAt,
  }) {
    return ProfileEntity(
      id: id,
      isimSoyisim: isimSoyisim ?? this.isimSoyisim,
      yas: yas ?? this.yas,
      kilo: kilo ?? this.kilo,
      doktor: doktor ?? this.doktor,
      diyabetEgitimHemsiresi:
          diyabetEgitimHemsiresi ?? this.diyabetEgitimHemsiresi,
      cepTelefonu: cepTelefonu ?? this.cepTelefonu,
      adres: adres ?? this.adres,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'isimSoyisim': isimSoyisim,
    'yas': yas,
    'kilo': kilo,
    'doktor': doktor,
    'diyabetEgitimHemsiresi': diyabetEgitimHemsiresi,
    'cepTelefonu': cepTelefonu,
    'adres': adres,
    'createdAt': createdAt.toUtc().millisecondsSinceEpoch,
    'updatedAt': updatedAt.toUtc().millisecondsSinceEpoch,
  };

  factory ProfileEntity.fromMap(Map<String, dynamic> map) {
    return ProfileEntity(
      id: (map['id'] as num?)?.toInt() ?? 1,
      isimSoyisim: map['isimSoyisim'] as String? ?? '',
      yas: (map['yas'] as num?)?.toInt() ?? 0,
      kilo: (map['kilo'] as num?)?.toDouble() ?? 0.0,
      doktor: map['doktor'] as String? ?? '',
      diyabetEgitimHemsiresi: map['diyabetEgitimHemsiresi'] as String? ?? '',
      cepTelefonu: map['cepTelefonu'] as String? ?? '',
      adres: map['adres'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num).toInt(),
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['updatedAt'] as num).toInt(),
        isUtc: true,
      ),
    );
  }

  factory ProfileEntity.empty() {
    final now = DateTime.now();
    return ProfileEntity(createdAt: now, updatedAt: now);
  }
}
