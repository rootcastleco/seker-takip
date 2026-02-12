import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../core/constants.dart';
import '../../core/services/sofia_ai_service.dart';
import '../../core/services/openfda_service.dart';
import '../../core/services/voice_service.dart';
import '../../domain/usecases/ea1c_calculator.dart';
import '../state/providers.dart';
import '../widgets/glass_widgets.dart';

/// Sofia AI Sohbet Sayfası — Gemini destekli asistan.
///
/// Sesli giriş (STT), yemek fotoğrafı analizi, panik butonu,
/// biohacking skoru, ilaç etkileşimi, OpenFDA bilgi entegrasyonu.
class SofiaAiPage extends ConsumerStatefulWidget {
  const SofiaAiPage({super.key});

  @override
  ConsumerState<SofiaAiPage> createState() => _SofiaAiPageState();
}

class _SofiaAiPageState extends ConsumerState<SofiaAiPage>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _voiceAutoPlay = true;

  // STT
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  // Image picker
  final ImagePicker _picker = ImagePicker();

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _initSpeech();

    _messages.add(
      _ChatMessage(
        text:
            'Merhaba, ben Sofia. Kan şekeri, diyabet yönetimi, beslenme ve '
            'ilaç konularında sana yardımcı olabilirim. Yemek fotoğrafı '
            'çekerek besin analizi de yapabilirim. Bana ne sormak istersin?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onError: (e) {
          if (mounted) setState(() => _isListening = false);
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
      );
    } catch (_) {
      _speechAvailable = false;
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    if (!_speechAvailable) {
      _addBotMessage('Ses tanıma bu cihazda kullanılamıyor.');
      return;
    }

    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
        });
        if (result.finalResult) {
          setState(() => _isListening = false);
          if (_controller.text.trim().isNotEmpty) {
            _sendMessage(_controller.text);
          }
        }
      },
      localeId: 'tr_TR',
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    _speech.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addUserMessage(String text) {
    _messages.add(
      _ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
    );
  }

  void _addBotMessage(String text) {
    _messages.add(
      _ChatMessage(text: text, isUser: false, timestamp: DateTime.now()),
    );
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _addUserMessage(text.trim());
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    final response = await SofiaAiService.instance.ask(text.trim());

    setState(() {
      _addBotMessage(response);
      _isLoading = false;
    });
    _scrollToBottom();
    if (_voiceAutoPlay) SystemVoiceService.instance.speak(response);
  }

  // ─── Veri Analizi ─────────────────────────────────────
  Future<void> _analyzeMyData() async {
    setState(() {
      _addUserMessage('Verilerime göre analiz yap.');
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final allRecords = await ref.read(glucoseRepositoryProvider).getAll();
      final todayRecords = await ref.read(glucoseRepositoryProvider).getToday();

      if (allRecords.isEmpty) {
        const noData =
            'Henüz kayıtlı kan şekeri verin yok. Önce birkaç ölçüm kaydet, '
            'sonra sana detaylı analiz yapayım.';
        setState(() {
          _addBotMessage(noData);
          _isLoading = false;
        });
        if (_voiceAutoPlay) SystemVoiceService.instance.speak(noData);
        return;
      }

      final allVals = allRecords
          .expand((r) => r.allMeasurements)
          .whereType<int>()
          .toList();
      final avgGlucose = allVals.isNotEmpty
          ? (allVals.reduce((a, b) => a + b) / allVals.length)
          : 0.0;

      final ea1cResult = Ea1cCalculator.calculate(allRecords);
      final sdResult = Ea1cCalculator.calculateVariability(allRecords);

      int? todayFasting;
      int? todayPostprandial;
      if (todayRecords.isNotEmpty) {
        todayFasting = todayRecords.first.sabahAc;
        todayPostprandial = todayRecords.first.sabahTok;
      }

      String? stabilityText;
      if (sdResult != null) {
        switch (sdResult.level) {
          case StabilityLevel.stable:
            stabilityText = 'Stabil';
          case StabilityLevel.moderate:
            stabilityText = 'Orta değişkenlik';
          case StabilityLevel.high:
            stabilityText = 'Yüksek değişkenlik';
        }
      }

      final response = await SofiaAiService.instance.analyzeGlucose(
        avgGlucose: avgGlucose,
        recordCount: allRecords.length,
        ea1c: ea1cResult?.formattedEa1c,
        stabilityLevel: stabilityText,
        todayFasting: todayFasting,
        todayPostprandial: todayPostprandial,
      );

      setState(() {
        _addBotMessage(response);
        _isLoading = false;
      });
      _scrollToBottom();
      if (_voiceAutoPlay) SystemVoiceService.instance.speak(response);
    } catch (e) {
      setState(() {
        _addBotMessage('Veri analizi sırasında bir hata oluştu. Tekrar dene.');
        _isLoading = false;
      });
    }
  }

  // ─── İlaç Bilgisi ─────────────────────────────────────
  Future<void> _askDrugInfo() async {
    final drugName = await _showTextInputDialog(
      title: 'İlaç Bilgisi Sorgula',
      label: 'İlaç adı',
      hint: 'ör: Metformin, Parol, Glucophage',
      icon: Icons.medication,
      buttonText: 'Sorgula',
    );
    if (drugName == null || drugName.isEmpty) return;

    setState(() {
      _addUserMessage('$drugName hakkında bilgi ver.');
      _isLoading = true;
    });
    _scrollToBottom();

    final fdaData = await OpenFdaService.instance.searchDrug(drugName);

    String response;
    if (fdaData != null && fdaData['warnings']!.isNotEmpty) {
      response = await SofiaAiService.instance.ask(
        'İlaç: $drugName. Etken madde: ${fdaData['active_ingredient']}. '
        'FDA uyarıları: ${fdaData['warnings']}. '
        'Diyabet hastasına bu ilacı anlat ve uyarıları Türkçe özetle.',
      );
    } else {
      response = await SofiaAiService.instance.askDrugInfo(drugName);
    }

    setState(() {
      _addBotMessage(response);
      _isLoading = false;
    });
    _scrollToBottom();
    if (_voiceAutoPlay) SystemVoiceService.instance.speak(response);
  }

  // ─── Gören Sofia (Yemek Fotoğrafı Analizi) ────────────
  Future<void> _analyzeFood() async {
    try {
      final source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (image == null) return;

      final Uint8List bytes = await image.readAsBytes();

      setState(() {
        _addUserMessage('📷 Yemek fotoğrafı gönderildi. Analiz et.');
        _isLoading = true;
      });
      _scrollToBottom();

      final response = await SofiaAiService.instance.analyzeFood(bytes);

      setState(() {
        _addBotMessage(response);
        _isLoading = false;
      });
      _scrollToBottom();
      if (_voiceAutoPlay) SystemVoiceService.instance.speak(response);
    } catch (e) {
      setState(() {
        _addBotMessage(
          'Fotoğraf analizi sırasında bir hata oluştu. Tekrar dene.',
        );
        _isLoading = false;
      });
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yemek Fotoğrafı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Biohacking Skoru ──────────────────────────────────
  Future<void> _showBiohacking() async {
    setState(() {
      _addUserMessage('Biohacking skorumu hesapla.');
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final allRecords = await ref.read(glucoseRepositoryProvider).getAll();
      final activeMeds = await ref
          .read(medicationRepositoryProvider)
          .getActive();

      final allVals = allRecords
          .expand((r) => r.allMeasurements)
          .whereType<int>()
          .toList();
      final avgGlucose = allVals.isNotEmpty
          ? (allVals.reduce((a, b) => a + b) / allVals.length)
          : null;

      // İlaç uyum tahmini: aktif ilaç varsa %80 başlangıç
      final ilacUyum = activeMeds.isNotEmpty ? 80 : 0;

      // Son 7 günde ölçüm yapılmış gün sayısı
      final now = DateTime.now();
      final last7 = allRecords
          .where((r) => r.tarih.isAfter(now.subtract(const Duration(days: 7))))
          .toList();

      final response = await SofiaAiService.instance.analyzeBiohacking(
        ilacUyumYuzde: ilacUyum,
        olcumSayisi: last7.length,
        toplamKayit: allRecords.length,
        ortalamaGlukoz: avgGlucose?.toDouble(),
      );

      setState(() {
        _addBotMessage(response);
        _isLoading = false;
      });
      _scrollToBottom();
      if (_voiceAutoPlay) SystemVoiceService.instance.speak(response);
    } catch (e) {
      setState(() {
        _addBotMessage('Biohacking hesaplaması sırasında hata oluştu.');
        _isLoading = false;
      });
    }
  }

  // ─── Panik Butonu (Acil Durum) ─────────────────────────
  Future<void> _panicButton() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.red.shade900,
        title: const Text(
          'ACİL DURUM',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Panik butonunu kullanmak istediğine emin misin?\n\n'
          'Sofia seni sakinleştirecek ve yönlendirecek.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('EVET, ACİL'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _addUserMessage('ACİL DURUM! Yardım et!');
      _isLoading = true;
    });
    _scrollToBottom();

    // TTS ile hemen sakinleştir
    SystemVoiceService.instance.speak(
      'Sakin ol. Yanındayım. Şimdi sana yardımcı olacağım.',
    );

    final response = await SofiaAiService.instance.emergencyResponse();

    setState(() {
      _addBotMessage(response);
      _isLoading = false;
    });
    _scrollToBottom();
    if (_voiceAutoPlay) SystemVoiceService.instance.speak(response);
  }

  // ─── İlaç Etkileşim Kontrolü ──────────────────────────
  Future<void> _checkDrugInteraction() async {
    final activeMeds = await ref.read(medicationRepositoryProvider).getActive();

    if (activeMeds.isEmpty) {
      _addBotMessage(
        'Etkileşim kontrolü için önce İlaçlarım sekmesine ilaç ekle.',
      );
      setState(() {});
      return;
    }

    final yeniMadde = await _showTextInputDialog(
      title: 'Etkileşim Kontrolü',
      label: 'Kontrol edilecek madde',
      hint: 'ör: Aspirin, D vitamini, Omega-3',
      icon: Icons.science,
      buttonText: 'Kontrol Et',
    );
    if (yeniMadde == null || yeniMadde.isEmpty) return;

    final mevcutIlaclar = activeMeds.map((m) => m.ilacAdi).toList();

    setState(() {
      _addUserMessage(
        '$yeniMadde ile mevcut ilaçlarımın etkileşimini kontrol et.',
      );
      _isLoading = true;
    });
    _scrollToBottom();

    final response = await SofiaAiService.instance.checkDrugInteraction(
      mevcutIlaclar: mevcutIlaclar,
      yeniMadde: yeniMadde,
    );

    setState(() {
      _addBotMessage(response);
      _isLoading = false;
    });
    _scrollToBottom();
    if (_voiceAutoPlay) SystemVoiceService.instance.speak(response);
  }

  // ─── Ortak Input Dialog ────────────────────────────────
  Future<String?> _showTextInputDialog({
    required String title,
    required String label,
    String? hint,
    IconData? icon,
    String buttonText = 'Tamam',
  }) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon) : null,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (val) => Navigator.pop(ctx, val.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(Tr.iptal),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // ─── UI ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassScaffold(
      appBar: GlassAppBar(
        title: 'Sofia AI',
        actions: [
          // Ses toggle
          IconButton(
            icon: Icon(
              _voiceAutoPlay ? Icons.volume_up : Icons.volume_off,
              color: _voiceAutoPlay ? RC.accentGreen : Colors.grey,
            ),
            onPressed: () {
              setState(() => _voiceAutoPlay = !_voiceAutoPlay);
              if (!_voiceAutoPlay) SystemVoiceService.instance.stop();
            },
            tooltip: 'Sesli Okuma',
          ),
          // Sohbeti Temizle
          IconButton(
            icon: Icon(Icons.delete_sweep, color: Colors.grey.shade400),
            onPressed: () {
              SofiaAiService.instance.clearHistory();
              setState(() {
                _messages.clear();
                _addBotMessage(
                  'Sohbet temizlendi. Sana nasıl yardımcı olabilirim?',
                );
              });
            },
            tooltip: 'Sohbeti Temizle',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mesaj Listesi
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildTypingIndicator(isDark);
                  }
                  return _buildMessageBubble(_messages[index], isDark);
                },
              ),
            ),
            // Hızlı Aksiyonlar (kaydırılabilir)
            _buildQuickActions(isDark),
            // Mesaj Girişi
            _buildInputBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message, bool isDark) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 48 : 0,
        right: isUser ? 0 : 48,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [RC.blue, RC.accentGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GlassCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              borderRadius: 16,
              blur: 8,
              borderColor: isUser
                  ? RC.blue.withValues(alpha: 0.3)
                  : RC.accentGreen.withValues(alpha: 0.2),
              backgroundColor: isUser
                  ? RC.blue.withValues(alpha: isDark ? 0.25 : 0.1)
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Sofia AI',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: RC.accentGreen,
                        ),
                      ),
                    ),
                  SelectableText(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white30 : Colors.black26,
                        ),
                      ),
                      if (!isUser) ...[
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () =>
                              SystemVoiceService.instance.speak(message.text),
                          child: Icon(
                            Icons.volume_up,
                            size: 16,
                            color: isDark ? Colors.white30 : Colors.black26,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(right: 48, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (ctx, child) {
              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      RC.blue,
                      RC.accentGreen.withValues(
                        alpha: 0.5 + _pulseController.value * 0.5,
                      ),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'S',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          GlassCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            borderRadius: 16,
            blur: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(RC.accentGreen),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Sofia düşünüyor...',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _quickActionChip(
              icon: Icons.analytics,
              label: 'Analiz Et',
              color: RC.blue,
              onTap: _isLoading ? null : _analyzeMyData,
            ),
            const SizedBox(width: 8),
            _quickActionChip(
              icon: Icons.camera_alt,
              label: 'Yemek Tara',
              color: Colors.orange,
              onTap: _isLoading ? null : _analyzeFood,
            ),
            const SizedBox(width: 8),
            _quickActionChip(
              icon: Icons.medication,
              label: 'İlaç Bilgisi',
              color: RC.accentGreen,
              onTap: _isLoading ? null : _askDrugInfo,
            ),
            const SizedBox(width: 8),
            _quickActionChip(
              icon: Icons.science,
              label: 'Etkileşim',
              color: Colors.deepPurple,
              onTap: _isLoading ? null : _checkDrugInteraction,
            ),
            const SizedBox(width: 8),
            _quickActionChip(
              icon: Icons.emoji_events,
              label: 'Biohacking',
              color: Colors.amber,
              onTap: _isLoading ? null : _showBiohacking,
            ),
            const SizedBox(width: 8),
            _quickActionChip(
              icon: Icons.restaurant,
              label: 'Beslenme',
              color: Colors.teal,
              onTap: _isLoading
                  ? null
                  : () => _sendMessage(
                      'Diyabet hastası olarak günlük beslenmede nelere '
                      'dikkat etmeliyim? Karbonhidrat yönetimi hakkında bilgi ver.',
                    ),
            ),
            const SizedBox(width: 8),
            _quickActionChip(
              icon: Icons.nightlight_round,
              label: 'Gece Şekeri',
              color: RC.accent,
              onTap: _isLoading
                  ? null
                  : () => _sendMessage(
                      'Gece kan şekerim yükseliyor. Bunun nedeni ne olabilir?',
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionChip({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: color.withValues(alpha: isDark ? 0.15 : 0.1),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          // Panik butonu
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withValues(alpha: 0.15),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.sos, color: Colors.red, size: 18),
              onPressed: _isLoading ? null : _panicButton,
              tooltip: 'Acil Durum',
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 8),
          // Metin girişi
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.1),
                border: _isListening
                    ? Border.all(color: Colors.red, width: 1.5)
                    : null,
              ),
              child: TextField(
                controller: _controller,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: _isListening ? 'Dinliyorum...' : "Sofia'ya sor...",
                  hintStyle: TextStyle(
                    color: _isListening
                        ? Colors.red.shade300
                        : isDark
                        ? Colors.white30
                        : Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: _isLoading ? null : _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Mikrofon butonu
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isListening
                  ? Colors.red.withValues(alpha: 0.2)
                  : Colors.purple.withValues(alpha: 0.15),
            ),
            child: IconButton(
              icon: Icon(
                _isListening ? Icons.mic_off : Icons.mic,
                color: _isListening ? Colors.red : Colors.purple,
                size: 20,
              ),
              onPressed: _isLoading ? null : _toggleListening,
              tooltip: _isListening ? 'Dinlemeyi Durdur' : 'Sesli Giriş',
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 6),
          // Gönder
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [RC.blue, RC.accentGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _isLoading
                  ? null
                  : () => _sendMessage(_controller.text),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
