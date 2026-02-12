import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/constants.dart';
import '../../core/formatting.dart';
import '../../domain/usecases/ea1c_calculator.dart';
import '../../features/dashboard/logic/glucose_analyzer.dart';
import '../state/providers.dart';
import '../widgets/rootcastle_app_bar.dart';

/// Ana sayfa — Dashboard.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayRecordsProvider);
    final last7Async = ref.watch(last7DaysRecordsProvider);
    final last90Async = ref.watch(last90DaysRecordsProvider);

    return Scaffold(
      appBar: const RootcastleAppBar(title: kAppName),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayRecordsProvider);
          ref.invalidate(last7DaysRecordsProvider);
          ref.invalidate(last90DaysRecordsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Bugünün özeti
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Tr.bugunOzet,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: RootcastleColors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    todayAsync.when(
                      data: (records) {
                        if (records.isEmpty) {
                          return const Text('Bugün henüz kayıt yok.');
                        }
                        return Column(
                          children: records
                              .map(
                                (r) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    '${formatDate(r.tarih)} — '
                                    'Sabah Aç: ${formatGlucose(r.sabahAc)}, '
                                    'Sabah Tok: ${formatGlucose(r.sabahTok)}',
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
            ),
            const SizedBox(height: 12),

            // Son 7 gün ortalaması
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Tr.son7Gun,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: RootcastleColors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    last7Async.when(
                      data: (records) {
                        if (records.isEmpty) {
                          return const Text('Son 7 günde kayıt yok.');
                        }
                        final allVals = records
                            .expand((r) => r.allMeasurements)
                            .whereType<int>()
                            .toList();
                        if (allVals.isEmpty) {
                          return const Text('Ölçüm verisi yok.');
                        }
                        final avg =
                            allVals.reduce((a, b) => a + b) / allVals.length;
                        return Text(
                          '${records.length} kayıt — '
                          'Genel ortalama: ${avg.toStringAsFixed(0)} mg/dL',
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('${Tr.hata}: $e'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ─── eA1c Kartı ──────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.science,
                          color: RootcastleColors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Tr.ea1cBaslik,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: RootcastleColors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    last90Async.when(
                      data: (records) {
                        final result = Ea1cCalculator.calculate(records);
                        if (result == null) {
                          return Text(
                            Tr.ea1cYetersiz,
                            style: TextStyle(color: Colors.grey.shade600),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  const TextSpan(text: 'eA1c: '),
                                  TextSpan(
                                    text: '%${result.formattedEa1c}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: RootcastleColors.blue,
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
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Tr.ea1cBilgiNot,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.shade700,
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
            ),
            const SizedBox(height: 12),

            // ─── Stabilite Göstergesi ────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.show_chart,
                          color: RootcastleColors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Tr.stabiliteBaslik,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: RootcastleColors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    last90Async.when(
                      data: (records) {
                        final result = Ea1cCalculator.calculateVariability(
                          records,
                        );
                        if (result == null) {
                          return Text(
                            Tr.stabiliteYetersiz,
                            style: TextStyle(color: Colors.grey.shade600),
                          );
                        }
                        final color = _stabilityColor(result.level);
                        final label = _stabilityLabel(result.level);
                        final icon = _stabilityIcon(result.level);

                        // Yüksek SD varsa sesli uyarı
                        if (result.standardDeviation > 40) {
                          GlucoseAnalyzer.instance.announceHighVariability(
                            result,
                          );
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
                              style: Theme.of(context).textTheme.bodySmall,
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
            ),
            const SizedBox(height: 24),

            // Hızlı erişim butonları
            _QuickButton(
              icon: Icons.add_circle_outline,
              label: Tr.yeniKayitEkle,
              color: RootcastleColors.green,
              onTap: () => Navigator.pushNamed(context, AppRoutes.recordEdit),
            ),
            _QuickButton(
              icon: Icons.list_alt,
              label: Tr.kayitlar,
              color: RootcastleColors.blue,
              onTap: () => Navigator.pushNamed(context, AppRoutes.records),
            ),
            _QuickButton(
              icon: Icons.file_download,
              label: Tr.disaAktar,
              color: RootcastleColors.blue,
              onTap: () => Navigator.pushNamed(context, AppRoutes.export),
            ),
            _QuickButton(
              icon: Icons.file_upload,
              label: Tr.iceAktar,
              color: RootcastleColors.blue,
              onTap: () => Navigator.pushNamed(context, AppRoutes.import),
            ),
            _QuickButton(
              icon: Icons.person,
              label: Tr.kisiselBilgiler,
              color: RootcastleColors.blue,
              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
            ),
            _QuickButton(
              icon: Icons.flag,
              label: Tr.idealHedefler,
              color: RootcastleColors.green,
              onTap: () => Navigator.pushNamed(context, AppRoutes.targets),
            ),
            _QuickButton(
              icon: Icons.settings,
              label: Tr.ayarlar,
              color: RootcastleColors.blue,
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
            _QuickButton(
              icon: Icons.info_outline,
              label: Tr.hakkinda,
              color: RootcastleColors.green,
              onTap: () => Navigator.pushNamed(context, AppRoutes.about),
            ),
            _QuickButton(
              icon: Icons.bug_report,
              label: Tr.tanilamaLoglari,
              color: Colors.grey,
              onTap: () => Navigator.pushNamed(context, AppRoutes.diagnostics),
            ),
          ],
        ),
      ),
    );
  }

  Color _stabilityColor(StabilityLevel level) {
    switch (level) {
      case StabilityLevel.stable:
        return RootcastleColors.green;
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

class _QuickButton extends StatelessWidget {
  const _QuickButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        onTap: onTap,
      ),
    );
  }
}
