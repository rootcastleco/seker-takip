import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../core/constants.dart';
import '../../core/services/voice_service.dart';
import '../widgets/glass_widgets.dart';

/// Konsolide Ayarlar sayfası — Tab 4.
///
/// İçerik: Profil, Yedekleme Merkezi, Raporlama, Sesli Asistan toggle,
/// İdeal Hedefler, Tanılama, Kullanım Kılavuzu, Hakkında.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _voiceEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // ─── Başlık ───────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            Tr.tabAyarlar,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : RC.black,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // ─── Profil ──────────────────────────────────
        GlassSectionHeader(title: 'Hesap', icon: Icons.person),
        GlassListTile(
          icon: Icons.person_outline,
          label: Tr.profilBilgileri,
          color: RC.accent,
          onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
        ),

        const SizedBox(height: 8),

        // ─── Veri Yönetimi ───────────────────────────
        GlassSectionHeader(title: 'Veri Yönetimi', icon: Icons.storage),
        GlassListTile(
          icon: Icons.backup,
          label: Tr.yedeklemeMerkezi,
          color: RC.blue,
          onTap: () => _showBackupSheet(context, isDark),
        ),
        GlassListTile(
          icon: Icons.picture_as_pdf,
          label: Tr.raporlama,
          color: Colors.red.shade400,
          onTap: () => Navigator.pushNamed(context, AppRoutes.export),
        ),

        const SizedBox(height: 8),

        // ─── Tercihler ──────────────────────────────
        GlassSectionHeader(title: 'Tercihler', icon: Icons.tune),
        // Sesli Asistan Toggle
        GlassCard(
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.only(bottom: 8),
          borderRadius: 12,
          blur: 8,
          child: SwitchListTile(
            secondary: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: RC.accentGreen.withValues(alpha: isDark ? 0.15 : 0.1),
              ),
              child: Icon(
                Icons.record_voice_over,
                color: RC.accentGreen,
                size: 22,
              ),
            ),
            title: Text(
              Tr.sesliAsistan,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : RC.black,
              ),
            ),
            subtitle: Text(
              Tr.sesliAsistanAciklama,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.grey,
              ),
            ),
            value: _voiceEnabled,
            activeColor: RC.accentGreen,
            onChanged: (val) {
              setState(() => _voiceEnabled = val);
              if (!val) {
                SystemVoiceService.instance.stop();
              }
            },
          ),
        ),
        GlassListTile(
          icon: Icons.flag,
          label: Tr.idealHedefler,
          color: RC.accentGreen,
          onTap: () => Navigator.pushNamed(context, AppRoutes.targets),
        ),

        const SizedBox(height: 8),

        // ─── Sistem ────────────────────────────────
        GlassSectionHeader(title: 'Sistem', icon: Icons.settings),
        GlassListTile(
          icon: Icons.bug_report,
          label: Tr.tanilamaLoglari,
          color: Colors.grey,
          onTap: () => Navigator.pushNamed(context, AppRoutes.diagnostics),
        ),
        GlassListTile(
          icon: Icons.menu_book,
          label: Tr.kullanimKilavuzu,
          color: RC.accent,
          onTap: () => _showGuide(context, isDark),
        ),
        GlassListTile(
          icon: Icons.info_outline,
          label: Tr.hakkinda,
          color: RC.blue,
          onTap: () => Navigator.pushNamed(context, AppRoutes.about),
        ),
      ],
    );
  }

  /// Yedekleme alt sayfası — Export / Import seçimi.
  void _showBackupSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? RC.bgDark2 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                Tr.yedeklemeMerkezi,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : RC.black,
                ),
              ),
              const SizedBox(height: 24),
              GlassListTile(
                icon: Icons.file_download,
                label: Tr.disaAktar,
                color: RC.blue,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.export);
                },
              ),
              GlassListTile(
                icon: Icons.file_upload,
                label: Tr.iceAktar,
                color: RC.accentGreen,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.import);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Kullanım Kılavuzu dialog.
  void _showGuide(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? RC.bgDark2 : Colors.white,
        title: Text(
          Tr.kullanimKilavuzu,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : RC.black,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _guideItem(
                '1.',
                'Ana Sayfa\'dan + butonuna tıklayarak yeni kayıt ekleyin.',
                isDark,
              ),
              _guideItem(
                '2.',
                'Kayıt Defteri sekmesinde tüm ölçümlerinizi görüntüleyin.',
                isDark,
              ),
              _guideItem(
                '3.',
                'Analiz sekmesinde grafikler ve eA1c değerinizi takip edin.',
                isDark,
              ),
              _guideItem(
                '4.',
                'Verilerinizi CSV, Excel, JSON veya PDF olarak dışa aktarın.',
                isDark,
              ),
              _guideItem(
                '5.',
                'Ölçüm cihazından OCR ile otomatik değer okuyun.',
                isDark,
              ),
              _guideItem(
                '6.',
                'Tüm verileriniz cihazınızda saklanır, internet gerekmez.',
                isDark,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              Tr.tamam,
              style: TextStyle(color: isDark ? RC.accent : RC.blue),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _guideItem(String num, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            num,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? RC.accentGreen : RC.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
