import 'package:flutter/material.dart';
import '../presentation/pages/profile_page.dart';
import '../presentation/pages/record_edit_page.dart';
import '../presentation/pages/export_page.dart';
import '../presentation/pages/import_page.dart';
import '../presentation/pages/targets_page.dart';
import '../presentation/pages/diagnostics_page.dart';
import '../presentation/pages/about_page.dart';

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

  static Map<String, WidgetBuilder> get routes => {
    profile: (_) => const ProfilePage(),
    export: (_) => const ExportPage(),
    import: (_) => const ImportPage(),
    targets: (_) => const TargetsPage(),
    diagnostics: (_) => const DiagnosticsPage(),
    about: (_) => const AboutPage(),
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
