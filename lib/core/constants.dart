/// REI Şeker Takip — Türkçe UI sabitleri ve uygulama limitleri.

// ─── Uygulama ────────────────────────────────────────────
const String kAppName = 'REI Şeker Takip';
const String kAppVersion = '2.0.0';

// ─── Ölçüm limitleri (mg/dL) ────────────────────────────
const int kGlucoseMin = 20;
const int kGlucoseMax = 600;

// ─── Hedefler ────────────────────────────────────────────
const int kTargetAksFasting = 100; // AKŞ < 100
const int kTargetPostprandial = 140; // TKŞ < 140

// ─── eA1c ────────────────────────────────────────────────
const int kEa1cMinRecords = 15;
const int kEa1cDayRange = 90;

// ─── Schema ──────────────────────────────────────────────
const int kSchemaVersion = 1;

// ─── Log ─────────────────────────────────────────────────
const int kLogMaxFileSize = 1024 * 1024; // 1 MB
const int kLogMaxFiles = 5;
const int kLogUiLineCount = 200;

// ─── Export ──────────────────────────────────────────────
const String kExportPrefix = 'rei_seker_takip';

// ─── Bildirim ────────────────────────────────────────────
const String kNotifChannelId = 'rei_tokluk';
const String kNotifChannelName = 'Tokluk Hatırlatıcısı';
const int kNotifIlacId = 1003;
const String kNotifIlacChannelId = 'rei_ilac';
const String kNotifIlacChannelName = 'İlaç Hatırlatıcısı';
const String kPayloadIlacReminder = 'PAYLOAD_ILAC_REMINDER';
const int kNotifToklukId = 1001;
const int kNotifAclikId = 1002;
const int kToklukRemindMinutes = 120;

// ─── Bildirim Payload'ları ───────────────────────────────
const String kPayloadToklukReminder = 'PAYLOAD_TOKLUK_REMINDER';
const String kPayloadAclikReminder = 'PAYLOAD_ACLIK_REMINDER';

// ─── Türkçe UI metinleri ─────────────────────────────────
class Tr {
  Tr._();

  // Genel
  static const String kaydet = 'Kaydet';
  static const String guncelle = 'Güncelle';
  static const String sil = 'Sil';
  static const String iptal = 'İptal';
  static const String tamam = 'Tamam';
  static const String evet = 'Evet';
  static const String hayir = 'Hayır';
  static const String hata = 'Hata';
  static const String basarili = 'Başarılı';
  static const String uyari = 'Uyarı';
  static const String yukle = 'Yükleniyor...';

  // Dashboard
  static const String anaSayfa = 'Ana Sayfa';
  static const String bugunOzet = 'Bugünün Özeti';
  static const String son7Gun = 'Son 7 Gün Ortalaması';
  static const String yeniKayitEkle = 'Yeni Kayıt Ekle';
  static const String kayitlar = 'Kayıtlar';
  static const String disaAktar = 'Dışa Aktar';
  static const String iceAktar = 'İçe Aktar';
  static const String kisiselBilgiler = 'Kişisel Bilgiler';
  static const String idealHedefler = 'İdeal Hedefler';
  static const String tanilamaLoglari = 'Tanılama';

  // Profil
  static const String isimSoyisim = 'İsim / Soyisim';
  static const String yas = 'Yaş';
  static const String kilo = 'Kilo (kg)';
  static const String doktor = 'Doktor';
  static const String diyabetEgitimHemsiresi = 'Diyabet Eğitim Hemşiresi';
  static const String cepTelefonu = 'Cep Telefonu';
  static const String adres = 'Adres';
  static const String profilKaydedildi = 'Profil kaydedildi.';

  // Kayıt Formu
  static const String tarih = 'Tarih';
  static const String ilacInsulinAdi = 'İlaç / İnsülin Adı';
  static const String sabahAc = 'Sabah Açlık';
  static const String sabahTok = 'Sabah Tokluk (2s)';
  static const String oglenAc = 'Öğlen Açlık';
  static const String oglenTok = 'Öğlen Tokluk (2s)';
  static const String aksamAc = 'Akşam Açlık';
  static const String aksamTok = 'Akşam Tokluk (2s)';
  static const String yatmadanOnce = 'Yatmadan Önce';
  static const String gece03 = 'Gece 03:00';
  static const String notlar = 'Not';
  static const String mgDl = 'mg/dL';

