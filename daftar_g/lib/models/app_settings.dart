import 'package:flutter/material.dart';

enum ThemeMode {
  light,
  dark,
  system,
}

class AppSettings {
  final ThemeMode themeMode;
  final Color primaryColor;
  final String currency;
  final String dateFormat;
  final bool enableNotifications;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.primaryColor = Colors.teal,
    this.currency = 'د.ع', // دينار عراقي
    this.dateFormat = 'dd/MM/yyyy',
    this.enableNotifications = true,
  });

  // تحويل من Map إلى AppSettings
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      themeMode: ThemeMode.values[map['themeMode'] as int? ?? 2],
      primaryColor: Color(map['primaryColor'] as int? ?? Colors.teal.value),
      currency: map['currency'] as String? ?? 'د.ع',
      dateFormat: map['dateFormat'] as String? ?? 'dd/MM/yyyy',
      enableNotifications: map['enableNotifications'] as bool? ?? true,
    );
  }

  // تحويل من AppSettings إلى Map
  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'primaryColor': primaryColor.value,
      'currency': currency,
      'dateFormat': dateFormat,
      'enableNotifications': enableNotifications,
    };
  }

  // نسخ مع تعديل
  AppSettings copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
    String? currency,
    String? dateFormat,
    bool? enableNotifications,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      enableNotifications: enableNotifications ?? this.enableNotifications,
    );
  }

  @override
  String toString() {
    return 'AppSettings(themeMode: $themeMode, primaryColor: $primaryColor, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.primaryColor == primaryColor &&
        other.currency == currency &&
        other.dateFormat == dateFormat &&
        other.enableNotifications == enableNotifications;
  }

  @override
  int get hashCode {
    return themeMode.hashCode ^
        primaryColor.hashCode ^
        currency.hashCode ^
        dateFormat.hashCode ^
        enableNotifications.hashCode;
  }
}
