import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../core/services/voice_service.dart';
import 'theme.dart';
import 'routes.dart';
import 'splash_screen.dart';
import '../presentation/layout/main_layout.dart';

/// Ana MaterialApp widget'ı.
class SekerTakipApp extends ConsumerStatefulWidget {
  const SekerTakipApp({super.key});

  @override
  ConsumerState<SekerTakipApp> createState() => _SekerTakipAppState();
}

class _SekerTakipAppState extends ConsumerState<SekerTakipApp> {
  bool _showSplash = true;

  void _onSplashDone() {
    setState(() => _showSplash = false);
    // Karşılama sesi
    SystemVoiceService.instance.speak(Tr.sesKarsilama);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: RootcastleTheme.light,
      darkTheme: RootcastleTheme.dark,
      themeMode: ThemeMode.dark,
      builder: (context, child) {
        if (_showSplash) {
          return SplashScreen(onDone: _onSplashDone);
        }
        return child!;
      },
      home: const MainLayout(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
      routes: AppRoutes.routes,
    );
  }
}
