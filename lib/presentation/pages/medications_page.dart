import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/voice_service.dart';
import '../../domain/entities/medication.dart';
import '../state/providers.dart';
import '../widgets/glass_widgets.dart';

/// İlaç yönetim sayfası — İlaç ekle / düzenle / sil + hatırlatıcı.
class MedicationsPage extends ConsumerStatefulWidget {
  const MedicationsPage({super.key});

  @override
  ConsumerState<MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends ConsumerState<MedicationsPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final medsAsync = ref.watch(medicationsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // ─── Başlık ───────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Tr.ilacListesi,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : RC.black,
                  letterSpacing: 0.5,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline,
                  color: RC.accentGreen,
                  size: 32,
                ),
                onPressed: () => _showMedicationDialog(context),
              ),
            ],
          ),
        ),

        // ─── İlaç Listesi ─────────────────────────────
        medsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => GlassCard(
            child: Text('Hata: $e', style: TextStyle(color: Colors.red)),
          ),
          data: (meds) {
            if (meds.isEmpty) {
              return _buildEmptyState(isDark);
            }
            // Saate göre sırala (aktifler önce, sonra saate göre)
            final sorted = List<MedicationEntity>.from(meds);
            sorted.sort((a, b) {
              // Aktifler önce
              if (a.aktif != b.aktif) return a.aktif ? -1 : 1;
              // Saate göre sırala
              final aTime = a.saatHour * 60 + a.saatMinute;
              final bTime = b.saatHour * 60 + b.saatMinute;
              return aTime.compareTo(bTime);
            });
            return Column(
              children: [
                // Aktif ilaç sayısı
                GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _miniStat(
                        '${sorted.where((m) => m.aktif).length}',
                        'Aktif İlaç',
                        RC.accentGreen,
                        isDark,
                      ),
                      _miniStat('${sorted.length}', 'Toplam', RC.blue, isDark),
                      _miniStat(
                        _nextMedTime(sorted),
                        'Sıradaki',
                        RC.accent,
                        isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ...sorted.map((med) => _buildMedCard(med, isDark)),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.medication_outlined,
            size: 64,
            color: isDark ? Colors.white38 : Colors.black26,
          ),
          const SizedBox(height: 12),
          Text(
            Tr.ilacYok,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlaçlarını ekle, saatinde hatırlatalım.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showMedicationDialog(context),
            icon: const Icon(Icons.add),
            label: Text(Tr.ilacEkle),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String value, String label, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
      ],
    );
  }

  String _nextMedTime(List<MedicationEntity> meds) {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    for (final m in meds) {
      if (!m.aktif || m.hatirlatmaSaati.isEmpty) continue;
      final mMinutes = m.saatHour * 60 + m.saatMinute;
      if (mMinutes > nowMinutes) return m.hatirlatmaSaati;
    }
    // Yarına döner
    for (final m in meds) {
      if (!m.aktif || m.hatirlatmaSaati.isEmpty) continue;
      return m.hatirlatmaSaati;
    }
    return '-';
  }

  Widget _buildMedCard(MedicationEntity med, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderColor: med.aktif ? RC.accentGreen.withValues(alpha: 0.3) : null,
      child: Row(
        children: [
          // İkon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: med.aktif
                  ? RC.accentGreen.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.medication,
              color: med.aktif ? RC.accentGreen : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // İlaç bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.ilacAdi,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : RC.black,
                  ),
                ),
                if (med.doz.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${Tr.ilacDozu}: ${med.doz}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
                if (med.hatirlatmaSaati.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.alarm,
                        size: 14,
                        color: med.aktif ? RC.accent : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        med.hatirlatmaSaati,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: med.aktif ? RC.accent : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Toggle + More
          Switch(
            value: med.aktif,
            activeColor: RC.accentGreen,
            onChanged: (val) => _toggleAktif(med, val),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
            onSelected: (action) {
              if (action == 'edit') {
                _showMedicationDialog(context, existing: med);
              } else if (action == 'delete') {
                _confirmDelete(med);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Düzenle'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text('Sil', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAktif(MedicationEntity med, bool aktif) async {
    final updated = med.copyWith(aktif: aktif, updatedAt: DateTime.now());
    await ref.read(medicationsProvider.notifier).updateMedication(updated);

    if (aktif && med.hatirlatmaSaati.isNotEmpty) {
      await NotificationService.instance.scheduleIlacReminder(
        id: med.id!,
        ilacAdi: med.ilacAdi,
        hour: med.saatHour,
        minute: med.saatMinute,
      );
    } else {
      await NotificationService.instance.cancelIlacReminder(med.id!);
    }
  }

  Future<void> _confirmDelete(MedicationEntity med) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(Tr.uyari),
        content: Text('"${med.ilacAdi}" ilacını silmek istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(Tr.iptal),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(Tr.sil, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(medicationsProvider.notifier).delete(med.id!);
      await NotificationService.instance.cancelIlacReminder(med.id!);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(Tr.ilacSilindi)));
      }
    }
  }

  Future<void> _showMedicationDialog(
    BuildContext context, {
    MedicationEntity? existing,
  }) async {
    final isEdit = existing != null;
    final ilacAdiCtrl = TextEditingController(text: existing?.ilacAdi ?? '');
    final dozCtrl = TextEditingController(text: existing?.doz ?? '');
    final notCtrl = TextEditingController(text: existing?.notlar ?? '');

    TimeOfDay selectedTime = TimeOfDay(
      hour: existing?.saatHour ?? 8,
      minute: existing?.saatMinute ?? 0,
    );

    bool hatirlaticiAktif = existing?.hatirlatmaSaati.isNotEmpty ?? true;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'İlaç Düzenle' : Tr.ilacEkle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: ilacAdiCtrl,
                      decoration: InputDecoration(
                        labelText: Tr.ilacAdi,
                        prefixIcon: const Icon(Icons.medication),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dozCtrl,
                      decoration: InputDecoration(
                        labelText: Tr.ilacDozu,
                        hintText: 'ör: 500mg, 1 tablet',
                        prefixIcon: const Icon(Icons.science),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notCtrl,
                      decoration: InputDecoration(
                        labelText: Tr.notlar,
                        prefixIcon: const Icon(Icons.note),
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Hatırlatıcı
                    SwitchListTile(
                      title: Text(Tr.ilacHatirlatici),
                      subtitle: Text(
                        hatirlaticiAktif
                            ? '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'
                            : 'Kapalı',
                      ),
                      value: hatirlaticiAktif,
                      onChanged: (val) =>
                          setDialogState(() => hatirlaticiAktif = val),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (hatirlaticiAktif)
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(
                          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(Tr.ilacSaati),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            setDialogState(() => selectedTime = picked);
                          }
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(Tr.iptal),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = ilacAdiCtrl.text.trim();
                    if (name.isEmpty) return;

                    final timeStr = hatirlaticiAktif
                        ? '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'
                        : '';

                    final now = DateTime.now();
                    final entity = MedicationEntity(
                      id: existing?.id,
                      ilacAdi: name,
                      doz: dozCtrl.text.trim(),
                      hatirlatmaSaati: timeStr,
                      aktif: true,
                      notlar: notCtrl.text.trim().isNotEmpty
                          ? notCtrl.text.trim()
                          : null,
                      createdAt: existing?.createdAt ?? now,
                      updatedAt: now,
                    );

                    if (isEdit) {
                      await ref
                          .read(medicationsProvider.notifier)
                          .updateMedication(entity);
                    } else {
                      await ref.read(medicationsProvider.notifier).save(entity);
                    }

                    // Hatırlatıcı kur
                    if (hatirlaticiAktif && entity.id != null) {
                      await NotificationService.instance.scheduleIlacReminder(
                        id: entity.id!,
                        ilacAdi: name,
                        hour: selectedTime.hour,
                        minute: selectedTime.minute,
                      );
                    }

                    // Sesli geri bildirim
                    SystemVoiceService.instance.speak(Tr.ilacKaydedildi);

                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(Tr.ilacKaydedildi)),
                      );
                    }
                  },
                  child: Text(isEdit ? Tr.guncelle : Tr.kaydet),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
