import 'package:flutter/material.dart';
import 'package:idle_universe/core/widgets/widgets.dart';

/// Settings Screen - Màn hình cài đặt
/// 
/// Các tùy chọn:
/// - Audio settings (music, SFX)
/// - Notifications
/// - Save/Load
/// - Reset game
/// - About/Credits
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  bool _notificationsEnabled = true;
  bool _offlineProgress = true;

  @override
  Widget build(BuildContext context) {
    return SimpleGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(
          title: 'Settings',
          subtitle: '⚙️ Preferences',
        ),
        body: ListView(
          children: [
          // Audio Section
          _buildSection(
            context,
            title: 'Audio',
            icon: Icons.volume_up,
            children: [
              SwitchListTile(
                title: const Text('Music'),
                subtitle: const Text('Background music'),
                value: _musicEnabled,
                onChanged: (value) {
                  setState(() => _musicEnabled = value);
                },
                secondary: const Icon(Icons.music_note),
              ),
              SwitchListTile(
                title: const Text('Sound Effects'),
                subtitle: const Text('Button clicks and notifications'),
                value: _sfxEnabled,
                onChanged: (value) {
                  setState(() => _sfxEnabled = value);
                },
                secondary: const Icon(Icons.volume_down),
              ),
            ],
          ),

          // Gameplay Section
          _buildSection(
            context,
            title: 'Gameplay',
            icon: Icons.videogame_asset,
            children: [
              SwitchListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Alerts for important events'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
                secondary: const Icon(Icons.notifications),
              ),
              SwitchListTile(
                title: const Text('Offline Progress'),
                subtitle: const Text('Earn resources while away'),
                value: _offlineProgress,
                onChanged: (value) {
                  setState(() => _offlineProgress = value);
                },
                secondary: const Icon(Icons.timelapse),
              ),
            ],
          ),

          // Data Section
          _buildSection(
            context,
            title: 'Data',
            icon: Icons.storage,
            children: [
              ListTile(
                leading: const Icon(Icons.save),
                title: const Text('Export Save'),
                subtitle: const Text('Backup your progress'),
                onTap: () {
                  _showComingSoon(context, 'Export Save');
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload),
                title: const Text('Import Save'),
                subtitle: const Text('Restore from backup'),
                onTap: () {
                  _showComingSoon(context, 'Import Save');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Reset Game', style: TextStyle(color: Colors.red)),
                subtitle: const Text('Delete all progress'),
                onTap: () {
                  _showResetConfirmation(context);
                },
              ),
            ],
          ),

          // About Section
          _buildSection(
            context,
            title: 'About',
            icon: Icons.info,
            children: [
              ListTile(
                leading: const Icon(Icons.article),
                title: const Text('Changelog'),
                subtitle: const Text('Version history'),
                onTap: () {
                  _showComingSoon(context, 'Changelog');
                },
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Credits'),
                subtitle: const Text('Made with Flutter & Riverpod'),
                onTap: () {
                  _showComingSoon(context, 'Credits');
                },
              ),
              const ListTile(
                leading: Icon(Icons.star),
                title: Text('Version'),
                subtitle: Text('0.1.0 (Alpha)'),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade300,
                    ),
              ),
            ],
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Game?'),
        content: const Text(
          'This will delete ALL your progress.\n\n'
          'This action cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon(context, 'Reset Game');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE ALL'),
          ),
        ],
      ),
    );
  }
}
