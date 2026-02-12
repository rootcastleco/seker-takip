/// PII (Kişisel Tanımlanabilir Bilgi) maskeleme.

/// İsim maskeleme: İlk 3 karakter + ***.
String maskName(String name) {
  if (name.isEmpty) return '';
  if (name.length <= 3) return '${name[0]}***';
  return '${name.substring(0, 3)}***';
}

/// Telefon maskeleme: İlk 4 + ****** + son 2.
String maskPhone(String phone) {
  if (phone.isEmpty) return '';
  final cleaned = phone.replaceAll(RegExp(r'\s'), '');
  if (cleaned.length <= 6) return '${cleaned.substring(0, 2)}****';
  return '${cleaned.substring(0, 4)}******${cleaned.substring(cleaned.length - 2)}';
}

/// Adres maskeleme: İlk 5 karakter + ***.
String maskAddress(String address) {
  if (address.isEmpty) return '';
  if (address.length <= 5) return '***';
  return '${address.substring(0, 5)}***';
}

/// Genel string maskeleme: Belirtilen alan adlarını maskeler.
String maskPii(String text) {
  var result = text;
  // Telefon numarası benzeri kalıplar
  result = result.replaceAllMapped(
    RegExp(r'(\+?\d{2,4})(\d{4,})(\d{2})'),
    (m) => '${m.group(1)}******${m.group(3)}',
  );
  return result;
}
