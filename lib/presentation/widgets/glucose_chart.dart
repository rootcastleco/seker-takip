import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/glucose_record.dart';
import '../../core/constants.dart';
import '../../core/formatting.dart';
import 'glass_widgets.dart';

/// Son 7 günlük veriyi LineChart üzerinde gösteren widget.
class GlucoseLineChart extends StatelessWidget {
  const GlucoseLineChart({super.key, required this.records});

  final List<GlucoseRecordEntity> records;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Son 7 gün için veri ayıklama (sadece geçerli sayısal ölçümler)
    final points = <FlSpot>[];
    
    // Tarihe göre sırala
    final sortedRecords = List<GlucoseRecordEntity>.from(records)
      ..sort((a, b) => a.tarih.compareTo(b.tarih));

    double maxVal = 200; // minimum üst sınır
    double minVal = 50;  // minimum alt sınır

    for (int i = 0; i < sortedRecords.length; i++) {
      final r = sortedRecords[i];
      // Basitlik adına günün ortalama kan şekerini noktaya yansıtıyoruz
      final dailyVals = r.allMeasurements.whereType<int>().toList();
      if (dailyVals.isNotEmpty) {
        final dailyAvg = dailyVals.reduce((a, b) => a + b) / dailyVals.length;
        points.add(FlSpot(i.toDouble(), dailyAvg));

        if (dailyAvg > maxVal) maxVal = dailyAvg + 20;
        if (dailyAvg < minVal) minVal = dailyAvg > 20 ? dailyAvg - 20 : 0;
      }
    }

    if (points.isEmpty) {
      return Center(
        child: Text(
          'Grafik için yeterli veri yok.',
          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.only(right: 18, left: 12, top: 24, bottom: 12),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 50,
              verticalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: isDark ? Colors.white12 : Colors.black12,
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: isDark ? Colors.white12 : Colors.black12,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= sortedRecords.length) return const SizedBox();
                    final date = sortedRecords[index].tarih;
                    // Sadece gün.ay göster
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '${date.day}.${date.month}',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 50,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.left,
                    );
                  },
                  reservedSize: 32,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: isDark ? RC.glassBorder : RC.glassBorderLight),
            ),
            minX: 0,
            maxX: (sortedRecords.length - 1).toDouble(),
            minY: minVal,
            maxY: maxVal,
            lineBarsData: [
              LineChartBarData(
                spots: points,
                isCurved: true,
                gradient: LinearGradient(
                  colors: [RC.accent, RC.blue],
                ),
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      RC.accent.withOpacity(0.3),
                      RC.blue.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (spot) => isDark ? RC.bgDark2 : RC.glassWhiteLight,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '${spot.y.toInt()} mg/dL',
                      TextStyle(
                        color: isDark ? Colors.white : RC.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
