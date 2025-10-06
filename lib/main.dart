import 'package:daftar_g/models/customer.dart';
import 'package:flutter/material.dart';
import 'package:daftar_g/models/app_settings.dart' as AppSettingsModel;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'constants/app_theme.dart';
import 'providers/app_providers.dart';
import 'screens/home/home_screen.dart';
import 'screens/customer/add_customer_screen.dart';
import 'screens/customer/customer_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'ar';
  runApp(const ProviderScope(child: DaftarGApp()));
}

class DaftarGApp extends ConsumerWidget {
  const DaftarGApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'دفترچي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(settings.primaryColor),
      darkTheme: AppTheme.darkTheme(settings.primaryColor),
      themeMode: settings.themeMode == AppSettingsModel.AppThemeMode.dark
          ? ThemeMode.dark
          : (settings.themeMode == AppSettingsModel.AppThemeMode.light
              ? ThemeMode.light
              : ThemeMode.system),
      locale: const Locale('ar'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
      ],
      home: const HomeScreen(),
      routes: {
        '/add_customer': (context) => const AddCustomerScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      onGenerateRoute: (routeSettings) {
        if (routeSettings.name == '/customer_details') {
          final customer = routeSettings.arguments as Customer;
          return MaterialPageRoute(
            builder: (context) => CustomerScreen(customer: customer),
          );
        }
        return null;
      },
    );
  }
}

