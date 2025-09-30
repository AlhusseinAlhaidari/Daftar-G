import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const DaftarGApp());
}

class DaftarGApp extends StatelessWidget {
  const DaftarGApp({super.key});

  @override
  Widget build(BuildContext context) {
    // تعيين اتجاه النص للعربية
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: MaterialApp(
        title: 'دفترچي',
        debugShowCheckedModeBanner: false,
        
        // إعدادات اللغة والاتجاه
        locale: const Locale('ar', 'SA'),
        
        // إعدادات الثيم
        theme: ThemeData(
          primarySwatch: Colors.teal,
          primaryColor: Colors.teal,
          fontFamily: 'Arial', // يمكن تغييرها لخط عربي أفضل
          
          // إعدادات الألوان
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.light,
          ),
          
          // إعدادات AppBar
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          
          // إعدادات الكروت
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          
          // إعدادات الأزرار
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          
          // إعدادات حقول النص
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          
          // إعدادات الخط
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            headlineMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            headlineSmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            titleMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
            ),
          ),
          
          useMaterial3: true,
        ),
        
        // الشاشة الرئيسية
        home: const HomeScreen(),
        
        // إعدادات التنقل
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl, // اتجاه النص من اليمين لليسار
            child: child!,
          );
        },
      ),
    );
  }
}
