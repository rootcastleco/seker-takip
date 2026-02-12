import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../widgets/glass_widgets.dart';

/// Hakkında sayfası — Geliştirici ve uygulama bilgisi.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassScaffold(
      appBar: const GlassAppBar(title: Tr.hakkinda),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, kToolbarHeight + 50, 24, 24),
        children: [
          // Logo
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: RC.blue.withValues(alpha: 0.3),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            kAppName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : RC.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'v$kAppVersion',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
          ),
          const SizedBox(height: 24),

          // Açıklama
          GlassCard(
            child: Text(
              Tr.uygulamaAciklama,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            ),
          ),

          // Geliştirici bilgisi
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassSectionHeader(title: Tr.gelistirici, icon: Icons.code),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: RC.green.withValues(alpha: 0.2),
                    ),
                    child: const Icon(Icons.person, color: RC.accentGreen),
                  ),
                  title: Text(
                    Tr.gelistiriciAdi,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    Tr.webSitesi,
                    style: TextStyle(color: isDark ? RC.accent : RC.blue),
                  ),
                ),
              ],
            ),
          ),

          // Özellikler listesi
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassSectionHeader(title: 'Özellikler', icon: Icons.star),
                const SizedBox(height: 8),
                _featureTile(Icons.wifi_off, 'Tamamen çevrimdışı', isDark),
                _featureTile(Icons.language, 'Tam Türkçe arayüz', isDark),
                _featureTile(Icons.lock, 'SHA-256 checksum koruması', isDark),
                _featureTile(
                  Icons.science,
                  'Tahmini HbA1c (eA1c) hesaplama',
                  isDark,
                ),
                _featureTile(
                  Icons.show_chart,
                  'Glukoz stabilite analizi',
                  isDark,
                ),
                _featureTile(
                  Icons.picture_as_pdf,
                  'Profesyonel PDF rapor',
                  isDark,
                ),
                _featureTile(
                  Icons.notifications_active,
                  'Akıllı hatırlatıcılar',
                  isDark,
                ),
                _featureTile(
                  Icons.file_download,
                  'CSV / XLSX / JSON dışa aktarım',
                  isDark,
                ),
                _featureTile(Icons.camera_alt, 'OCR ile glükoz tarama', isDark),
                _featureTile(Icons.no_accounts, 'Reklamsız, ücretsiz', isDark),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Alt bilgi
          Text(
            '© ${DateTime.now().year} ${Tr.gelistiriciAdi}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
          ),
          Text(
            Tr.webSitesi,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: isDark ? RC.accent : RC.blue),
          ),
        ],
      ),
    );
  }

  static Widget _featureTile(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDark ? RC.accentGreen : RC.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
