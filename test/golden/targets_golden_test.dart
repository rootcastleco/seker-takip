import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seker_takip/presentation/pages/targets_page.dart';

void main() {
  testWidgets('targets golden test', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TargetsPage()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TargetsPage),
      matchesGoldenFile('goldens/targets.png'),
    );
  });
}
