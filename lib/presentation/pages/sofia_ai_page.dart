import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/services/sofia_ai_service.dart';
import '../../core/services/openfda_service.dart';
import '../../core/services/voice_service.dart';
import '../../domain/usecases/ea1c_calculator.dart';
import '../state/providers.dart';
import '../widgets/glass_widgets.dart';

/// Sofia AI Sohbet Sayfası — Yapay zeka destekli sağlık asistanı.
///
/// Glassmorphism UI, sesli okuma, hızlı aksiyon butonları,
/// OpenFDA ilaç bilgi entegrasyonu.
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

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Hoş geldin mesajı
    _messages.add(
      _ChatMessage(
        text:
            'Merhaba, ben Sofia AI. Kan şekeri, diyabet yönetimi ve '
            'beslenme konularında sana yardımcı olabilirim. '
            'Bana ne sormak istersin?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
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

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text.trim(),
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    final response = await SofiaAiService.instance.ask(text.trim());

    setState(() {
      _messages.add(
        _ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
      );
      _isLoading = false;
    });
    _scrollToBottom();

    // Sesli oku
    if (_voiceAutoPlay) {
      SystemVoiceService.instance.speak(response);
    }
  }

  Future<void> _analyzeMyData() async {
    setState(() => _isLoading = true);
    _messages.add(
      _ChatMessage(
        text: 'Verilerime göre analiz yap.',
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
    _scrollToBottom();

    // Verileri topla
    try {
      final allRecords = await ref.read(glucoseRepositoryProvider).getAll();
      final todayRecords = await ref.read(glucoseRepositoryProvider).getToday();

      if (allRecords.isEmpty) {
        final noData =
            'Henüz kayıtlı kan şekeri verin yok. '
            'Önce birkaç ölçüm kaydet, sonra sana detaylı analiz yapayım. '
            'Lütfen doktoruna danışmayı unutma.';
        setState(() {
          _messages.add(
            _ChatMessage(
              text: noData,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
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
        _messages.add(
          _ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();

      if (_voiceAutoPlay) SystemVoiceService.instance.speak(response);
    } catch (e) {
      setState(() {
        _messages.add(
          _ChatMessage(
            text: 'Veri analizi sırasında bir hata oluştu. Tekrar deneyin.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _askDrugInfo() async {
    final drugName = await _showDrugInputDialog();
    if (drugName == null || drugName.isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          text: '$drugName hakkında bilgi ver.',
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });
    _scrollToBottom();

    // Önce OpenFDA'dan bilgi al
    final fdaData = await OpenFdaService.instance.searchDrug(drugName);

    String response;
    if (fdaData != null && fdaData['warnings']!.isNotEmpty) {
      response = await SofiaAiService.instance.analyzeDrugSideEffects(
        drugName: drugName,
        activeIngredient: fdaData['active_ingredient'],
        fdaWarnings: fdaData['warnings'],
      );
    } else {
      response = await SofiaAiService.instance.askDrugInfo(drugName);
    }

    setState(() {
      _messages.add(
        _ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
      );
      _isLoading = false;
    });
    _scrollToBottom();

    if (_voiceAutoPlay) SystemVoiceService.instance.speak(response);
  }

  Future<String?> _showDrugInputDialog() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('İlaç Bilgisi Sorgula'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'İlaç adı',
            hintText: 'ör: Metformin, Parol, Glucophage',
            prefixIcon: Icon(Icons.medication),
            border: OutlineInputBorder(),
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
            child: const Text('Sorgula'),
          ),
        ],
      ),
    );
  }

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
          // Geçmişi temizle
          IconButton(
            icon: Icon(Icons.delete_sweep, color: Colors.grey.shade400),
            onPressed: () {
              SofiaAiService.instance.clearHistory();
              setState(() {
                _messages.clear();
                _messages.add(
                  _ChatMessage(
                    text: 'Sohbet temizlendi. Sana nasıl yardımcı olabilirim?',
                    isUser: false,
                    timestamp: DateTime.now(),
                  ),
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
            // ─── Mesaj Listesi ─────────────────────────
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

            // ─── Hızlı Aksiyonlar ─────────────────────
            _buildQuickActions(isDark),

            // ─── Mesaj Girişi ──────────────────────────
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
            // Sofia avatar
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
                        // Sesli oku butonu
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
          // Sofia avatar — pulsing
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
              label: 'Verilerimi Analiz Et',
              color: RC.blue,
              onTap: _isLoading ? null : _analyzeMyData,
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
              icon: Icons.restaurant,
              label: 'Beslenme Tavsiyesi',
              color: Colors.orange,
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
                      'Gece kan şekerim yükseliyor. Bunun nedeni ne olabilir '
                      've ne yapmalıyım?',
                    ),
            ),
            const SizedBox(width: 8),
            _quickActionChip(
              icon: Icons.directions_run,
              label: 'Egzersiz',
              color: Colors.teal,
              onTap: _isLoading
                  ? null
                  : () => _sendMessage(
                      'Diyabet hastası olarak egzersiz yaparken şekerimi '
                      'nasıl kontrol altında tutabilirim?',
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
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.1),
              ),
              child: TextField(
                controller: _controller,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: "Sofia'ya sor...",
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white30 : Colors.grey,
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
          const SizedBox(width: 8),
          // Gönder butonu
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

// ─── Mesaj Modeli ────────────────────────────────────────────
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
