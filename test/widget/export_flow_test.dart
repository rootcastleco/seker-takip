import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seker_takip/core/constants.dart';
import 'package:seker_takip/presentation/pages/export_page.dart';

void main() {
  Widget makeTestable(Widget child) {
    return ProviderScope(child: MaterialApp(home: child));
  }

  group('ExportPage', () {
    testWidgets('sayfa açılır ve format seçenekleri gösterilir', (
      tester,
    ) async {
      await tester.pumpWidget(makeTestable(const ExportPage()));
      await tester.pumpAndSettle();

      expect(find.text(Tr.disaAktar), findsWidgets);
      expect(find.text(Tr.csvFormat), findsOneWidget);
      expect(find.text(Tr.xlsxFormat), findsOneWidget);
      expect(find.text(Tr.jsonBackup), findsOneWidget);
    });

    testWidgets('varsayılan format CSV seçili', (tester) async {
      await tester.pumpWidget(makeTestable(const ExportPage()));
      await tester.pumpAndSettle();

      // CSV radio tile'ı seçili olmalı
      final csvRadio = tester.widget<RadioListTile<String>>(
        find.widgetWithText(RadioListTile<String>, Tr.csvFormat),
      );
      expect(csvRadio.checked, isTrue);
    });
  });
}
