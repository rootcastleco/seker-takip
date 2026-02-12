import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seker_takip/app/app.dart';
import 'package:seker_takip/core/constants.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full app flow: profil → kayıt → tablo', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SekerTakipApp()));
    await tester.pumpAndSettle();

    // Dashboard görünmeli
    expect(find.text(kAppName), findsOneWidget);
    expect(find.text(Tr.yeniKayitEkle), findsOneWidget);

    // Profil sayfasına git
    await tester.tap(find.text(Tr.kisiselBilgiler));
    await tester.pumpAndSettle();
    expect(find.text(Tr.kisiselBilgiler), findsWidgets);

    // İsim gir ve kaydet
    await tester.enterText(
      find.widgetWithText(TextFormField, Tr.isimSoyisim),
      'Test Kişi',
    );
    await tester.tap(find.text(Tr.kaydet));
    await tester.pumpAndSettle();

    // Geri dön
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // Yeni kayıt ekle
    await tester.tap(find.text(Tr.yeniKayitEkle));
    await tester.pumpAndSettle();
    expect(find.text(Tr.yeniKayitEkle), findsWidgets);

    // Sabah Aç değeri gir
    await tester.enterText(
      find.widgetWithText(TextFormField, Tr.sabahAc),
      '95',
    );
    await tester.tap(find.text(Tr.kaydet));
    await tester.pumpAndSettle();

    // Kayıtlar sayfasına git (ana sayfadan)
    await tester.tap(find.text(Tr.kayitlar));
    await tester.pumpAndSettle();

    // Hedefler sayfası
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Tr.idealHedefler));
    await tester.pumpAndSettle();
    expect(find.text(Tr.hedeflerBaslik), findsOneWidget);
  });
}
