import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../core/constants.dart';
import '../../core/formatting.dart';
import '../../core/logger/logger.dart';
import '../../data/export_import/csv_exporter.dart';
import '../../data/export_import/xlsx_exporter.dart';
import '../../data/export_import/json_backup_exporter.dart';
import '../../data/export_import/pdf_report_generator.dart';
import '../state/providers.dart';
import '../widgets/glass_widgets.dart';

/// Dışa aktarma sayfası.
class ExportPage extends ConsumerStatefulWidget {
  const ExportPage({super.key});

  @override
  ConsumerState<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends ConsumerState<ExportPage> {
  String _selectedFormat = 'csv';
  bool _exporting = false;

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final records = await ref.read(glucoseRepositoryProvider).getAll();
      final profile = await ref.read(profileRepositoryProvider).getProfile();
      final medications = await ref.read(medicationsProvider.future);
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = formatExportTimestamp(DateTime.now());
      final baseName = '${kExportPrefix}_$timestamp';

      String filePath;
      if (_selectedFormat == 'csv') {
        filePath = p.join(dir.path, '$baseName.csv');
        await CsvExporter.writeToFile(records, filePath);
      } else if (_selectedFormat == 'xlsx') {
        filePath = p.join(dir.path, '$baseName.xlsx');
        await XlsxExporter.writeToFile(records, filePath);
      } else if (_selectedFormat == 'json') {
        filePath = p.join(dir.path, '$baseName.json');
        await JsonBackupExporter.writeToFile(
          profile: profile,
          records: records,
          filePath: filePath,
        );
      } else {
        // PDF
        filePath = p.join(dir.path, '$baseName.pdf');
        await PdfReportGenerator.writeToFile(
          profile: profile,
          records: records,
          medications: medications,
          filePath: filePath,
        );
      }

      AppLogger.instance.info('Export tamamlandı: $filePath');

      if (!mounted) return;
      _showSuccessDialog(filePath);
    } catch (e, stack) {
      AppLogger.instance.error('Export hatası', error: e, stack: stack);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${Tr.hata}: $e')));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _showSuccessDialog(String filePath) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(Tr.basarili),
        content: Text('${Tr.dosyaOlusturuldu}\n$filePath'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(Tr.tamam),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Share.shareXFiles([XFile(filePath)]);
            },
            child: const Text(Tr.paylas),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: const GlassAppBar(title: Tr.disaAktar),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 50, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassSectionHeader(title: Tr.formatSec, icon: Icons.file_copy),
            const SizedBox(height: 8),
            _FormatTile(
              title: Tr.csvFormat,
              subtitle: 'CSV dosyası',
              value: 'csv',
              groupValue: _selectedFormat,
              onChanged: (v) => setState(() => _selectedFormat = v!),
            ),
            _FormatTile(
              title: Tr.xlsxFormat,
              subtitle: 'Microsoft Excel dosyası',
              value: 'xlsx',
              groupValue: _selectedFormat,
              onChanged: (v) => setState(() => _selectedFormat = v!),
            ),
            _FormatTile(
              title: Tr.jsonBackup,
              subtitle: 'Checksum korumalı yedek (NASA)',
              value: 'json',
              groupValue: _selectedFormat,
              onChanged: (v) => setState(() => _selectedFormat = v!),
            ),
            _FormatTile(
              title: Tr.pdfRapor,
              subtitle: Tr.pdfSubtitle,
              value: 'pdf',
              groupValue: _selectedFormat,
              onChanged: (v) => setState(() => _selectedFormat = v!),
            ),
            const Spacer(),
            GlassButton(
              onPressed: _exporting ? null : _export,
              icon: _exporting ? null : Icons.file_download,
              label: _exporting ? Tr.yukle : Tr.disaAktar,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatTile extends StatelessWidget {
  const _FormatTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 8),
      blur: 8,
      child: RadioListTile<String>(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
