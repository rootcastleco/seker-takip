import 'dart:convert';
import 'package:crypto/crypto.dart';

/// SHA-256 hex digest hesaplama.
String sha256Hex(List<int> bytes) {
  return sha256.convert(bytes).toString();
}

/// String'den SHA-256 hex digest hesaplama.
String sha256HexFromString(String input) {
  return sha256Hex(utf8.encode(input));
}
