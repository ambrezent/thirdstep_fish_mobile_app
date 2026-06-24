import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isArabic = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Brand card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(children: [
              Text('🐟', style: TextStyle(fontSize: 48)),
              SizedBox(height: 8),
              Text('Third Step Fish Trading', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              Text('Fresh Catch UAE', style: TextStyle(color: AppColors.goldLight, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 20),

          _SettingsSection('Preferences', [
            _SettingsTile(
              icon: Icons.language,
              title: 'Language',
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_isArabic ? 'العربية' : 'English', style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(width: 8),
                Switch(value: _isArabic, onChanged: (v) => setState(() => _isArabic = v), activeColor: AppColors.navy),
              ]),
              onTap: null,
            ),
          ]),

          const SizedBox(height: 12),
          _SettingsSection('Contact & Support', [
            _SettingsTile(
              icon: Icons.chat_outlined,
              title: 'WhatsApp Support',
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => launchUrl(Uri.parse('https://wa.me/971XXXXXXXXX')),
            ),
            _SettingsTile(
              icon: Icons.location_on_outlined,
              title: 'Our Location',
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => launchUrl(Uri.parse('https://maps.google.com')),
            ),
          ]),

          const SizedBox(height: 12),
          _SettingsSection('About', [
            _SettingsTile(icon: Icons.info_outline, title: 'App Version', trailing: const Text('1.0.0', style: TextStyle(color: AppColors.textSecondary)), onTap: null),
          ]),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection(this.title, this.children);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5)),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Column(children: children),
          ),
        ],
      );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, required this.title, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: AppColors.navy, size: 20),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: trailing,
        onTap: onTap,
        dense: true,
      );
}
