import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seker_takip/core/constants.dart';
import 'package:seker_takip/presentation/pages/record_edit_page.dart';

void main() {
  Widget makeTestable(Widget child) {
    return ProviderScope(child: MaterialApp(home: child));
  }

  group('RecordEditPage - form validasyonu', () {
    testWidgets('sayfa açılır ve form alanları görünür', (tester) async {
      await tester.pumpWidget(makeTestable(const RecordEditPage()));
      await tester.pumpAndSettle();

      expect(find.text(Tr.yeniKayitEkle), findsOneWidget);
      expect(find.text(Tr.sabahAc), findsOneWidget);
      expect(find.text(Tr.sabahTok), findsOneWidget);
      expect(find.text(Tr.oglenAc), findsOneWidget);
    });

    testWidgets('kaydet butonu mevcut', (tester) async {
      await tester.pumpWidget(makeTestable(const RecordEditPage()));
      await tester.pumpAndSettle();

      expect(find.text(Tr.kaydet), findsOneWidget);
    });

    testWidgets('boş form kaydetmeye çalışınca uyarı gösterir', (tester) async {
      await tester.pumpWidget(makeTestable(const RecordEditPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text(Tr.kaydet));
      await tester.pumpAndSettle();

      // En az bir ölçüm gerekiyor snackbar'ı
      expect(find.text(Tr.enAzBirOlcum), findsOneWidget);
    });
  });
}
