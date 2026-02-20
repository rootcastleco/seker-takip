import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/formatting.dart';
import '../../domain/usecases/ea1c_calculator.dart';
import '../../features/dashboard/logic/glucose_analyzer.dart';
import '../../app/routes.dart';
import '../state/providers.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/glucose_chart.dart';
import '../widgets/glycemic_predictor_card.dart';

/// Ana sayfa — Dashboard (Tab 1).
///
/// Sadece özet kartları gösterir. Navigasyon butonları kaldırıldı
/// çünkü artık BottomNavigationBar mevcut.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayRecordsProvider);
    final last7Async = ref.watch(last7DaysRecordsProvider);
    final last90Async = ref.watch(last90DaysRecordsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(todayRecordsProvider);
        ref.invalidate(last7DaysRecordsProvider);
        ref.invalidate(last90DaysRecordsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // App title
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Image.asset('assets/images/logo.png', height: 32),
                const SizedBox(width: 10),
                Text(
                  kAppName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : RC.blue,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // ─── Sofia AI Hızlı Erişim ──────────────
          GlassCard(
            padding: EdgeInsets.zero,
            borderColor: Colors.purple.withOpacity(0.3),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, AppRoutes.sofiaAi),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [RC.blue, RC.accentGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'S',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Tr.sofiaAi,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : RC.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              Tr.sofiaAiAciklama,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: isDark ? Colors.white30 : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Besin Etkisi Tahmini ───────────────────
          GlycemicPredictorCard(
            onOpenScanner: () =>
                Navigator.pushNamed(context, AppRoutes.foodScanner),
          ),

          // ─── Bugünün Özeti ────────────────────────
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassSectionHeader(title: Tr.bugunOzet, icon: Icons.today),
                const SizedBox(height: 8),
                todayAsync.when(
                  data: (records) {
                    if (records.isEmpty) {
                      return Text(
                        'Bugün henüz kayıt yok.',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      );
                    }
                    return Column(
                      children: records
                          .map(
                            (r) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                '${formatDate(r.tarih)} — '
                                'Sabah Aç: ${formatGlucose(r.sabahAc)}, '
                                'Sabah Tok: ${formatGlucose(r.sabahTok)}',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('${Tr.hata}: $e'),
                ),
              ],
            ),
          ),

          // ─── Son 7 Gün Ortalaması ─────────────────
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassSectionHeader(title: Tr.son7Gun, icon: Icons.date_range),
                const SizedBox(height: 8),
                last7Async.when(
                  data: (records) {
                    if (records.isEmpty) {
                      return Text(
                        'Son 7 günde kayıt yok.',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      );
                    }
                    final allVals = records
                        .expand((r) => r.allMeasurements)
                        .whereType<int>()
                        .toList();
                    if (allVals.isEmpty) {
                      return Text(
                        'Ölçüm verisi yok.',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      );
                    }
                    final avg =
                        allVals.reduce((a, b) => a + b) / allVals.length;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          '${records.length} kayıt — '
                          'Genel ortalama: ${avg.toStringAsFixed(0)} mg/dL',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GlucoseLineChart(records: records),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('${Tr.hata}: $e'),
                ),
              ],
            ),
          ),

          // ─── eA1c Kartı ───────────────────────────
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
                                  fontSize: 24,
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
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('${Tr.hata}: $e'),
                ),
              ],
            ),
          ),

          // ─── Stabilite Göstergesi ─────────────────
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassSectionHeader(
                  title: Tr.stabiliteBaslik,
                  icon: Icons.show_chart,
                ),
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

                    // Yüksek SD varsa sesli uyarı
                    if (result.standardDeviation > 40) {
                      GlucoseAnalyzer.instance.announceHighVariability(result);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(icon, color: color, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              label,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: color,
                                fontSize: 16,
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
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('${Tr.hata}: $e'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _stabilityColor(StabilityLevel level) {
    switch (level) {
      case StabilityLevel.stable:
        return RC.accentGreen;
      case StabilityLevel.moderate:
        return Colors.orange;
      case StabilityLevel.high:
        return Colors.red;
    }
  }

  String _stabilityLabel(StabilityLevel level) {
    switch (level) {
      case StabilityLevel.stable:
        return Tr.stabiliteDusuk;
      case StabilityLevel.moderate:
        return Tr.stabiliteOrta;
      case StabilityLevel.high:
        return Tr.stabiliteYuksek;
    }
  }

  IconData _stabilityIcon(StabilityLevel level) {
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
