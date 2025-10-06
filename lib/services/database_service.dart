import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/customer.dart';
import '../models/transaction.dart' as app_transaction;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'daftar_g_v2.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // إنشاء جدول الزبائن
    await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phoneNumber TEXT,
        balance REAL DEFAULT 0.0,
        createdAt INTEGER NOT NULL
      )
    ''');

    // إنشاء جدول المعاملات
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER,
        amount REAL NOT NULL,
        type INTEGER NOT NULL,
        description TEXT,
        category TEXT,
        date INTEGER NOT NULL,
        FOREIGN KEY (customerId) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    // إنشاء فهارس لتحسين الأداء
    await db.execute('CREATE INDEX idx_customer_name ON customers(name)');
    await db.execute('CREATE INDEX idx_transaction_customer ON transactions(customerId)');
    await db.execute('CREATE INDEX idx_transaction_date ON transactions(date)');
    await db.execute('CREATE INDEX idx_transaction_type ON transactions(type)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // إضافة حقل createdAt إذا لم يكن موجوداً
      await db.execute('ALTER TABLE customers ADD COLUMN createdAt INTEGER DEFAULT 0');
      // إضافة حقل category للمعاملات
      await db.execute('ALTER TABLE transactions ADD COLUMN category TEXT');
    }
  }

  // ============= عمليات الزبائن =============

  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert(
      'customers',
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  Future<Customer?> getCustomer(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    // حذف جميع معاملات الزبون أولاً
    await db.delete(
      'transactions',
      where: 'customerId = ?',
      whereArgs: [id],
    );
    // ثم حذف الزبون
    return await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'name LIKE ? OR phoneNumber LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  // ============= عمليات المعاملات =============

  Future<int> insertTransaction(app_transaction.Transaction transaction) async {
    final db = await database;
    final id = await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // تحديث رصيد الزبون إذا كانت المعاملة مرتبطة بزبون
    if (transaction.customerId != null) {
      await updateCustomerBalance(transaction.customerId!);
    }
    
    return id;
  }

  Future<List<app_transaction.Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => app_transaction.Transaction.fromMap(maps[i]));
  }

  Future<List<app_transaction.Transaction>> getCustomerTransactions(int customerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'customerId = ?',
      whereArgs: [customerId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => app_transaction.Transaction.fromMap(maps[i]));
  }

  Future<List<app_transaction.Transaction>> getExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'type = ? AND customerId IS NULL',
      whereArgs: [app_transaction.TransactionType.expense.index],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => app_transaction.Transaction.fromMap(maps[i]));
  }

  Future<List<app_transaction.Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => app_transaction.Transaction.fromMap(maps[i]));
  }

  Future<int> updateTransaction(app_transaction.Transaction transaction) async {
    final db = await database;
    final result = await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
    
    // تحديث رصيد الزبون
    if (transaction.customerId != null) {
      await updateCustomerBalance(transaction.customerId!);
    }
    
    return result;
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    
    // الحصول على المعاملة قبل حذفها لتحديث الرصيد
    final transaction = await getTransaction(id);
    
    final result = await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    // تحديث رصيد الزبون
    if (transaction != null && transaction.customerId != null) {
      await updateCustomerBalance(transaction.customerId!);
    }
    
    return result;
  }

  Future<app_transaction.Transaction?> getTransaction(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return app_transaction.Transaction.fromMap(maps.first);
    }
    return null;
  }

  // ============= حسابات الرصيد =============

  Future<double> calculateCustomerBalance(int customerId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN type = ? THEN amount ELSE 0 END) as totalDebt,
        SUM(CASE WHEN type = ? THEN amount ELSE 0 END) as totalPayment
      FROM transactions 
      WHERE customerId = ?
    ''', [
      app_transaction.TransactionType.debt.index,
      app_transaction.TransactionType.payment.index,
      customerId,
    ]);

    if (result.isNotEmpty) {
      final totalDebt = (result.first['totalDebt'] as num?)?.toDouble() ?? 0.0;
      final totalPayment = (result.first['totalPayment'] as num?)?.toDouble() ?? 0.0;
      return totalPayment - totalDebt; // موجب = دائن، سالب = مدين
    }
    return 0.0;
  }

  Future<void> updateCustomerBalance(int customerId) async {
    final balance = await calculateCustomerBalance(customerId);
    final db = await database;
    await db.update(
      'customers',
      {'balance': balance},
      where: 'id = ?',
      whereArgs: [customerId],
    );
  }

  // ============= إحصائيات =============

  Future<Map<String, double>> getTotalStats() async {
    final db = await database;
    
    // إجمالي الديون والمبالغ الدائنة
    final customersResult = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN balance < 0 THEN ABS(balance) ELSE 0 END) as totalDebts,
        SUM(CASE WHEN balance > 0 THEN balance ELSE 0 END) as totalCredits
      FROM customers
    ''');
    
    // إجمالي المصروفات
    final expensesResult = await db.rawQuery('''
      SELECT SUM(amount) as totalExpenses
      FROM transactions
      WHERE type = ? AND customerId IS NULL
    ''', [app_transaction.TransactionType.expense.index]);
    
    return {
      'totalDebts': (customersResult.first['totalDebts'] as num?)?.toDouble() ?? 0.0,
      'totalCredits': (customersResult.first['totalCredits'] as num?)?.toDouble() ?? 0.0,
      'totalExpenses': (expensesResult.first['totalExpenses'] as num?)?.toDouble() ?? 0.0,
    };
  }

  Future<Map<String, int>> getCustomerStats() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(CASE WHEN balance < 0 THEN 1 END) as debtors,
        COUNT(CASE WHEN balance > 0 THEN 1 END) as creditors,
        COUNT(CASE WHEN balance = 0 THEN 1 END) as balanced
      FROM customers
    ''');
    
    return {
      'debtors': (result.first['debtors'] as int?) ?? 0,
      'creditors': (result.first['creditors'] as int?) ?? 0,
      'balanced': (result.first['balanced'] as int?) ?? 0,
    };
  }

  // ============= النسخ الاحتياطي والاستعادة =============

  Future<Map<String, dynamic>> exportData() async {
    final customers = await getAllCustomers();
    final transactions = await getAllTransactions();
    
    return {
      'version': 2,
      'exportDate': DateTime.now().toIso8601String(),
      'customers': customers.map((c) => c.toMap()).toList(),
      'transactions': transactions.map((t) => t.toMap()).toList(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    final db = await database;
    
    // حذف البيانات الحالية
    await db.delete('transactions');
    await db.delete('customers');
    
    // استيراد الزبائن
    final customers = (data['customers'] as List)
        .map((c) => Customer.fromMap(c as Map<String, dynamic>))
        .toList();
    
    for (final customer in customers) {
      await db.insert('customers', customer.toMap());
    }
    
    // استيراد المعاملات
    final transactions = (data['transactions'] as List)
        .map((t) => app_transaction.Transaction.fromMap(t as Map<String, dynamic>))
        .toList();
    
    for (final transaction in transactions) {
      await db.insert('transactions', transaction.toMap());
    }
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('customers');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
