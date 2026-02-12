import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seker_takip/domain/entities/glucose_record.dart';
import 'package:seker_takip/presentation/widgets/record_table.dart';

void main() {
  final now = DateTime(2025, 1, 15);

  testWidgets('records table golden test', (tester) async {
    final records = [
      GlucoseRecordEntity(
        id: 1,
        tarih: DateTime(2025, 1, 15),
        sabahAc: 95,
        sabahTok: 130,
        oglenAc: 88,
        oglenTok: 145,
        aksamAc: 102,
        aksamTok: 155,
        yatmadanOnce: 120,
        gece03: 85,
        notlar: 'Normal',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RecordTable(records: records)),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(RecordTable),
      matchesGoldenFile('goldens/records_table.png'),
    );
  });
}
