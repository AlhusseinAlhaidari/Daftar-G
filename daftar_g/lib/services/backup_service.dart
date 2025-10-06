import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'database_service.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;

  // تسجيل الدخول إلى Google
  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return false;

      _currentUser = account;
      
      // ملاحظة: تكامل Google Drive يتطلب إعداد إضافي
      // هذه نسخة مبسطة للعرض التوضيحي
      debugPrint('تم تسجيل الدخول بنجاح');
      return true;
    } catch (e) {
      debugPrint('خطأ في تسجيل الدخول: $e');
      return false;
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _driveApi = null;
  }

  // التحقق من حالة تسجيل الدخول
  bool get isSignedIn => _currentUser != null;

  // الحصول على المستخدم الحالي
  GoogleSignInAccount? get currentUser => _currentUser;

  // إنشاء نسخة احتياطية
  Future<String?> createBackup() async {
    if (_driveApi == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    try {
      // تصدير البيانات من قاعدة البيانات
      final dbService = DatabaseService();
      final data = await dbService.exportData();
      
      // تحويل البيانات إلى JSON
      final jsonData = json.encode(data);
      
      // إنشاء ملف مؤقت
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'daftar_g_backup_$timestamp.json';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsString(jsonData);

      // رفع الملف إلى Google Drive
      final driveFile = drive.File()
        ..name = fileName
        ..description = 'نسخة احتياطية من تطبيق دفترچي'
        ..mimeType = 'application/json';

      final media = drive.Media(tempFile.openRead(), tempFile.lengthSync());
      
      final uploadedFile = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );

      // حذف الملف المؤقت
      await tempFile.delete();

      return uploadedFile.id;
    } catch (e) {
      debugPrint('خطأ في إنشاء النسخة الاحتياطية: $e');
      return null;
    }
  }

  // الحصول على قائمة النسخ الاحتياطية
  Future<List<BackupInfo>> listBackups() async {
    if (_driveApi == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    try {
      final fileList = await _driveApi!.files.list(
        q: "name contains 'daftar_g_backup_' and mimeType='application/json'",
        orderBy: 'createdTime desc',
        spaces: 'drive',
        $fields: 'files(id, name, createdTime, size)',
      );

      return fileList.files?.map((file) {
        return BackupInfo(
          id: file.id!,
          name: file.name!,
          createdTime: file.createdTime ?? DateTime.now(),
          size: int.tryParse(file.size ?? '0') ?? 0,
        );
      }).toList() ?? [];
    } catch (e) {
      debugPrint('خطأ في الحصول على قائمة النسخ الاحتياطية: $e');
      return [];
    }
  }

  // استعادة نسخة احتياطية
  Future<bool> restoreBackup(String fileId) async {
    if (_driveApi == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    try {
      // تحميل الملف من Google Drive
      final media = await _driveApi!.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      // قراءة محتوى الملف
      final dataBytes = <int>[];
      await for (var chunk in media.stream) {
        dataBytes.addAll(chunk);
      }
      
      final jsonData = utf8.decode(dataBytes);
      final data = json.decode(jsonData) as Map<String, dynamic>;

      // استيراد البيانات إلى قاعدة البيانات
      final dbService = DatabaseService();
      await dbService.importData(data);

      return true;
    } catch (e) {
      debugPrint('خطأ في استعادة النسخة الاحتياطية: $e');
      return false;
    }
  }

  // حذف نسخة احتياطية
  Future<bool> deleteBackup(String fileId) async {
    if (_driveApi == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    try {
      await _driveApi!.files.delete(fileId);
      return true;
    } catch (e) {
      debugPrint('خطأ في حذف النسخة الاحتياطية: $e');
      return false;
    }
  }
}

// فئة لتخزين معلومات النسخة الاحتياطية
class BackupInfo {
  final String id;
  final String name;
  final DateTime createdTime;
  final int size;

  BackupInfo({
    required this.id,
    required this.name,
    required this.createdTime,
    required this.size,
  });

  String get formattedSize {
    if (size < 1024) return '$size بايت';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(2)} كيلوبايت';
    return '${(size / (1024 * 1024)).toStringAsFixed(2)} ميجابايت';
  }
}


