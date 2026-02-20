import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import '../../core/constants.dart';
import '../../core/services/glycemic_engine.dart';
import '../../core/services/sofia_ai_service.dart';
import '../../core/services/voice_service.dart';
import '../../presentation/widgets/glass_widgets.dart';

/// AR Besin Tarayıcı — Kamera + ML Kit Image Labeling + Yerel Veritabanı.
///
/// Yemeği tanır → anında GI/kalori bilgisi → dokunulunca Sofia AI derin analiz.
class FoodScannerPage extends StatefulWidget {
  const FoodScannerPage({super.key});

  @override
  State<FoodScannerPage> createState() => _FoodScannerPageState();
}

class _FoodScannerPageState extends State<FoodScannerPage> {
  CameraController? _cameraCtrl;
  ImageLabeler? _labeler;
  bool _isBusy = false;
  bool _sofiaLoading = false;
  String? _sofiaResponse;

  // Tespit edilen yemek etiketleri
  final List<_DetectedLabel> _detectedLabels = [];
  TurkishFoodItem? _matchedFood;
  GlycemicPrediction? _prediction;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _cameraCtrl = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await _cameraCtrl!.initialize();
      if (!mounted) return;

      // ML Kit Image Labeler
      _labeler = ImageLabeler(
        options: ImageLabelerOptions(confidenceThreshold: 0.5),
      );

      // Canlı akış başlat
      _cameraCtrl!.startImageStream(_processImage);

      setState(() {});
    } catch (e) {
      debugPrint('Kamera hatası: $e');
    }
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isBusy || _labeler == null) return;
    _isBusy = true;

    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) {
        _isBusy = false;
        return;
      }

      final labels = await _labeler!.processImage(inputImage);

      if (!mounted) {
        _isBusy = false;
        return;
      }

      // Yemekle eşleşen etiketleri bul
      final newLabels = <_DetectedLabel>[];
      TurkishFoodItem? bestMatch;

      for (final label in labels) {
        newLabels.add(_DetectedLabel(
          text: label.label,
          confidence: label.confidence,
        ));

        // Yerel veritabanı eşleşmesi
        if (bestMatch == null) {
          final match = GlycemicEngine.instance.matchFromLabel(label.label);
          if (match != null) bestMatch = match;
        }
      }

      setState(() {
        _detectedLabels
          ..clear()
          ..addAll(newLabels);
        if (bestMatch != null && bestMatch != _matchedFood) {
          _matchedFood = bestMatch;
          _prediction = GlycemicEngine.instance
              .predict(bestMatch, PortionSize.normal);
          _sofiaResponse = null;
        }
      });
    } catch (e) {
      debugPrint('ML Kit hatası: $e');
    }

    _isBusy = false;
  }

  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final camera = _cameraCtrl!.description;
      final rotation = InputImageRotationValue.fromRawValue(
        camera.sensorOrientation,
      );
      if (rotation == null) return null;

      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) return null;

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
    } catch (_) {
      return null;
    }
  }

  Future<void> _askSofia() async {
    if (_matchedFood == null) return;
    setState(() {
      _sofiaLoading = true;
      _sofiaResponse = null;
    });

    try {
      final response = await SofiaAiService.instance.analyzeDetectedFood(
        foodName: _matchedFood!.name,
        calories: _matchedFood!.caloriesPer100g,
        carbsG: _matchedFood!.carbsPer100g.round(),
        glycemicIndex: _matchedFood!.glycemicIndex,
      );
      if (mounted) {
        setState(() {
          _sofiaResponse = response;
          _sofiaLoading = false;
        });
        // Sesli okuma
        SystemVoiceService.instance.speak(response);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _sofiaResponse = 'Bağlantı hatası. Tekrar dene.';
          _sofiaLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraCtrl?.dispose();
    _labeler?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('AR Besin Tarayıcı'),
        backgroundColor: Colors.black.withOpacity(0.5),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Kamera önizleme
          if (_cameraCtrl != null && _cameraCtrl!.value.isInitialized)
            CameraPreview(_cameraCtrl!)
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // AR Yüzen Etiket
          if (_matchedFood != null && _prediction != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildAROverlay(isDark),
            ),

          // Etiket listesi (üst)
          if (_detectedLabels.isNotEmpty)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildLabelBar(isDark),
            ),
        ],
      ),
    );
  }

  Widget _buildLabelBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: _detectedLabels.take(5).map((l) {
          final isMatch = _matchedFood != null &&
              GlycemicEngine.instance.matchFromLabel(l.text) != null;
          return Chip(
            label: Text(
              '${l.text} ${(l.confidence * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                color: isMatch ? Colors.white : Colors.white70,
              ),
            ),
            backgroundColor:
                isMatch ? RC.accentGreen.withOpacity(0.5) : Colors.white12,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAROverlay(bool isDark) {
    final p = _prediction!;
    final riskColor = p.food.glycemicIndex > 70
        ? Colors.red
        : p.food.glycemicIndex > 55
            ? Colors.orange
            : RC.accentGreen;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: riskColor.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: riskColor.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Yemek başlığı
          Row(
            children: [
              Text(p.food.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.food.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'GI: ${p.food.glycemicIndex} • '
                      '${p.food.caloriesPer100g} kcal/100g • '
                      '${p.food.carbsPer100g.toStringAsFixed(0)}g karb',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Metrikler
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _arMetric('⏱️', '${p.peakMinutes} dk', 'Pik'),
              _arMetric('📈', '~${p.estimatedRiseMgDl}', 'mg/dL'),
              _arMetric('🚶', '${p.exerciseMinutes} dk', 'Egzersiz'),
            ],
          ),
          const SizedBox(height: 12),

          // Sofia AI butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sofiaLoading ? null : _askSofia,
              icon: _sofiaLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome, size: 18),
              label: Text(
                _sofiaLoading ? 'Sofia düşünüyor...' : 'Sofia\'ya Sor',
                style: const TextStyle(fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: RC.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // Sofia yanıtı
          if (_sofiaResponse != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: RC.blue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: RC.blue.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🤖 ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      _sofiaResponse!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _arMetric(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

class _DetectedLabel {
  final String text;
  final double confidence;
  const _DetectedLabel({required this.text, required this.confidence});
}
