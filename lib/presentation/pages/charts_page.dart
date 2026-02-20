import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/formatting.dart';
import '../../domain/entities/glucose_record.dart';
import '../../domain/usecases/ea1c_calculator.dart';
import '../state/providers.dart';
import '../widgets/glass_widgets.dart';

/// Analiz & Grafikler sayfası — Tab 3 (Analiz).
class ChartsPage extends ConsumerWidget {
  const ChartsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last90Async = ref.watch(last90DaysRecordsProvider);
    final last7Async = ref.watch(last7DaysRecordsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // ─── Son 7 Gün Trend Grafiği ────────────────────
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassSectionHeader(title: Tr.gunlukTrend, icon: Icons.show_chart),
              const SizedBox(height: 8),
              last7Async.when(
                data: (records) {
                  if (records.isEmpty) {
                    return _emptyState(isDark);
                  }
                  return _TrendChart(records: records, isDark: isDark);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('${Tr.hata}: $e'),
              ),
            ],
          ),
        ),

        // ─── eA1c Özet ──────────────────────────────────
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassSectionHeader(title: Tr.ea1cBaslik, icon: Icons.science),
              const SizedBox(height: 8),
              last90Async.when(
                data: (records) {
                  final result = Ea1cCalculator.calculate(records);
                  if (result == null) {
                    return Text(
                      Tr.ea1cYetersiz,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                          children: [
                            const TextSpan(text: 'eA1c: '),
                            TextSpan(
                              text: '%${result.formattedEa1c}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isDark ? RC.accent : RC.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ortalama: ${result.formattedAvg} mg/dL '
                        '(${result.measurementCount} ölçüm, '
                        '${result.recordCount} kayıt)',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Tr.ea1cBilgiNot,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange.shade400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('${Tr.hata}: $e'),
              ),
            ],
          ),
        ),

        // ─── Stabilite Göstergesi ────────────────────────
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassSectionHeader(title: Tr.stabiliteBaslik, icon: Icons.shield),
              const SizedBox(height: 8),
              last90Async.when(
                data: (records) {
                  final result = Ea1cCalculator.calculateVariability(records);
                  if (result == null) {
                    return Text(
                      Tr.stabiliteYetersiz,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                      ),
                    );
                  }
                  final color = _stabilityColor(result.level);
                  final label = _stabilityLabel(result.level);
                  final icon = _stabilityIcon(result.level);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(icon, color: color, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            label,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${Tr.standartSapma}: ${result.formattedSD} mg/dL  '
                        '(CV: %${result.formattedCV})',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('${Tr.hata}: $e'),
              ),
            ],
          ),
        ),

        // ─── Son Ölçümler Listesi ────────────────────────
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassSectionHeader(title: Tr.sonOlcumler, icon: Icons.history),
              const SizedBox(height: 8),
              last7Async.when(
                data: (records) {
                  if (records.isEmpty) return _emptyState(isDark);
                  return Column(
                    children: records.take(10).map((r) {
                      final vals = r.allMeasurements.whereType<int>().toList();
                      final avg = vals.isEmpty
                          ? 0.0
                          : vals.reduce((a, b) => a + b) / vals.length;
                      final isHigh = vals.any((v) => v > 180);
                      final isLow = vals.any((v) => v < 70);
                      final valueColor = isLow
                          ? Colors.orange
                          : isHigh
                          ? Colors.red
                          : (isDark ? RC.accentGreen : RC.green);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 28,
                              decoration: BoxDecoration(
                                color: valueColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                formatDate(r.tarih),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            Text(
                              '${avg.toStringAsFixed(0)} mg/dL',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: valueColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('${Tr.hata}: $e'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _emptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          Tr.veriYok,
          style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
        ),
      ),
    );
  }

  static Color _stabilityColor(StabilityLevel level) {
    switch (level) {
      case StabilityLevel.stable:
        return RC.accentGreen;
      case StabilityLevel.moderate:
        return Colors.orange;
      case StabilityLevel.high:
        return Colors.red;
    }
  }

  static String _stabilityLabel(StabilityLevel level) {
    switch (level) {
      case StabilityLevel.stable:
        return Tr.stabiliteDusuk;
      case StabilityLevel.moderate:
        return Tr.stabiliteOrta;
      case StabilityLevel.high:
        return Tr.stabiliteYuksek;
    }
  }

  static IconData _stabilityIcon(StabilityLevel level) {
    switch (level) {
      case StabilityLevel.stable:
        return Icons.shield;
      case StabilityLevel.moderate:
        return Icons.warning_amber;
      case StabilityLevel.high:
        return Icons.error;
    }
  }
}

// ─── Custom Trend Chart (no external dep) ────────────────────

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.records, required this.isDark});

  final List<GlucoseRecordEntity> records;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Flatten daily averages
    final dailyData = <DateTime, List<int>>{};
    for (final r in records) {
      final day = DateTime(r.tarih.year, r.tarih.month, r.tarih.day);
      final vals = r.allMeasurements.whereType<int>().toList();
      dailyData.putIfAbsent(day, () => []).addAll(vals);
    }

    if (dailyData.isEmpty) {
      return _emptyChart();
    }

    final sortedDays = dailyData.keys.toList()..sort();
    final averages = sortedDays.map((d) {
      final vals = dailyData[d]!;
      return vals.reduce((a, b) => a + b) / vals.length;
    }).toList();

    final maxVal = averages.reduce(math.max);
    final minVal = averages.reduce(math.min);
    final range = (maxVal - minVal).clamp(1.0, double.infinity);

    return SizedBox(
      height: 180,
      child: CustomPaint(
        size: const Size(double.infinity, 180),
        painter: _ChartPainter(
          values: averages,
          labels: sortedDays,
          minVal: minVal,
          range: range,
          isDark: isDark,
        ),
      ),
    );
  }

  Widget _emptyChart() {
    return SizedBox(
      height: 180,
      child: Center(
        child: Text(
          Tr.veriYok,
          style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.values,
    required this.labels,
    required this.minVal,
    required this.range,
    required this.isDark,
  });

  final List<double> values;
  final List<DateTime> labels;
  final double minVal;
  final double range;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final chartLeft = 40.0;
    final chartBottom = size.height - 30.0;
    final chartTop = 10.0;
    final chartRight = size.width - 10.0;
    final chartWidth = chartRight - chartLeft;
    final chartHeight = chartBottom - chartTop;

    // Grid lines
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.08)
      ..strokeWidth = 0.5;

    for (var i = 0; i <= 4; i++) {
      final y = chartTop + (chartHeight / 4) * i;
      canvas.drawLine(Offset(chartLeft, y), Offset(chartRight, y), gridPaint);

      // Y-axis labels
      final val = minVal + range * (1 - i / 4);
      final tp = TextPainter(
        text: TextSpan(
          text: val.toStringAsFixed(0),
          style: TextStyle(
            fontSize: 9,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.5,
            ),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(chartLeft - tp.width - 4, y - tp.height / 2));
    }

    // Target zone (70–140)
    final targetPaint = Paint()..color = RC.accentGreen.withOpacity(0.08);
    final targetTop =
        chartTop + chartHeight * (1 - (140 - minVal) / range).clamp(0.0, 1.0);
    final targetBottom =
        chartTop + chartHeight * (1 - (70 - minVal) / range).clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTRB(chartLeft, targetTop, chartRight, targetBottom),
      targetPaint,
    );

    // Line + dots
    final linePaint = Paint()
      ..color = RC.accent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = RC.accent
      ..style = PaintingStyle.fill;

    final path = Path();
    final step = values.length > 1 ? chartWidth / (values.length - 1) : 0.0;

    for (var i = 0; i < values.length; i++) {
      final x = chartLeft + step * i;
      final normalized = ((values[i] - minVal) / range).clamp(0.0, 1.0);
      final y = chartBottom - (normalized * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Color dot by value
      final dotColor = values[i] < 70
          ? Colors.orange
          : values[i] > 180
          ? Colors.red
          : RC.accentGreen;
      canvas.drawCircle(Offset(x, y), 4, dotPaint..color = dotColor);
      canvas.drawCircle(
        Offset(x, y),
        2,
        Paint()..color = isDark ? RC.bgDark1 : Colors.white,
      );

      // X-axis label
      if (labels.length > i) {
        final d = labels[i];
        final tp = TextPainter(
          text: TextSpan(
            text: '${d.day}/${d.month}',
            style: TextStyle(
              fontSize: 9,
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.5,
              ),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, chartBottom + 6));
      }
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
