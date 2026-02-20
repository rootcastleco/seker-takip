import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/validators.dart';
import '../../core/formatting.dart';
import '../../core/services/notification_service.dart';
import '../../domain/entities/glucose_record.dart';
import '../../features/dashboard/logic/glucose_analyzer.dart';
import '../../features/scanner/presentation/scan_page.dart';
import '../state/providers.dart';
import '../widgets/glass_widgets.dart';

/// Yeni kayıt veya düzenleme sayfası.
class RecordEditPage extends ConsumerStatefulWidget {
  const RecordEditPage({super.key, this.recordId});
  final int? recordId;

  @override
  ConsumerState<RecordEditPage> createState() => _RecordEditPageState();
}

class _RecordEditPageState extends ConsumerState<RecordEditPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  final _ilacCtrl = TextEditingController();
  final _sabahAcCtrl = TextEditingController();
  final _sabahTokCtrl = TextEditingController();
  final _oglenAcCtrl = TextEditingController();
  final _oglenTokCtrl = TextEditingController();
  final _aksamAcCtrl = TextEditingController();
  final _aksamTokCtrl = TextEditingController();
  final _yatmadanCtrl = TextEditingController();
  final _gece03Ctrl = TextEditingController();
  final _notCtrl = TextEditingController();
  bool _initialized = false;
  GlucoseRecordEntity? _existing;

  String _selectedPeriod = Tr.sabahAc;
  late final Map<String, TextEditingController> _periodControllers;

  @override
  void initState() {
    super.initState();
    _periodControllers = {
      Tr.sabahAc: _sabahAcCtrl,
      Tr.sabahTok: _sabahTokCtrl,
      Tr.oglenAc: _oglenAcCtrl,
      Tr.oglenTok: _oglenTokCtrl,
      Tr.aksamAc: _aksamAcCtrl,
      Tr.aksamTok: _aksamTokCtrl,
      Tr.yatmadanOnce: _yatmadanCtrl,
      Tr.gece03: _gece03Ctrl,
    };
  }

  @override
  void dispose() {
    _ilacCtrl.dispose();
    _sabahAcCtrl.dispose();
    _sabahTokCtrl.dispose();
    _oglenAcCtrl.dispose();
    _oglenTokCtrl.dispose();
    _aksamAcCtrl.dispose();
    _aksamTokCtrl.dispose();
    _yatmadanCtrl.dispose();
    _gece03Ctrl.dispose();
    _notCtrl.dispose();
    super.dispose();
  }

  void _fillForm(GlucoseRecordEntity record) {
    _selectedDate = record.tarih;
    _ilacCtrl.text = record.ilacInsulinAdi ?? '';
    _sabahAcCtrl.text = record.sabahAc?.toString() ?? '';
    _sabahTokCtrl.text = record.sabahTok?.toString() ?? '';
    _oglenAcCtrl.text = record.oglenAc?.toString() ?? '';
    _oglenTokCtrl.text = record.oglenTok?.toString() ?? '';
    _aksamAcCtrl.text = record.aksamAc?.toString() ?? '';
    _aksamTokCtrl.text = record.aksamTok?.toString() ?? '';
    _yatmadanCtrl.text = record.yatmadanOnce?.toString() ?? '';
    _gece03Ctrl.text = record.gece03?.toString() ?? '';
    _notCtrl.text = record.notlar ?? '';
    _existing = record;
    _initialized = true;
  }
  
  void _clearForm() {
    _existing = null;
    _ilacCtrl.clear();
    _sabahAcCtrl.clear();
    _sabahTokCtrl.clear();
    _oglenAcCtrl.clear();
    _oglenTokCtrl.clear();
    _aksamAcCtrl.clear();
    _aksamTokCtrl.clear();
    _yatmadanCtrl.clear();
    _gece03Ctrl.clear();
    _notCtrl.clear();
  }

  int? _parseInt(String text) {
    if (text.trim().isEmpty) return null;
    return int.tryParse(text.trim());
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _initialized = false;
        _clearForm();
      });
    }
  }

  /// Kamera tarayıcıyı aç ve sonucu ilgili alana yaz.
  Future<void> _scanForField(TextEditingController ctrl) async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => const ScanPage()),
    );
    if (result != null && mounted) {
      setState(() {
        ctrl.text = result.toString();
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Gelecek tarih kontrolü
    if (isFutureDate(_selectedDate)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Tr.gelecekTarih)));
      return;
    }

    // En az bir ölçüm kontrolü
    final measurements = [
      _parseInt(_sabahAcCtrl.text),
      _parseInt(_sabahTokCtrl.text),
      _parseInt(_oglenAcCtrl.text),
      _parseInt(_oglenTokCtrl.text),
      _parseInt(_aksamAcCtrl.text),
      _parseInt(_aksamTokCtrl.text),
      _parseInt(_yatmadanCtrl.text),
      _parseInt(_gece03Ctrl.text),
    ];
    if (!hasAtLeastOneMeasurement(measurements)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Tr.enAzBirOlcum)));
      return;
    }

    final now = DateTime.now();
    final record = GlucoseRecordEntity(
      id: _existing?.id,
      tarih: _selectedDate,
      ilacInsulinAdi: _ilacCtrl.text.trim().isEmpty
          ? null
          : _ilacCtrl.text.trim(),
      sabahAc: _parseInt(_sabahAcCtrl.text),
      sabahTok: _parseInt(_sabahTokCtrl.text),
      oglenAc: _parseInt(_oglenAcCtrl.text),
      oglenTok: _parseInt(_oglenTokCtrl.text),
      aksamAc: _parseInt(_aksamAcCtrl.text),
      aksamTok: _parseInt(_aksamTokCtrl.text),
      yatmadanOnce: _parseInt(_yatmadanCtrl.text),
      gece03: _parseInt(_gece03Ctrl.text),
      notlar: _notCtrl.text.trim().isEmpty ? null : _notCtrl.text.trim(),
      createdAt: _existing?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (_existing != null) {
        await ref.read(glucoseRecordsProvider.notifier).updateRecord(record);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text(Tr.kayitGuncellendi)));
        }
      } else {
        await ref.read(glucoseRecordsProvider.notifier).save(record);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text(Tr.kayitKaydedildi)));
        }
      }

      // Açlık kaydı varsa tokluk hatırlatıcısı öner
      if (mounted && _hasFastingValue()) {
        await _offerToklukReminder();
      }

      // ─── Sesli Geri Bildirim (GlucoseAnalyzer) ──────────
      try {
        await GlucoseAnalyzer.instance.analyzeAndSpeak(record);
      } catch (_) {
        // TTS hatası kullanıcıyı engellemez
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text(Tr.sesCihazSessiz)));
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${Tr.hata}: $e')));
      }
    }
  }

  /// Açlık alanlarından herhangi biri doluysa true döner.
  bool _hasFastingValue() {
    return _parseInt(_sabahAcCtrl.text) != null ||
        _parseInt(_oglenAcCtrl.text) != null ||
        _parseInt(_aksamAcCtrl.text) != null;
  }

  /// Tokluk hatırlatıcısı öner.
  Future<void> _offerToklukReminder() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(Tr.uyari),
        content: const Text(Tr.toklukHatirlatSorusu),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(Tr.hayir),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(Tr.evet),
          ),
        ],
      ),
    );
    if (accepted == true) {
      final granted = await NotificationService.instance.requestPermission();
      if (granted) {
        await NotificationService.instance.scheduleToklukReminder();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text(Tr.bildirimIzniYok)));
        }
      }
    }
  }

  Future<void> _delete() async {
    if (_existing == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(Tr.uyari),
        content: const Text(Tr.silOnay),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(Tr.iptal),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(Tr.sil),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref.read(glucoseRecordsProvider.notifier).delete(_existing!.id!);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text(Tr.kayitSilindi)));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${Tr.hata}: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(glucoseRecordsProvider);

    // Düzenleme veya gün seçimi modundaysa mevcut kaydı bul
    if (!_initialized) {
      recordsAsync.whenData((records) {
        if (widget.recordId != null) {
          final found = records.where((r) => r.id == widget.recordId);
          if (found.isNotEmpty) _fillForm(found.first);
        } else {
          // Check if there is already a record for the selected date
          final todayRecords = records.where((r) {
            final local = r.tarih.toLocal();
            return local.year == _selectedDate.year &&
                local.month == _selectedDate.month &&
                local.day == _selectedDate.day;
          });
          if (todayRecords.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _fillForm(todayRecords.first));
            });
          } else {
            _initialized = true;
          }
        }
      });
    }

    final isEdit = widget.recordId != null;

    return GlassScaffold(
      appBar: GlassAppBar(
        title: isEdit ? 'Kayıt Düzenle' : Tr.yeniKayitEkle,
        actions: isEdit
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: Tr.sil,
                  onPressed: _delete,
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 50, 16, 24),
        child: GlassCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tarih seçici
                GlassCard(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.zero,
                  blur: 6,
                  child: ListTile(
                    leading: Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? RC.accent
                          : RC.blue,
                    ),
                    title: Text('${Tr.tarih}: ${formatDate(_selectedDate)}'),
                    trailing: const Icon(Icons.edit_calendar),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: _pickDate,
                  ),
                ),
                // İlaç / İnsülin adı
                TextFormField(
                  controller: _ilacCtrl,
                  decoration: glassInputDecoration(
                    context: context,
                    label: Tr.ilacInsulinAdi,
                    hint: 'Opsiyonel',
                  ),
                ),
                const SizedBox(height: 16),
                // Ölçüm Zamanı Seçimi
                DropdownButtonFormField<String>(
                  value: _selectedPeriod,
                  decoration: glassInputDecoration(
                    context: context,
                    label: 'Ölçüm Zamanı',
                  ),
                  dropdownColor: Theme.of(context).brightness == Brightness.dark
                      ? RC.bgDark2
                      : Colors.white,
                  items: _periodControllers.keys.map((period) {
                    // Check if value exists to show an indicator
                    final hasValue = _periodControllers[period]!.text.isNotEmpty;
                    return DropdownMenuItem(
                      value: period,
                      child: Text(
                        hasValue ? '$period (Dolu)' : period,
                        style: TextStyle(
                          color: hasValue ? RC.accentGreen : null,
                          fontWeight: hasValue ? FontWeight.bold : null,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedPeriod = val);
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Tek Ölçüm Alanı
                _GlucoseField(
                  controller: _periodControllers[_selectedPeriod]!,
                  label: _selectedPeriod,
                  onScan: () => _scanForField(_periodControllers[_selectedPeriod]!),
                ),
                const SizedBox(height: 12),
                // Not
                TextFormField(
                  controller: _notCtrl,
                  decoration: glassInputDecoration(
                    context: context,
                    label: Tr.notlar,
                    hint: 'Opsiyonel',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                GlassButton(
                  onPressed: _save,
                  icon: Icons.save,
                  label: isEdit ? Tr.guncelle : Tr.kaydet,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlucoseField extends StatelessWidget {
  const _GlucoseField({
    required this.controller,
    required this.label,
    this.onScan,
  });
  final TextEditingController controller;
  final String label;
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: glassInputDecoration(
          context: context,
          label: label,
          suffixText: Tr.mgDl,
          suffixIcon: IconButton(
            icon: Icon(
              Icons.camera_alt_outlined,
              size: 20,
              color: Theme.of(context).brightness == Brightness.dark
                  ? RC.accent
                  : RC.blue,
            ),
            tooltip: Tr.kamerayiTara,
            onPressed: onScan,
          ),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
        validator: validateGlucose,
      ),
    );
  }
}
