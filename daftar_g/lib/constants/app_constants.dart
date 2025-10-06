import 'package:flutter/material.dart';

class AppConstants {
  // ألوان افتراضية
  static const List<Color> availableColors = [
    Colors.teal,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.cyan,
  ];

  // فئات المصروفات
  static const List<String> expenseCategories = [
    'إيجار',
    'رواتب',
    'كهرباء وماء',
    'صيانة',
    'مواد خام',
    'نقل ومواصلات',
    'تسويق وإعلان',
    'اتصالات وإنترنت',
    'ضرائب ورسوم',
    'أخرى',
  ];

  // العملات المتاحة
  static const List<Map<String, String>> availableCurrencies = [
    {'code': 'IQD', 'symbol': 'د.ع', 'name': 'دينار عراقي'},
    {'code': 'USD', 'symbol': '\$', 'name': 'دولار أمريكي'},
    {'code': 'EUR', 'symbol': '€', 'name': 'يورو'},
    {'code': 'GBP', 'symbol': '£', 'name': 'جنيه إسترليني'},
    {'code': 'SAR', 'symbol': 'ر.س', 'name': 'ريال سعودي'},
    {'code': 'AED', 'symbol': 'د.إ', 'name': 'درهم إماراتي'},
    {'code': 'KWD', 'symbol': 'د.ك', 'name': 'دينار كويتي'},
  ];

  // تنسيقات التاريخ
  static const List<String> dateFormats = [
    'dd/MM/yyyy',
    'MM/dd/yyyy',
    'yyyy-MM-dd',
    'dd-MM-yyyy',
  ];

  // الحد الأقصى لطول الاسم
  static const int maxNameLength = 50;

  // الحد الأقصى لطول رقم الهاتف
  static const int maxPhoneLength = 15;

  // الحد الأقصى لطول الوصف
  static const int maxDescriptionLength = 200;

  // المسافات والأبعاد
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // أحجام الخطوط
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;

  // مدة الرسوم المتحركة
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
}