  // Validasyon
  static const String enAzBirOlcum = 'En az bir ölçüm alanı doldurulmalıdır.';
  static const String gecersizDeger =
      'Geçersiz değer. $kGlucoseMin–$kGlucoseMax mg/dL aralığında olmalıdır.';
  static const String gelecekTarih = 'Gelecek tarih seçilemez.';
  static const String silOnay = 'Bu kaydı silmek istediğinize emin misiniz?';
  static const String kayitSilindi = 'Kayıt silindi.';
  static const String kayitKaydedildi = 'Kayıt kaydedildi.';
  static const String kayitGuncellendi = 'Kayıt güncellendi.';

  // Tablo
  static const String tarihKolonu = 'Tarih';
  static const String hedefDisi = 'Hedef dışı olabilir.';
  static const String kayitBulunamadi = 'Kayıt bulunamadı.';
  static const String filtre = 'Filtre';
  static const String baslangic = 'Başlangıç';
  static const String bitis = 'Bitiş';
  static const String temizle = 'Temizle';

  // Export
  static const String dosyaOlusturuldu = 'Dosya oluşturuldu.';
  static const String paylas = 'Paylaş';
  static const String dosyayiAc = 'Dosyayı Aç';
  static const String tumKayitlar = 'Tüm Kayıtlar';
  static const String tarihAraligi = 'Tarih Aralığı';
  static const String formatSec = 'Format Seç';
  static const String csvFormat = 'CSV';
  static const String xlsxFormat = 'Excel (XLSX)';
  static const String jsonBackup = 'JSON Yedek';
  static const String pdfRapor = 'PDF Rapor';
  static const String pdfSubtitle = 'Profesyonel hasta raporu';

  // Import
  static const String dosyaSec = 'Dosya Seç';
  static const String importBasarili = 'İçe aktarma başarılı.';
  static const String importHata = 'İçe aktarma sırasında hata oluştu.';
  static const String checksumHata =
      'Dosya bozuk veya kurcalanmış olabilir. Checksum uyuşmuyor.';
  static const String semaUyumsuz = 'Bu yedek sürümü desteklenmiyor.';
  static const String birlestir = 'Birleştir (Merge)';
  static const String ustYaz = 'Üzerine Yaz (Replace)';
  static const String importOzet = 'İçe Aktarma Özeti';
  static const String kayitSayisi = 'Kayıt Sayısı';
  static const String exportTarihi = 'Yedekleme Tarihi';
  static const String importMod = 'İçe Aktarma Modu';

  // Hedefler
  static const String hedeflerBaslik = 'Diyabette İdeal Hedefler';
  static const String hedeflerDipnot =
      'Bu değerler özel durumlarda (eşlik eden hastalık, yaş vs.) değişebilir.';

  // Diagnostics
  static const String loglariGor = 'Logları Gör';
  static const String loglariPaylas = 'Logları Paylaş';
  static const String piiMaskele = 'Kişisel Verileri Maskele';

  // eA1c
  static const String ea1cBaslik = 'Tahmini HbA1c (eA1c)';
  static const String ea1cYetersiz =
      'En az $kEa1cMinRecords kayıt gerekli (son $kEa1cDayRange gün).';
  static const String ea1cFormul = 'eA1c = (Ortalama + 46.7) / 28.7';
  static const String ea1cBilgiNot =
      'Laboratuvar HbA1c yerine geçmez. Doktorunuza danışın.';

  // Glukoz Değişkenliği (SD)
  static const String stabiliteBaslik = 'Stabilite Göstergesi';
  static const String stabiliteDusuk = 'Stabil (Düşük Değişkenlik)';
  static const String stabiliteOrta = 'Orta Değişkenlik';
  static const String stabiliteYuksek = 'Yüksek Değişkenlik';
  static const String stabiliteYetersiz = 'Yeterli veri yok.';
  static const String standartSapma = 'Std. Sapma';

  // Bildirimler
  static const String toklukHatirlatSorusu =
      'Tokluk hatırlatıcısı kurulsun mu? (2 saat sonra)';
  static const String toklukBildirimi =
      '⏰ Tokluk ölçümü zamanı! Yemekten 2 saat geçti.';
  static const String bildirimIzniYok = 'Bildirim izni verilmedi.';

  // Hakkında
  static const String hakkinda = 'Hakkında';
  static const String gelistirici = 'Geliştirici';
  static const String gelistiriciAdi = 'Batuhan Ayrıbaş';
  static const String webSitesi = 'rootcastle.com';
  static const String uygulamaAciklama =
      'REI Şeker Takip, Tip 1 ve Tip 2 diyabet hastaları için '
      'geliştirilmiş tam Türkçe, çevrimdışı, reklamsız kan şekeri takip uygulamasıdır.';

