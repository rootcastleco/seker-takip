import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// Tarih aralığı seçici widget.
class DateRangePickerWidget extends StatelessWidget {
  const DateRangePickerWidget({
    super.key,
    this.startDate,
    this.endDate,
    required this.onChanged,
    this.onClear,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(DateTime? start, DateTime? end) onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickRange(context),
            icon: const Icon(Icons.date_range, size: 18),
            label: Text(
              startDate != null && endDate != null
                  ? '${_fmt(startDate!)} – ${_fmt(endDate!)}'
                  : Tr.tarihAraligi,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (startDate != null) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.clear, size: 18),
            tooltip: Tr.temizle,
            onPressed: () {
              onChanged(null, null);
              onClear?.call();
            },
          ),
        ],
      ],
    );
  }

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      locale: const Locale('tr', 'TR'),
    );
    if (result != null) {
      onChanged(result.start, result.end);
    }
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}
