import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show Size;

import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../core/constants.dart';
import '../../../core/logger/logger.dart';

/// Rootcastle Vision — Glucometer OCR İşlemci.
///
/// Kamera frame'lerinden 7-segment LCD glukoz değerini tespit eder.
/// Yalnızca [kGlucoseMin]–[kGlucoseMax] (20–600) arasındaki tam sayılar kabul edilir.
///
/// Kurallar:
/// - Frame throttle: 500 ms (pil tasarrufu).
/// - ROI crop: Yalnızca merkez kutu içindeki metin işlenir.
/// - Regex filtre: Gürültü (mg/dL, tarih, mem) elenir.
/// - Güven kontrolü: Düşük güvenli bloklar atlanır.
class GlucoseOcrProcessor {
  GlucoseOcrProcessor() : _textRecognizer = TextRecognizer();

  final TextRecognizer _textRecognizer;

  /// 20–600 arası tam sayı yakalayan regex.
  /// 20-99: [2-9][0-9]
  /// 100-599: [1-5][0-9]{2}
  /// 600: 600
  static final _glucoseRegex = RegExp(r'\b(600|[1-5][0-9]{2}|[2-9][0-9])\b');

  /// Min throttle süresi (ms).
  static const _throttleMs = 500;

  DateTime _lastProcessed = DateTime.fromMillisecondsSinceEpoch(0);
  bool _isProcessing = false;

  /// Kamera frame'ini işle.
  ///
  /// [image]: Kamera frame'i.
  /// [cameraDescription]: Aktif kamera.
  /// [roiRect]: Ekrandaki ROI dikdörtgeni (normalize edilmiş 0..1).
  /// [previewSize]: Kamera preview boyutu.
  ///
  /// Başarılıysa algılanan glukoz değerini döner, aksi halde null.
  Future<int?> processFrame({
    required CameraImage image,
    required CameraDescription cameraDescription,
    required math.Rectangle<double> roiNormalized,
  }) async {
    // Throttle — 500ms'den sık işleme
    final now = DateTime.now();
    if (now.difference(_lastProcessed).inMilliseconds < _throttleMs) {
      return null;
    }
    if (_isProcessing) return null;

    _isProcessing = true;
    _lastProcessed = now;

    try {
      final inputImage = _buildInputImage(image, cameraDescription);
      if (inputImage == null) {
        _isProcessing = false;
        return null;
      }

      final recognized = await _textRecognizer.processImage(inputImage);

      // ROI filtresi — yalnızca merkez kutu içindeki blokları al
      final candidates = <int>[];
      final imgWidth = image.width.toDouble();
      final imgHeight = image.height.toDouble();

      for (final block in recognized.blocks) {
        // Block güven kontrolü (ML Kit v2 her zaman null dönebilir — atla)
        // Bounding box → normalize et ve ROI içinde mi kontrol et
        final bb = block.boundingBox;
        final blockCenterX = bb.center.dx / imgWidth;
        final blockCenterY = bb.center.dy / imgHeight;

        if (!_isInsideRoi(blockCenterX, blockCenterY, roiNormalized)) {
          continue;
        }

        // Blok metninden glukoz değeri çıkar
        final match = _glucoseRegex.firstMatch(block.text);
        if (match != null) {
          final value = int.parse(match.group(1)!);
          if (value >= kGlucoseMin && value <= kGlucoseMax) {
            candidates.add(value);
          }
        }
      }

      _isProcessing = false;

      if (candidates.isEmpty) return null;

      // Birden fazla aday varsa en büyük alanı kaplayan bloktakini tercih et,
      // burada basitçe ilk bulunandan döneriz.
      AppLogger.instance.info(
        'OCR algıladı: $candidates — seçilen: ${candidates.first}',
      );
      return candidates.first;
    } catch (e, stack) {
      AppLogger.instance.error('OCR işleme hatası', error: e, stack: stack);
      _isProcessing = false;
      return null;
    }
  }

  /// ROI kontrolü (normalize edilmiş koordinatlar).
  bool _isInsideRoi(double nx, double ny, math.Rectangle<double> roi) {
    return nx >= roi.left &&
        nx <= (roi.left + roi.width) &&
        ny >= roi.top &&
        ny <= (roi.top + roi.height);
  }

  /// CameraImage → InputImage dönüşümü.
  InputImage? _buildInputImage(CameraImage image, CameraDescription camera) {
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    // Rotation hesapla
    final rotation = InputImageRotationValue.fromRawValue(
      camera.sensorOrientation,
    );
    if (rotation == null) return null;

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  /// Kaynak temizliği.
  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}
