import 'package:flutter/material.dart';
import '../presentation/pages/profile_page.dart';
import '../presentation/pages/record_edit_page.dart';
import '../presentation/pages/export_page.dart';
import '../presentation/pages/import_page.dart';
import '../presentation/pages/targets_page.dart';
import '../presentation/pages/diagnostics_page.dart';
import '../presentation/pages/about_page.dart';
import '../presentation/pages/medications_page.dart';
import '../presentation/pages/sofia_ai_page.dart';

/// Uygulama route tanımlamaları.
///
/// Ana navigasyon MainLayout bottom nav ile yapılır.
/// Buradaki route'lar yalnızca push ile açılan alt sayfalardır.
class AppRoutes {
  AppRoutes._();

  static const String profile = '/profile';
  static const String recordEdit = '/record/edit';
  static const String export = '/export';
  static const String import = '/import';
  static const String targets = '/targets';
  static const String diagnostics = '/diagnostics';
  static const String about = '/about';
  static const String medications = '/medications';
  static const String sofiaAi = '/sofia-ai';

  static Map<String, WidgetBuilder> get routes => {
    profile: (_) => const ProfilePage(),
    export: (_) => const ExportPage(),
    import: (_) => const ImportPage(),
    targets: (_) => const TargetsPage(),
    diagnostics: (_) => const DiagnosticsPage(),
    about: (_) => const AboutPage(),
    medications: (_) => const _MedicationsPageWrapper(),
    sofiaAi: (_) => const SofiaAiPage(),
  };

  /// RecordEditPage argüman ile çalıştığından onGenerateRoute kullanılır.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == recordEdit) {
      final recordId = settings.arguments as int?;
      return MaterialPageRoute(
        builder: (_) => RecordEditPage(recordId: recordId),
      );
    }
    return null;
  }
}

/// İlaçlar sayfası wrapper — Scaffold ile tam sayfa.
class _MedicationsPageWrapper extends StatelessWidget {
  const _MedicationsPageWrapper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İlaçlarım')),
      body: const MedicationsPage(),
    );
  }
}
