import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';
import '../../providers/admin_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _waCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  final _storeCtrl = TextEditingController();
  bool _holiday = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (settings) {
          if (_waCtrl.text.isEmpty) {
            _waCtrl.text = settings['storeInfo']?['whatsapp'] ?? '';
            _storeCtrl.text = settings['storeInfo']?['name'] ?? 'Third Step Fish Trading';
            _feeCtrl.text = settings['delivery']?['fee']?.toString() ?? '15';
            _holiday = settings['holiday'] ?? false;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Section('Store Info', [
                TextFormField(controller: _storeCtrl, decoration: const InputDecoration(labelText: 'Store Name')),
                const SizedBox(height: 10),
                TextFormField(controller: _waCtrl, decoration: const InputDecoration(labelText: 'WhatsApp Number', prefixText: '+'), keyboardType: TextInputType.phone),
              ]),
              const SizedBox(height: 16),

              _Section('Delivery', [
                TextFormField(controller: _feeCtrl, decoration: const InputDecoration(labelText: 'Delivery Fee (AED)', prefixText: 'AED '), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              ]),
              const SizedBox(height: 16),

              _Section('Operations', [
                SwitchListTile(
                  value: _holiday,
                  onChanged: (v) => setState(() => _holiday = v),
                  title: const Text('Holiday / Closed', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Disables ordering on customer app'),
                  activeColor: AppColors.error,
                  dense: true,
                ),
              ]),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                  child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Settings', style: TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(height: 20),

              // Admin info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Signed in as', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(FirebaseAuth.instance.currentUser?.email ?? 'Demo Mode',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.navy)),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(firestoreServiceProvider).updateSettings({
        'storeInfo': {'name': _storeCtrl.text.trim(), 'whatsapp': _waCtrl.text.trim()},
        'delivery': {'fee': double.tryParse(_feeCtrl.text) ?? 15},
        'holiday': _holiday,
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.3)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ]);
}
