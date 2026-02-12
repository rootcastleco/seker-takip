import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants.dart';
import '../../../core/logger/logger.dart';
import '../../../core/services/voice_service.dart';
import '../logic/glucose_ocr_processor.dart';

/// Rootcastle Vision — Glucometer OCR tarama sayfası.
///
/// Tam ekran kamera preview + cyberpunk yeşil ROI kutusu.
/// Algılanan değer doğrulama dialog'u ile onaylanır.
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  GlucoseOcrProcessor? _ocrProcessor;

  bool _isInitialized = false;
  bool _hasPermission = false;
  bool _isFrozen = false;
  bool _initError = false;
  String _statusText = Tr.tarayiciAraniyor;
  int? _detectedValue;

  // ROI — ekranın ortasında sabit bir kare (normalize 0..1)
  static const double _roiSize = 0.55;
  static const double _roiLeft = (1.0 - _roiSize) / 2;
  static const double _roiTop = (1.0 - _roiSize) / 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopStream();
    _cameraController?.dispose();
    _ocrProcessor?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _stopStream();
      _cameraController?.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      // İzin kontrolü
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        setState(() {
          _hasPermission = false;
          _initError = true;
        });
        return;
      }
      _hasPermission = true;

      // Kamera listesi
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() => _initError = true);
        return;
      }

      // Arka kamerayı seç
      final backCamera = _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await _cameraController!.initialize();

      // OCR motor
      _ocrProcessor = GlucoseOcrProcessor();

      if (!mounted) return;
      setState(() => _isInitialized = true);

      // Stream başlat
      _startStream();
    } catch (e, stack) {
      AppLogger.instance.error('Kamera init hatası', error: e, stack: stack);
      if (mounted) {
        setState(() => _initError = true);
      }
    }
  }

  void _startStream() {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isFrozen) {
      return;
    }

    _cameraController!.startImageStream((image) {
      if (_isFrozen) return;
      _processFrame(image);
    });
  }

  void _stopStream() {
    try {
      if (_cameraController != null &&
          _cameraController!.value.isInitialized &&
          _cameraController!.value.isStreamingImages) {
        _cameraController!.stopImageStream();
      }
    } catch (_) {
      // Stream zaten durmuş olabilir
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_ocrProcessor == null || _cameraController == null) return;

    final roi = math.Rectangle<double>(_roiLeft, _roiTop, _roiSize, _roiSize);

    final result = await _ocrProcessor!.processFrame(
      image: image,
      cameraDescription: _cameraController!.description,
      roiNormalized: roi,
    );

    if (result != null && mounted && !_isFrozen) {
      _onValueDetected(result);
    }
  }

  Future<void> _onValueDetected(int value) async {
    // Dondur
    setState(() {
      _isFrozen = true;
      _detectedValue = value;
      _statusText = Tr.tarayiciAlgilandi;
    });
    _stopStream();

    // Sesli geri bildirim
    final spokenNumber = _numberToTurkish(value);
    try {
      await SystemVoiceService.instance.speak(
        '${Tr.sesOlcumAlgilandi} $spokenNumber. ${Tr.sesOnayBekliyor}',
      );
    } catch (_) {
      // TTS hatası engellemesin
    }

    // Doğrulama dialog
    if (mounted) {
      _showVerificationSheet(value);
    }
  }

  void _showVerificationSheet(int value) {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _VerificationSheet(
        detectedValue: value,
        onConfirm: (confirmedValue) {
          Navigator.pop(ctx);
          Navigator.pop(context, confirmedValue);
        },
        onRescan: () {
          Navigator.pop(ctx);
          _rescan();
        },
      ),
    );
  }

  void _rescan() {
    setState(() {
      _isFrozen = false;
      _detectedValue = null;
      _statusText = Tr.tarayiciAraniyor;
    });
    _startStream();
  }

  /// Sayıyı Türkçe okunuşa çevir (basit yüz/bin mantığı).
  String _numberToTurkish(int n) {
    if (n < 0 || n > 999) return '$n';

    const ones = [
      '',
      'bir',
      'iki',
      'üç',
      'dört',
      'beş',
      'altı',
      'yedi',
      'sekiz',
      'dokuz',
    ];
    const tens = [
      '',
      'on',
      'yirmi',
      'otuz',
      'kırk',
      'elli',
      'altmış',
      'yetmiş',
      'seksen',
      'doksan',
    ];

    if (n == 0) return 'sıfır';

    final h = n ~/ 100;
    final t = (n % 100) ~/ 10;
    final o = n % 10;

    final buf = StringBuffer();
    if (h > 0) {
      if (h == 1) {
        buf.write('yüz');
      } else {
        buf.write('${ones[h]} yüz');
      }
    }
    if (t > 0) {
      if (buf.isNotEmpty) buf.write(' ');
      buf.write(tens[t]);
    }
    if (o > 0) {
      if (buf.isNotEmpty) buf.write(' ');
      buf.write(ones[o]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.greenAccent,
        title: const Text(
          Tr.tarayiciBaslik,
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // İzin reddedildi
    if (_initError && !_hasPermission) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                Tr.kameraIzniReddedildi,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => openAppSettings(),
                icon: const Icon(Icons.settings),
                label: const Text(Tr.ayarlar),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.greenAccent,
                  side: const BorderSide(color: Colors.greenAccent),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Init hatası
    if (_initError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                Tr.gorusSistemiDevreDisi,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.greenAccent,
                  side: const BorderSide(color: Colors.greenAccent),
                ),
                child: const Text('Geri'),
              ),
            ],
          ),
        ),
      );
    }

    // Yüklenme
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.greenAccent),
      );
    }

    // Kamera preview + ROI overlay
    return Stack(
      fit: StackFit.expand,
      children: [
        // Kamera preview
        ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _cameraController!.value.previewSize!.height,
              height: _cameraController!.value.previewSize!.width,
              child: CameraPreview(_cameraController!),
            ),
          ),
        ),

        // ROI overlay
        CustomPaint(
          painter: _RoiOverlayPainter(
            roiFraction: _roiSize,
            isFrozen: _isFrozen,
          ),
        ),

        // Status text
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Text(
            _statusText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _isFrozen ? Colors.greenAccent : Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              shadows: const [Shadow(blurRadius: 8, color: Colors.black)],
            ),
          ),
        ),

        // Instruction text (top)
        if (!_isFrozen)
          Positioned(
            top: 16,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.greenAccent.withValues(alpha: 0.3),
                ),
              ),
              child: const Text(
                Tr.tarayiciHizala,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        // Detected value display
        if (_isFrozen && _detectedValue != null)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.greenAccent, width: 2),
              ),
              child: Text(
                '${_detectedValue!} mg/dL',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── ROI Overlay Painter ────────────────────────────────────

/// Cyberpunk yeşil kutucuk çizen overlay.
/// Kutu dışı koyu yarı-şeffaf, kutu çerçevesi yeşil neon.
class _RoiOverlayPainter extends CustomPainter {
  _RoiOverlayPainter({required this.roiFraction, required this.isFrozen});

  final double roiFraction;
  final bool isFrozen;

  @override
  void paint(Canvas canvas, Size size) {
    final roiW = size.width * roiFraction;
    final roiH = size.width * roiFraction; // kare
    final roiLeft = (size.width - roiW) / 2;
    final roiTop = (size.height - roiH) / 2;
    final roiRect = Rect.fromLTWH(roiLeft, roiTop, roiW, roiH);

    // Koyu overlay (ROI dışı)
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.saveLayer(fullRect, Paint());
    canvas.drawRect(fullRect, overlayPaint);

    // ROI alanını temizle (delik aç)
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawRRect(
      RRect.fromRectAndRadius(roiRect, const Radius.circular(12)),
      clearPaint,
    );
    canvas.restore();

    // ROI çerçeve (yeşil neon)
    final borderColor = isFrozen
        ? Colors.greenAccent
        : Colors.greenAccent.withValues(alpha: 0.8);
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = borderColor
      ..strokeWidth = isFrozen ? 3.0 : 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(roiRect, const Radius.circular(12)),
      borderPaint,
    );

    // Köşe süsleri (cyberpunk detay)
    _drawCornerAccents(canvas, roiRect, borderColor);
  }

  void _drawCornerAccents(Canvas canvas, Rect rect, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    const len = 24.0;
    const r = 12.0;

    // Sol üst
    canvas.drawLine(
      Offset(rect.left - 1, rect.top + r + len),
      Offset(rect.left - 1, rect.top + r),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left + r, rect.top - 1),
      Offset(rect.left + r + len, rect.top - 1),
      paint,
    );

    // Sağ üst
    canvas.drawLine(
      Offset(rect.right + 1, rect.top + r + len),
      Offset(rect.right + 1, rect.top + r),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right - r, rect.top - 1),
      Offset(rect.right - r - len, rect.top - 1),
      paint,
    );

    // Sol alt
    canvas.drawLine(
      Offset(rect.left - 1, rect.bottom - r - len),
      Offset(rect.left - 1, rect.bottom - r),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left + r, rect.bottom + 1),
      Offset(rect.left + r + len, rect.bottom + 1),
      paint,
    );

    // Sağ alt
    canvas.drawLine(
      Offset(rect.right + 1, rect.bottom - r - len),
      Offset(rect.right + 1, rect.bottom - r),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right - r, rect.bottom + 1),
      Offset(rect.right - r - len, rect.bottom + 1),
      paint,
    );
  }

  @override
  bool shouldRepaint(_RoiOverlayPainter old) =>
      old.isFrozen != isFrozen || old.roiFraction != roiFraction;
}