  // Ayarlar / Kullanım Kılavuzu
  static const String ayarlar = 'Ayarlar';
  static const String nasilKullanilir = 'Nasıl Kullanılır?';
  static const String kullanimKilavuzu = 'Kullanım Kılavuzu';

  // Bottom Navigation
  static const String tabAnaSayfa = 'Ana Sayfa';
  static const String tabKayitDefteri = 'Kayıt Defteri';
  static const String tabAnaliz = 'Analiz';
  static const String tabAyarlar = 'Ayarlar';

  // Consolidated Settings
  static const String profilBilgileri = 'Profil Bilgileri';
  static const String yedeklemeMerkezi = 'Yedekleme Merkezi';
  static const String raporlama = 'Raporlama';
  static const String sesliAsistan = 'Sesli Asistan';
  static const String sesliAsistanAciklama =
      'Kayıt sonrası sesli geri bildirim';

  // Charts / Analysis
  static const String analizBaslik = 'Analiz & Grafikler';
  static const String gunlukTrend = 'Günlük Trend';
  static const String haftalikOrtalama = 'Haftalık Ortalama';
  static const String veriYok = 'Henüz yeterli veri yok.';
  static const String sonOlcumler = 'Son Ölçümler';

  // Voice Scripts
  static const String sesKarsilama = 'REI sağlığınızı düşünür.';
  static const String sesOlcumHatirlatma = 'Hey, şekerini ölçmen lazım.';
  static const String sesIlacHatirlatma =
      'İlaç zamanı geldi. İlacını almayı unutma.';

  // Medication / İlaç
  static const String ilacEkle = 'İlaç Ekle';
  static const String ilacAdi = 'İlaç Adı';
  static const String ilacDozu = 'Doz';
  static const String ilacSaati = 'Hatırlatma Saati';
  static const String ilacListesi = 'İlaçlarım';
  static const String ilacHatirlatici = 'İlaç Hatırlatıcısı';
  static const String ilacKaydedildi = 'İlaç kaydedildi.';
  static const String ilacSilindi = 'İlaç silindi.';
  static const String ilacYok = 'Henüz ilaç eklenmemiş.';

  // PDF Rapor
  static const String pdfRaporBaslik = 'Kan Şekeri Takip Raporu';
  static const String pdfHastaBilgi = 'Hasta Bilgileri';
  static const String pdfOlcumTablosu = 'Ölçüm Tablosu';
  static const String pdfOzet = 'Genel Özet';
  static const String pdfOrtalamaGlukoz = 'Ortalama Glukoz';
  static const String pdfToplamKayit = 'Toplam Kayıt';
  static const String pdfHedefDisiBilgi = 'Kırmızı değerler hedef dışıdır.';
  static const String pdfOlusturmaTarihi = 'Rapor Tarihi';
  static const String pdfHeaderOrg = 'REI Medical Systems';
  static const String pdfFooterGen = 'Generated by REI Şeker Takip';

  // Sistem Sesi (TTS)
  static const String sesSistemBaslatildi = 'Sistem sesi aktif.';
  static const String sesCihazSessiz =
      'Cihaz sessiz modda. Sesli geri bildirim devre dışı.';

  // Sofia AI
  static const String sofiaAi = 'Sofia AI';
  static const String sofiaAiAciklama = 'Yapay zeka sağlık asistanı';
  static const String sofiaAiSor = "Sofia'ya sor...";

  // OCR Tarayıcı (Rootcastle Vision)
  static const String kamerayiTara = 'Kamerayla Tara';
  static const String tarayiciBaslik = 'REI Vision';
  static const String tarayiciHizala = 'Cihaz ekranını kutucuğa hizalayın.';
  static const String tarayiciAraniyor = 'Ölçüm aranıyor...';
  static const String tarayiciAlgilandi = 'Ölçüm algılandı';
  static const String tarayiciOnay = 'Onaylıyor musunuz?';
  static const String yenidenTara = 'Yeniden Tara';
  static const String onaylaKaydet = 'ONAYLA';
  static const String kameraIzniGerekli =
      'Ölçüm cihazını okumak için kamera izni gerekiyor.';
  static const String kameraIzniReddedildi =
      'Kamera izni reddedildi. Ayarlardan izin verebilirsiniz.';
  static const String gorusSistemiDevreDisi =
      'Görüş sistemi devre dışı. Manuel giriş yapınız.';
  static const String sesOlcumAlgilandi = 'Ölçüm algılandı:';
  static const String sesOnayBekliyor = 'Onaylıyor musunuz?';
}
