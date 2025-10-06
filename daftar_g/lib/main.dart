import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'providers/app_providers.dart';
import 'screens/home/home_screen.dart';
import 'constants/app_theme.dart';
import 'models/app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تعيين اتجاه الشاشة
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  runApp(
    const ProviderScope(
      child: DaftarGApp(),
    ),
  );
}

class DaftarGApp extends ConsumerWidget {
  const DaftarGApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return MaterialApp(
      title: 'دفترچي',
      debugShowCheckedModeBanner: false,
      
      // إعدادات اللغة والاتجاه
      locale: const Locale('ar', 'SA'),
      
      // إعدادات الثيم
      theme: AppTheme.lightTheme(settings.primaryColor),
      darkTheme: AppTheme.darkTheme(settings.primaryColor),
      themeMode: _getThemeMode(settings.themeMode),
      
      // الشاشة الرئيسية
      home: const HomeScreen(),
      
      // إعدادات التنقل
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
  
  ThemeMode _getThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return ThemeMode.light as ThemeMode;
      case ThemeMode.dark:
        return ThemeMode.dark as ThemeMode;
      case ThemeMode.system:
        return ThemeMode.system as ThemeMode;
    }
  }
}
