import 'dart:convert';

/// Canonical JSON: alan sırası sabit, null alanlar dahil.
/// Deterministik serileştirme için JSON'un her seferinde
/// aynı byte dizisini üretmesi gerekir.
String canonicalJsonEncode(Map<String, dynamic> data) {
  final sorted = _sortMap(data);
  return const JsonEncoder(null).convert(sorted);
}

/// Canonical JSON byte dizisi (UTF-8).
List<int> canonicalJsonBytes(Map<String, dynamic> data) {
  return utf8.encode(canonicalJsonEncode(data));
}

/// Map'i anahtar sırasına göre recursive sıralar.
Map<String, dynamic> _sortMap(Map<String, dynamic> map) {
  final sorted = <String, dynamic>{};
  final keys = map.keys.toList()..sort();
  for (final key in keys) {
    final value = map[key];
    if (value is Map<String, dynamic>) {
      sorted[key] = _sortMap(value);
    } else if (value is List) {
      sorted[key] = value.map((e) {
        if (e is Map<String, dynamic>) return _sortMap(e);
        return e;
      }).toList();
    } else {
      sorted[key] = value;
    }
  }
  return sorted;
}
