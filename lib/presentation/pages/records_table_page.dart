import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../core/constants.dart';
import '../../domain/entities/glucose_record.dart';
import '../state/providers.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/record_table.dart';
import '../widgets/date_range_picker.dart';

/// Kayıtlar tablosu sayfası.
class RecordsTablePage extends ConsumerStatefulWidget {
  const RecordsTablePage({super.key});

  @override
  ConsumerState<RecordsTablePage> createState() => _RecordsTablePageState();
}

class _RecordsTablePageState extends ConsumerState<RecordsTablePage> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  List<GlucoseRecordEntity> _filter(List<GlucoseRecordEntity> records) {
    var filtered = records;

    // Tarih aralığı
    if (_startDate != null && _endDate != null) {
      final start = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
      );
      final end = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        23,
        59,
        59,
      );
      filtered = filtered
          .where((r) => !r.tarih.isBefore(start) && !r.tarih.isAfter(end))
          .toList();
    }

    // Not arama
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (r) =>
                (r.notlar ?? '').toLowerCase().contains(q) ||
                (r.ilacInsulinAdi ?? '').toLowerCase().contains(q),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(glucoseRecordsProvider);

    return Column(
      children: [
        const SizedBox(height: 16),
        // Filtre alanı
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: GlassCard(
            child: Column(
              children: [
                DateRangePickerWidget(
                  startDate: _startDate,
                  endDate: _endDate,
                  onChanged: (start, end) {
                    setState(() {
                      _startDate = start;
                      _endDate = end;
                    });
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration:
                      glassInputDecoration(
                        context: context,
                        label: 'Not veya ilaç adında ara...',
                      ).copyWith(
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                      ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Tablo
        Expanded(
          child: recordsAsync.when(
            data: (records) {
              final filtered = _filter(records);
              return RecordTable(
                records: filtered,
                onTap: (record) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.recordEdit,
                    arguments: record.id,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('${Tr.hata}: $e')),
          ),
        ),
      ],
    );
  }
}
