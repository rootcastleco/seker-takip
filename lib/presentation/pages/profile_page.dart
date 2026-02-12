import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/validators.dart';
import '../../domain/entities/profile.dart';
import '../state/providers.dart';
import '../widgets/rootcastle_app_bar.dart';

/// Kişisel Bilgiler (Profil) sayfası.
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _isimCtrl;
  late TextEditingController _yasCtrl;
  late TextEditingController _kiloCtrl;
  late TextEditingController _doktorCtrl;
  late TextEditingController _hemsireCtrl;
  late TextEditingController _telefonCtrl;
  late TextEditingController _adresCtrl;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _isimCtrl = TextEditingController();
    _yasCtrl = TextEditingController();
    _kiloCtrl = TextEditingController();
    _doktorCtrl = TextEditingController();
    _hemsireCtrl = TextEditingController();
    _telefonCtrl = TextEditingController();
    _adresCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _isimCtrl.dispose();
    _yasCtrl.dispose();
    _kiloCtrl.dispose();
    _doktorCtrl.dispose();
    _hemsireCtrl.dispose();
    _telefonCtrl.dispose();
    _adresCtrl.dispose();
    super.dispose();
  }

  void _fillForm(ProfileEntity profile) {
    if (!_initialized) {
      _isimCtrl.text = profile.isimSoyisim;
      _yasCtrl.text = profile.yas > 0 ? profile.yas.toString() : '';
      _kiloCtrl.text = profile.kilo > 0 ? profile.kilo.toString() : '';
      _doktorCtrl.text = profile.doktor;
      _hemsireCtrl.text = profile.diyabetEgitimHemsiresi;
      _telefonCtrl.text = profile.cepTelefonu;
      _adresCtrl.text = profile.adres;
      _initialized = true;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final existing = ref.read(profileProvider).valueOrNull;
    final profile = ProfileEntity(
      id: 1,
      isimSoyisim: _isimCtrl.text.trim(),
      yas: int.tryParse(_yasCtrl.text.trim()) ?? 0,
      kilo: double.tryParse(_kiloCtrl.text.trim()) ?? 0.0,
      doktor: _doktorCtrl.text.trim(),
      diyabetEgitimHemsiresi: _hemsireCtrl.text.trim(),
      cepTelefonu: _telefonCtrl.text.trim(),
      adres: _adresCtrl.text.trim(),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      await ref.read(profileProvider.notifier).save(profile);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(Tr.profilKaydedildi)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${Tr.hata}: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: const RootcastleAppBar(title: Tr.kisiselBilgiler),
      body: profileAsync.when(
        data: (profile) {
          _fillForm(profile);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _isimCtrl,
                    decoration: const InputDecoration(
                      labelText: Tr.isimSoyisim,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _yasCtrl,
                    decoration: const InputDecoration(labelText: Tr.yas),
                    keyboardType: TextInputType.number,
                    validator: validateAge,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _kiloCtrl,
                    decoration: const InputDecoration(labelText: Tr.kilo),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: validateWeight,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _doktorCtrl,
                    decoration: const InputDecoration(labelText: Tr.doktor),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _hemsireCtrl,
                    decoration: const InputDecoration(
                      labelText: Tr.diyabetEgitimHemsiresi,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _telefonCtrl,
                    decoration: const InputDecoration(
                      labelText: Tr.cepTelefonu,
                    ),
                    keyboardType: TextInputType.phone,
                    validator: validatePhone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _adresCtrl,
                    decoration: const InputDecoration(labelText: Tr.adres),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: const Text(Tr.kaydet),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${Tr.hata}: $e')),
      ),
    );
  }
}
