import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import 'theme.dart';
import 'routes.dart';

/// Ana MaterialApp widget'ı.
class SekerTakipApp extends ConsumerWidget {
  const SekerTakipApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: RootcastleTheme.light,
      darkTheme: RootcastleTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.dashboard,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
