import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/constants.dart';
import '../../core/formatting.dart';
import '../../core/logger/logger.dart';
import '../../data/export_import/json_backup_importer.dart';
import '../state/providers.dart';
import '../widgets/glass_widgets.dart';

/// İçe aktarma sayfası.
class ImportPage extends ConsumerStatefulWidget {
  const ImportPage({super.key});

  @override
  ConsumerState<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends ConsumerState<ImportPage> {
  ImportResult? _importResult;
  String _importMode = 'merge';
  bool _importing = false;
  String? _errorMessage;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.single.path == null) return;

      final path = result.files.single.path!;
      final importResult = await JsonBackupImporter.parseFile(path);

      setState(() {
        _importResult = importResult;
        _errorMessage = null;
      });
    } on ImportException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _importResult = null;
      });
    } catch (e, stack) {
      AppLogger.instance.error(
        'Import dosya okuma hatası',
        error: e,
        stack: stack,
      );
      setState(() {
        _errorMessage = '${Tr.importHata}\n$e';
        _importResult = null;
      });
    }
  }

  Future<void> _executeImport() async {
    if (_importResult == null) return;
    setState(() => _importing = true);

    try {
      final glucoseRepo = ref.read(glucoseRepositoryProvider);
      final profileRepo = ref.read(profileRepositoryProvider);

      if (_importMode == 'replace') {
        // Üzerine yaz: tüm mevcut kayıtları sil
        await glucoseRepo.deleteAll();
      }

      // Profil import
      if (_importResult!.profile != null) {
        await profileRepo.saveProfile(_importResult!.profile!);
        ref.invalidate(profileProvider);
      }

      // Kayıtları ekle
      for (final record in _importResult!.records) {
        // ID'leri yeniden oluştur (autoincrement)
        final withoutId = record.copyWith(id: null);
        await glucoseRepo.save(withoutId);
      }

      // State'i güncelle
      await ref.read(glucoseRecordsProvider.notifier).refresh();

      AppLogger.instance.info(
        'Import tamamlandı: ${_importResult!.records.length} kayıt, mod=$_importMode',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${Tr.importBasarili} (${_importResult!.records.length} kayıt)',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e, stack) {
      AppLogger.instance.error('Import hatası', error: e, stack: stack);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${Tr.importHata}\n$e')));
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: const GlassAppBar(title: Tr.iceAktar),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 50, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassButton(
              onPressed: _pickFile,
              icon: Icons.folder_open,
              label: Tr.dosyaSec,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              GlassCard(
                borderColor: Colors.red.withOpacity(0.4),
                backgroundColor: Colors.red.withOpacity(0.1),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
            if (_importResult != null) ...[
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassSectionHeader(
                      title: Tr.importOzet,
                      icon: Icons.summarize,
                    ),
                    const SizedBox(height: 8),
                    Text('${Tr.kayitSayisi}: ${_importResult!.recordCount}'),
                    Text(
                      '${Tr.exportTarihi}: ${formatDateTime(_importResult!.exportedAt.toLocal())}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassSectionHeader(title: Tr.importMod, icon: Icons.swap_horiz),
              GlassCard(
                padding: EdgeInsets.zero,
                child: RadioListTile<String>(
                  title: const Text(Tr.birlestir),
                  subtitle: const Text('Mevcut kayıtlara ekler'),
                  value: 'merge',
                  groupValue: _importMode,
                  onChanged: (v) => setState(() => _importMode = v!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              GlassCard(
                padding: EdgeInsets.zero,
                child: RadioListTile<String>(
                  title: const Text(Tr.ustYaz),
                  subtitle: const Text('Mevcut kayıtları siler'),
                  value: 'replace',
                  groupValue: _importMode,
                  onChanged: (v) => setState(() => _importMode = v!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const Spacer(),
              GlassButton(
                onPressed: _importing ? null : _executeImport,
                icon: _importing ? null : Icons.file_upload,
                label: _importing ? Tr.yukle : Tr.iceAktar,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
