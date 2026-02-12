import '../core/constants.dart';

/// Kan şekeri ölçüm değeri validasyonu.
String? validateGlucose(String? value) {
  if (value == null || value.trim().isEmpty) return null; // nullable alan
  final parsed = int.tryParse(value.trim());
  if (parsed == null || parsed < kGlucoseMin || parsed > kGlucoseMax) {
    return Tr.gecersizDeger;
  }
  return null;
}

/// En az bir ölçüm alanının dolu olup olmadığını kontrol eder.
bool hasAtLeastOneMeasurement(List<int?> values) {
  return values.any((v) => v != null);
}

/// Gelecek tarih kontrolü.
bool isFutureDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final check = DateTime(date.year, date.month, date.day);
  return check.isAfter(today);
}

/// Yaş validasyonu (1–150).
String? validateAge(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parsed = int.tryParse(value.trim());
  if (parsed == null || parsed < 1 || parsed > 150) {
    return 'Geçerli bir yaş giriniz (1–150).';
  }
  return null;
}

/// Kilo validasyonu (1–500 kg).
String? validateWeight(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parsed = double.tryParse(value.trim());
  if (parsed == null || parsed < 1 || parsed > 500) {
    return 'Geçerli bir kilo giriniz (1–500 kg).';
  }
  return null;
}

/// Telefon numarası validasyonu (boş bırakılabilir).
String? validatePhone(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  if (cleaned.length < 7 || cleaned.length > 15) {
    return 'Geçerli bir telefon numarası giriniz.';
  }
  return null;
}
