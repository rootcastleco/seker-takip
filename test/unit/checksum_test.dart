import 'package:flutter_test/flutter_test.dart';
import 'package:seker_takip/core/checksum/canonical_json.dart';
import 'package:seker_takip/core/checksum/sha256.dart';

void main() {
  group('canonicalJsonEncode', () {
    test('anahtarlar sıralı olmalı', () {
      final data = <String, dynamic>{'z': 1, 'a': 2, 'm': 3};
      final result = canonicalJsonEncode(data);
      expect(result, '{"a":2,"m":3,"z":1}');
    });

    test('iç içe map da sıralı olmalı', () {
      final data = <String, dynamic>{
        'b': <String, dynamic>{'z': 1, 'a': 2},
        'a': 'first',
      };
      final result = canonicalJsonEncode(data);
      expect(result, '{"a":"first","b":{"a":2,"z":1}}');
    });

    test('null değerler korunmalı', () {
      final data = <String, dynamic>{'a': null, 'b': 'val'};
      final result = canonicalJsonEncode(data);
      expect(result, '{"a":null,"b":"val"}');
    });

    test('liste elemanları sıralı map içerebilmeli', () {
      final data = <String, dynamic>{
        'list': [
          <String, dynamic>{'z': 1, 'a': 2},
        ],
      };
      final result = canonicalJsonEncode(data);
      expect(result, '{"list":[{"a":2,"z":1}]}');
    });

    test('deterministik: aynı giriş her seferinde aynı çıktı', () {
      final data = <String, dynamic>{
        'schemaVersion': 1,
        'records': <dynamic>[],
        'checksum': 'abc',
      };
      final r1 = canonicalJsonEncode(data);
      final r2 = canonicalJsonEncode(data);
      expect(r1, r2);
    });
  });

  group('sha256Hex', () {
    test('boş string hash', () {
      final hash = sha256HexFromString('');
      expect(
        hash,
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
    });

    test('hello world hash', () {
      final hash = sha256HexFromString('hello world');
      expect(
        hash,
        'b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9',
      );
    });

    test('hash 64 karakter hex olmalı', () {
      final hash = sha256HexFromString('test');
      expect(hash.length, 64);
      expect(RegExp(r'^[a-f0-9]+$').hasMatch(hash), isTrue);
    });
  });
}
