import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seker_takip/core/constants.dart';
import 'package:seker_takip/domain/entities/glucose_record.dart';
import 'package:seker_takip/presentation/widgets/record_table.dart';

void main() {
  final now = DateTime.now();
  final records = [
    GlucoseRecordEntity(
      id: 1,
      tarih: DateTime(2025, 1, 15),
      sabahAc: 95,
      sabahTok: 130,
      createdAt: now,
      updatedAt: now,
    ),
    GlucoseRecordEntity(
      id: 2,
      tarih: DateTime(2025, 1, 14),
      sabahAc: 110,
      oglenTok: 155,
      notlar: 'Test notu',
      createdAt: now,
      updatedAt: now,
    ),
  ];

  Widget makeTestable(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('RecordTable', () {
    testWidgets('boş liste mesajı gösterir', (tester) async {
      await tester.pumpWidget(makeTestable(const RecordTable(records: [])));
      expect(find.text(Tr.kayitBulunamadi), findsOneWidget);
    });

    testWidgets('kayıtlar gösterilir', (tester) async {
      await tester.pumpWidget(makeTestable(RecordTable(records: records)));
      await tester.pumpAndSettle();

      expect(find.text('15.01.2025'), findsOneWidget);
      expect(find.text('14.01.2025'), findsOneWidget);
      expect(find.text('95'), findsOneWidget);
    });

    testWidgets('hedef dışı uyarı ikonu görünür', (tester) async {
      await tester.pumpWidget(
        makeTestable(
          RecordTable(
            records: [
              GlucoseRecordEntity(
                id: 1,
                tarih: DateTime(2025, 1, 15),
                sabahAc: 150, // > 100, hedef dışı
                createdAt: now,
                updatedAt: now,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_amber), findsWidgets);
    });
  });
}