// ─── Verification Sheet ─────────────────────────────────────

/// Doğrulama bottom sheet — değeri düzenleme + onay/yeniden tara.
class _VerificationSheet extends StatefulWidget {
  const _VerificationSheet({
    required this.detectedValue,
    required this.onConfirm,
    required this.onRescan,
  });

  final int detectedValue;
  final void Function(int confirmedValue) onConfirm;
  final VoidCallback onRescan;

  @override
  State<_VerificationSheet> createState() => _VerificationSheetState();
}

class _VerificationSheetState extends State<_VerificationSheet> {
  late TextEditingController _editController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(
      text: widget.detectedValue.toString(),
    );
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  int? get _currentValue => int.tryParse(_editController.text.trim());

  bool get _isValid {
    final v = _currentValue;
    return v != null && v >= kGlucoseMin && v <= kGlucoseMax;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Başlık
          Text(
            Tr.tarayiciAlgilandi,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Tr.tarayiciOnay,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Değer gösterimi (tıklayınca düzenlenebilir)
          GestureDetector(
            onTap: () => setState(() => _isEditing = true),
            child: _isEditing
                ? SizedBox(
                    width: 160,
                    child: TextField(
                      controller: _editController,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        suffixText: Tr.mgDl,
                        suffixStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        errorText: _isValid ? null : Tr.gecersizDeger,
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => setState(() => _isEditing = false),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _editController.text,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'mg/dL',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.edit, size: 18, color: Colors.grey.shade400),
                    ],
                  ),
          ),
          const SizedBox(height: 32),

          // Butonlar
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onRescan,
                  icon: const Icon(Icons.refresh),
                  label: const Text(Tr.yenidenTara),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isValid
                      ? () => widget.onConfirm(_currentValue!)
                      : null,
                  icon: const Icon(Icons.check),
                  label: const Text(Tr.onaylaKaydet),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF228B55),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
