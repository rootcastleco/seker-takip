import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../app/theme.dart';
import '../widgets/rootcastle_app_bar.dart';

/// Hakkında sayfası — Geliştirici ve uygulama bilgisi.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const RootcastleAppBar(title: Tr.hakkinda),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Logo / İkon
          CircleAvatar(
            radius: 48,
            backgroundColor: RootcastleColors.blue,
            child: const Icon(Icons.bloodtype, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            kAppName,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: RootcastleColors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'v$kAppVersion',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Açıklama
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                Tr.uygulamaAciklama,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Geliştirici bilgisi
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Tr.gelistirici,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: RootcastleColors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: RootcastleColors.green,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: const Text(
                      Tr.gelistiriciAdi,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(Tr.webSitesi),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Özellikler listesi
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Özellikler',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: RootcastleColors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _featureTile(Icons.wifi_off, 'Tamamen çevrimdışı'),
                  _featureTile(Icons.language, 'Tam Türkçe arayüz'),
                  _featureTile(Icons.lock, 'SHA-256 checksum koruması'),
                  _featureTile(Icons.science, 'Tahmini HbA1c (eA1c) hesaplama'),
                  _featureTile(Icons.show_chart, 'Glukoz stabilite analizi'),
                  _featureTile(Icons.picture_as_pdf, 'Profesyonel PDF rapor'),
                  _featureTile(
                    Icons.notifications_active,
                    'Akıllı hatırlatıcılar',
                  ),
                  _featureTile(
                    Icons.file_download,
                    'CSV / XLSX / JSON dışa aktarım',
                  ),
                  _featureTile(Icons.no_accounts, 'Reklamsız, ücretsiz'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Alt bilgi
          Text(
            '© ${DateTime.now().year} ${Tr.gelistiriciAdi}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          Text(
            '${Tr.webSitesi}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: RootcastleColors.blue,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _featureTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: RootcastleColors.green),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
