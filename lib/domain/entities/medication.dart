/// İlaç domain entity.
class MedicationEntity {
  final int? id;
  final String ilacAdi;
  final String doz;
  final String hatirlatmaSaati; // "HH:mm" formatı
  final bool aktif;
  final String? notlar;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MedicationEntity({
    this.id,
    required this.ilacAdi,
    this.doz = '',
    this.hatirlatmaSaati = '',
    this.aktif = true,
    this.notlar,
    required this.createdAt,
    required this.updatedAt,
  });

  MedicationEntity copyWith({
    int? id,
    String? ilacAdi,
    String? doz,
    String? hatirlatmaSaati,
    bool? aktif,
    String? notlar,
    bool clearNotlar = false,
    DateTime? updatedAt,
  }) {
    return MedicationEntity(
      id: id ?? this.id,
      ilacAdi: ilacAdi ?? this.ilacAdi,
      doz: doz ?? this.doz,
      hatirlatmaSaati: hatirlatmaSaati ?? this.hatirlatmaSaati,
      aktif: aktif ?? this.aktif,
      notlar: clearNotlar ? null : (notlar ?? this.notlar),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Hatırlatma saatini TimeOfDay benzeri çözümle.
  int get saatHour {
    if (hatirlatmaSaati.isEmpty) return 8;
    final parts = hatirlatmaSaati.split(':');
    return int.tryParse(parts[0]) ?? 8;
  }

  int get saatMinute {
    if (hatirlatmaSaati.isEmpty) return 0;
    final parts = hatirlatmaSaati.split(':');
    return parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'ilacAdi': ilacAdi,
    'doz': doz,
    'hatirlatmaSaati': hatirlatmaSaati,
    'aktif': aktif ? 1 : 0,
    'notlar': notlar,
    'createdAt': createdAt.toUtc().millisecondsSinceEpoch,
    'updatedAt': updatedAt.toUtc().millisecondsSinceEpoch,
  };

  factory MedicationEntity.fromMap(Map<String, dynamic> map) {
    return MedicationEntity(
      id: map['id'] as int?,
      ilacAdi: map['ilacAdi'] as String? ?? '',
      doz: map['doz'] as String? ?? '',
      hatirlatmaSaati: map['hatirlatmaSaati'] as String? ?? '',
      aktif: (map['aktif'] as int?) == 1,
      notlar: map['notlar'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] as int,
        isUtc: true,
      ).toLocal(),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updatedAt'] as int,
        isUtc: true,
      ).toLocal(),
    );
  }
}
