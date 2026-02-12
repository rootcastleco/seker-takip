import 'dart:io';
import 'package:path/path.dart' as p;
import '../constants.dart';

/// Dosyaya rotasyonlu log yazımı.
class FileLogSink {
  FileLogSink(this._logDir);

  final String _logDir;
  File? _currentFile;
  IOSink? _sink;

  Future<void> init() async {
    final dir = Directory(_logDir);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    _currentFile = File(p.join(_logDir, 'app.log'));
    _sink = _currentFile!.openWrite(mode: FileMode.append);
  }

  Future<void> write(String line) async {
    if (_sink == null) await init();
    _sink!.writeln(line);

    // Rotasyon kontrolü
    if (_currentFile != null && _currentFile!.existsSync()) {
      final size = await _currentFile!.length();
      if (size > kLogMaxFileSize) {
        await _rotate();
      }
    }
  }

  Future<void> _rotate() async {
    await _sink?.flush();
    await _sink?.close();

    // Eski dosyaları kaydır
    for (var i = kLogMaxFiles - 1; i >= 1; i--) {
      final older = File(p.join(_logDir, 'app.$i.log'));
      final newer = i == 1
          ? File(p.join(_logDir, 'app.log'))
          : File(p.join(_logDir, 'app.${i - 1}.log'));
      if (newer.existsSync()) {
        if (older.existsSync()) await older.delete();
        await newer.rename(older.path);
      }
    }

    _currentFile = File(p.join(_logDir, 'app.log'));
    _sink = _currentFile!.openWrite(mode: FileMode.append);
  }

  Future<List<String>> readLastLines(int count) async {
    final file = File(p.join(_logDir, 'app.log'));
    if (!file.existsSync()) return [];
    final lines = await file.readAsLines();
    if (lines.length <= count) return lines;
    return lines.sublist(lines.length - count);
  }

  Future<String> readAll() async {
    final file = File(p.join(_logDir, 'app.log'));
    if (!file.existsSync()) return '';
    return file.readAsString();
  }

  Future<void> dispose() async {
    await _sink?.flush();
    await _sink?.close();
  }
}
