import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seker_takip/presentation/pages/dashboard_page.dart';

void main() {
  Widget makeTestable(Widget child) {
    return ProviderScope(child: MaterialApp(home: child));
  }

  testWidgets('dashboard golden test', (tester) async {
    await tester.pumpWidget(makeTestable(const DashboardPage()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(DashboardPage),
      matchesGoldenFile('goldens/dashboard.png'),
    );
  });
}
