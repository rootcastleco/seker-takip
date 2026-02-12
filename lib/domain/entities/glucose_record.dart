/// Kan şekeri kaydı domain entity.
class GlucoseRecordEntity {
  final int? id;
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

  const GlucoseRecordEntity({
    this.id,
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

  /// Tüm ölçüm alanlarının listesi (validasyon için).
  List<int?> get allMeasurements => [
    sabahAc,
    sabahTok,
    oglenAc,
    oglenTok,
    aksamAc,
    aksamTok,
    yatmadanOnce,
    gece03,
  ];

  GlucoseRecordEntity copyWith({
    int? id,
    DateTime? tarih,
    String? ilacInsulinAdi,
    int? sabahAc,
    int? sabahTok,
    int? oglenAc,
    int? oglenTok,
    int? aksamAc,
    int? aksamTok,
    int? yatmadanOnce,
    int? gece03,
    String? notlar,
    DateTime? updatedAt,
    bool clearIlac = false,
    bool clearNot = false,
  }) {
    return GlucoseRecordEntity(
      id: id ?? this.id,
      tarih: tarih ?? this.tarih,
      ilacInsulinAdi: clearIlac
          ? null
          : (ilacInsulinAdi ?? this.ilacInsulinAdi),
      sabahAc: sabahAc ?? this.sabahAc,
      sabahTok: sabahTok ?? this.sabahTok,
      oglenAc: oglenAc ?? this.oglenAc,
      oglenTok: oglenTok ?? this.oglenTok,
      aksamAc: aksamAc ?? this.aksamAc,
      aksamTok: aksamTok ?? this.aksamTok,
      yatmadanOnce: yatmadanOnce ?? this.yatmadanOnce,
      gece03: gece03 ?? this.gece03,
      notlar: clearNot ? null : (notlar ?? this.notlar),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'tarih': tarih.toUtc().millisecondsSinceEpoch,
    'ilacInsulinAdi': ilacInsulinAdi,
    'sabahAc': sabahAc,
    'sabahTok': sabahTok,
    'oglenAc': oglenAc,
    'oglenTok': oglenTok,
    'aksamAc': aksamAc,
    'aksamTok': aksamTok,
    'yatmadanOnce': yatmadanOnce,
    'gece03': gece03,
    'notlar': notlar,
    'createdAt': createdAt.toUtc().millisecondsSinceEpoch,
    'updatedAt': updatedAt.toUtc().millisecondsSinceEpoch,
  };

  factory GlucoseRecordEntity.fromMap(Map<String, dynamic> map) {
    return GlucoseRecordEntity(
      id: (map['id'] as num?)?.toInt(),
      tarih: DateTime.fromMillisecondsSinceEpoch(
        (map['tarih'] as num).toInt(),
        isUtc: true,
      ),
      ilacInsulinAdi: map['ilacInsulinAdi'] as String?,
      sabahAc: (map['sabahAc'] as num?)?.toInt(),
      sabahTok: (map['sabahTok'] as num?)?.toInt(),
      oglenAc: (map['oglenAc'] as num?)?.toInt(),
      oglenTok: (map['oglenTok'] as num?)?.toInt(),
      aksamAc: (map['aksamAc'] as num?)?.toInt(),
      aksamTok: (map['aksamTok'] as num?)?.toInt(),
      yatmadanOnce: (map['yatmadanOnce'] as num?)?.toInt(),
      gece03: (map['gece03'] as num?)?.toInt(),
      notlar: map['notlar'] as String?,
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
}
