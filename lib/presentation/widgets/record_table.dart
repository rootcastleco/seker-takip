import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/formatting.dart';
import '../../domain/entities/glucose_record.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

/// Hedef dışı uyarı ikonu döner.
Widget? glucoseWarningIcon(int? value, {bool isFasting = true}) {
  if (value == null) return null;
  final threshold = isFasting ? kTargetAksFasting : kTargetPostprandial;
  if (value >= threshold) {
    return Tooltip(
      message: Tr.hedefDisi,
      child: const Icon(Icons.warning_amber, color: Colors.orange, size: 16),
    );
  }
  return null;
}

/// Yatay kaydırmalı kayıt tablosu.
class RecordTable extends StatelessWidget {
  const RecordTable({super.key, required this.records, this.onTap});

  final List<GlucoseRecordEntity> records;
  final void Function(GlucoseRecordEntity)? onTap;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            Tr.kayitBulunamadi,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 14,
        headingRowColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.primaryContainer.withAlpha(60),
        ),
        columns: const [
          DataColumn(label: Text(Tr.tarihKolonu)),
          DataColumn(label: Text('Sabah\nAç'), numeric: true),
          DataColumn(label: Text('Sabah\nTok(2s)'), numeric: true),
          DataColumn(label: Text('Öğlen\nAç'), numeric: true),
          DataColumn(label: Text('Öğlen\nTok(2s)'), numeric: true),
          DataColumn(label: Text('Akşam\nAç'), numeric: true),
          DataColumn(label: Text('Akşam\nTok(2s)'), numeric: true),
          DataColumn(label: Text('Yat.\nÖnce'), numeric: true),
          DataColumn(label: Text('Gece\n03:00'), numeric: true),
          DataColumn(label: Text('Not')),
        ],
        rows: records.map((r) => _buildRow(context, r)).toList(),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, GlucoseRecordEntity r) {
    return DataRow(
      onSelectChanged: onTap != null ? (_) => onTap!(r) : null,
      cells: [
        DataCell(Text(formatDate(r.tarih))),
        _measureCell(r.sabahAc, isFasting: true),
        _measureCell(r.sabahTok, isFasting: false),
        _measureCell(r.oglenAc, isFasting: true),
        _measureCell(r.oglenTok, isFasting: false),
        _measureCell(r.aksamAc, isFasting: true),
        _measureCell(r.aksamTok, isFasting: false),
        _measureCell(r.yatmadanOnce, isFasting: false),
        _measureCell(r.gece03, isFasting: false),
        DataCell(
          Text(r.notlar ?? '', overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
      ],
    );
  }

  DataCell _measureCell(int? value, {required bool isFasting}) {
    final warning = glucoseWarningIcon(value, isFasting: isFasting);
    return DataCell(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(formatGlucose(value)),
          if (warning != null) ...[const SizedBox(width: 2), warning],
        ],
      ),
    );
  }
}
