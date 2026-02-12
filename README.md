# Rootcastle Kan Şekeri Takip

**Architect:** Batuhan Ayrıbaş  
**Brand:** [Rootcastle](https://rootcastle.com/)  
**Platform:** Flutter (Android / iOS)  
**Version:** 1.1.0

---

## Proje Hakkında

Rootcastle Kan Şekeri Takip, Tip 1 ve Tip 2 diyabet hastaları için geliştirilmiş tam Türkçe, çevrimdışı, reklamsız kan şekeri takip uygulamasıdır.

### Temel Prensipler
- **Offline-First:** Tüm veriler cihazda saklanır, internet gerektirmez.
- **Deterministik:** SHA-256 checksum korumalı yedekleme.
- **NASA-Standard Reliability:** Sıkı analiz kuralları, kapsamlı hata yakalama.

---

## Özellikler

| Özellik | Açıklama |
|---|---|
| Kan Şekeri Takibi | 8 farklı ölçüm (sabah açlık, tokluk, öğlen, akşam, gece) |
| Tahmini HbA1c (eA1c) | Son 90 günlük veriden otomatik hesaplama |
| Stabilite Göstergesi | Standart sapma (SD) ile glukoz değişkenlik analizi |
| Sistem Sesi (TTS) | Dinamik Türkçe sesli geri bildirim — Mainframe AI persona |
| OCR Tarayıcı | Kamerayla glucometer ekranını okuma (Rootcastle Vision) |
| Akıllı Hatırlatıcılar | Tokluk ölçüm hatırlatıcısı (2 saat) + bildirim payload |
| PDF Rapor | Profesyonel hasta raporu — doktora göstermek için ideal |
| Dışa Aktarma | CSV, Excel (XLSX), JSON yedek, PDF formatları |
| İçe Aktarma | SHA-256 checksum doğrulamalı JSON yedek |
| Karanlık Mod | Material 3 light/dark tema desteği |
| Tam Türkçe | Tüm arayüz, mesajlar ve sesli geri bildirim Türkçe |

---

## Mimari

```
lib/
├── app/              # App, Theme, Routes
├── core/
│   ├── checksum/     # SHA-256 + Canonical JSON
│   ├── logger/       # AppLogger, PII maskeleme, dosya rotasyonu
│   └── services/     # VoiceService (TTS), NotificationService
├── data/
│   ├── db/           # Drift: Tables, AppDatabase, DAOs
│   ├── export_import/ # CSV, XLSX, JSON Backup, PDF Report
│   └── repositories/ # ProfileRepo, GlucoseRepo
├── domain/
│   ├── entities/     # ProfileEntity, GlucoseRecordEntity
│   └── usecases/     # Ea1cCalculator, GlucoseVariability
├── features/
│   ├── dashboard/logic/  # GlucoseAnalyzer (Sesli analiz motoru)
│   └── scanner/          # Rootcastle Vision (OCR tarayıcı)
│       ├── logic/        # GlucoseOcrProcessor
│       └── presentation/ # ScanPage (kamera + ROI overlay)
└── presentation/
    ├── pages/        # Dashboard, Profile, RecordEdit, Records, Export,
    │                 # Import, Targets, Diagnostics, About, Settings
    ├── state/        # Riverpod Providers
    └── widgets/      # AppBar, RecordTable, DateRangePicker
```

---

## Sistem Sesi Protokolü

| Durum | Sesli Mesaj |
|---|---|
| Glukoz < 70 | "Kritik seviye tespit edildi. Hipoglisemi riski." |
| 70–100 | "Değerler nominal. Sistem stabil. Kayıt tamamlandı." |
| 101–140 | "Sınır değer. Takip protokolü devrede." |
| > 180 | "Yüksek glukoz uyarısı. İnsülin kontrolü gerekli." |
| SD > 40 | "Dikkat. Glikoz dalgalanması yüksek." |

---

## Teknolojiler

- **Flutter** (Stable) + **Dart** (null-safety)
- **Drift** — SQLite ORM (offline DB)
- **flutter_riverpod** — State management
- **flutter_tts** — Dinamik TTS (sistem sesi)
- **camera** + **google_mlkit_text_recognition** — Offline OCR tarayıcı
- **permission_handler** — Kamera izin yönetimi
- **flutter_local_notifications** — Bildirimler
- **pdf** — PDF rapor üretimi
- **excel** — XLSX export
- **crypto** — SHA-256 checksum

---

## Kurulum

```bash
git clone <repo_url>
cd seker-takip-1
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

---

## Lisans

Bu proje Batuhan Ayrıbaş tarafından geliştirilmiştir.  
© 2025–2026 Rootcastle. Tüm hakları saklıdır.