import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_weather_hub/presentations/providers/settings_provider.dart';
import 'package:news_weather_hub/presentations/providers/weather_provider.dart';
import 'package:news_weather_hub/presentations/screens/dashboard/widgets/city_search_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDarkMode = settings.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Theme Section
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark theme'),
            value: isDarkMode,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
            },
            secondary: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: isDarkMode ? Colors.amber : Colors.blue,
            ),
          ),

          const Divider(),

          // Weather Settings
          _buildSectionHeader('Weather Settings'),
          ListTile(
            leading: const Icon(Icons.location_city),
            title: const Text('Default City'),
            subtitle: Text(settings.defaultCity),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _changeDefaultCity(),
          ),

          const Divider(),

          // About Section
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: Text('$_appVersion ($_buildNumber)'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Developer'),
            subtitle: const Text('News & Weather Hub'),
          ),

          const Divider(),

          // Credits
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Powered by',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Open-Meteo Weather API\n• NewsAPI.org',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _changeDefaultCity() {
    showDialog(
      context: context,
      builder: (context) => const CitySearchDialog(),
    ).then((_) {
      // After city selection, update default city
      final weatherState = ref.read(weatherProvider);
      if (weatherState.data != null) {
        // We would need to get the city name from coordinates
        // For simplicity, we'll use a placeholder
        ref.read(settingsProvider.notifier).setDefaultCity('Selected City');
      }
    });
  }
}