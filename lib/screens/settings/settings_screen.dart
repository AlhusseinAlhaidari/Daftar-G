import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../constants/app_constants.dart';
import '../../models/app_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        children: [
          // المظهر
          _buildSectionHeader(context, 'المظهر'),
          _buildThemeModeSelector(context, ref, settings),
          _buildColorSelector(context, ref, settings),
          
          const Divider(),
          
          // العملة
          _buildSectionHeader(context, 'العملة'),
          _buildCurrencySelector(context, ref, settings),
          
          const Divider(),
          
          // معلومات التطبيق
          _buildSectionHeader(context, 'حول التطبيق'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('الإصدار'),
            subtitle: const Text('2.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('المطور'),
            subtitle: const Text('الحسين الحيدري'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildThemeModeSelector(BuildContext context, WidgetRef ref, AppSettings settings) {
    return ListTile(
      leading: const Icon(Icons.brightness_6),
      title: const Text('الوضع'),
      subtitle: Text(_getThemeModeText(settings.themeMode)),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('اختر الوضع'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('فاتح'),
                  value: ThemeMode.light,
                  groupValue: settings.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(settingsProvider.notifier).updateThemeMode(value);
                      Navigator.pop(context);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('داكن'),
                  value: ThemeMode.dark,
                  groupValue: settings.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(settingsProvider.notifier).updateThemeMode(value);
                      Navigator.pop(context);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('تلقائي'),
                  value: ThemeMode.system,
                  groupValue: settings.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(settingsProvider.notifier).updateThemeMode(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorSelector(BuildContext context, WidgetRef ref, AppSettings settings) {
    return ListTile(
      leading: Icon(Icons.palette, color: settings.primaryColor),
      title: const Text('اللون الأساسي'),
      subtitle: const Text('اختر لون التطبيق'),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('اختر اللون'),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: AppConstants.availableColors.length,
                itemBuilder: (context, index) {
                  final color = AppConstants.availableColors[index];
                  final isSelected = color.value == settings.primaryColor.value;
                  
                  return InkWell(
                    onTap: () {
                      ref.read(settingsProvider.notifier).updatePrimaryColor(color);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrencySelector(BuildContext context, WidgetRef ref, AppSettings settings) {
    return ListTile(
      leading: const Icon(Icons.attach_money),
      title: const Text('العملة'),
      subtitle: Text(settings.currency),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('اختر العملة'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: AppConstants.availableCurrencies.length,
                itemBuilder: (context, index) {
                  final currency = AppConstants.availableCurrencies[index];
                  final symbol = currency['symbol']!;
                  final name = currency['name']!;
                  
                  return RadioListTile<String>(
                    title: Text('$name ($symbol)'),
                    value: symbol,
                    groupValue: settings.currency,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(settingsProvider.notifier).updateCurrency(value);
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'فاتح';
      case ThemeMode.dark:
        return 'داكن';
      case ThemeMode.system:
        return 'تلقائي';
    }
  }
}
