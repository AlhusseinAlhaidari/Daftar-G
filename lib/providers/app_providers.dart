import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart' hide ThemeMode;
import '../models/customer.dart';
import '../models/transaction.dart';
import '../models/app_settings.dart';
import '../services/database_service.dart';
import '../services/settings_service.dart';
import '../services/backup_service.dart';

// ============= Database Service Provider =============
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// ============= Settings Service Provider =============
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

// ============= Backup Service Provider =============
final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService();
});

// ============= Settings Provider =============
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.read(settingsServiceProvider));
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsService _settingsService;

  SettingsNotifier(this._settingsService) : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsService.loadSettings();
    state = settings;
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final newSettings = state.copyWith(themeMode: themeMode);
    state = newSettings;
    await _settingsService.saveSettings(newSettings);
  }

  Future<void> updatePrimaryColor(Color color) async {
    final newSettings = state.copyWith(primaryColor: color);
    state = newSettings;
    await _settingsService.saveSettings(newSettings);
  }

  Future<void> updateCurrency(String currency) async {
    final newSettings = state.copyWith(currency: currency);
    state = newSettings;
    await _settingsService.saveSettings(newSettings);
  }

  Future<void> updateDateFormat(String dateFormat) async {
    final newSettings = state.copyWith(dateFormat: dateFormat);
    state = newSettings;
    await _settingsService.saveSettings(newSettings);
  }

  Future<void> updateNotifications(bool enabled) async {
    final newSettings = state.copyWith(enableNotifications: enabled);
    state = newSettings;
    await _settingsService.saveSettings(newSettings);
  }
}

// ============= Customers Provider =============
final customersProvider = StateNotifierProvider<CustomersNotifier, AsyncValue<List<Customer>>>((ref) {
  return CustomersNotifier(ref.read(databaseServiceProvider));
});

class CustomersNotifier extends StateNotifier<AsyncValue<List<Customer>>> {
  final DatabaseService _databaseService;

  CustomersNotifier(this._databaseService) : super(const AsyncValue.loading()) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    state = const AsyncValue.loading();
    try {
      final customers = await _databaseService.getAllCustomers();
      state = AsyncValue.data(customers);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addCustomer(String name, {String? phoneNumber}) async {
    try {
      final customer = Customer(name: name, phoneNumber: phoneNumber);
      await _databaseService.insertCustomer(customer);
      await loadCustomers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      await _databaseService.updateCustomer(customer);
      await loadCustomers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteCustomer(int customerId) async {
    try {
      await _databaseService.deleteCustomer(customerId);
      await loadCustomers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<List<Customer>> searchCustomers(String query) async {
    try {
      return await _databaseService.searchCustomers(query);
    } catch (e) {
      return [];
    }
  }
}

// ============= Transactions Provider =============
final transactionsProvider = StateNotifierProvider<TransactionsNotifier, AsyncValue<List<Transaction>>>((ref) {
  return TransactionsNotifier(ref.read(databaseServiceProvider));
});

class TransactionsNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  final DatabaseService _databaseService;

  TransactionsNotifier(this._databaseService) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = const AsyncValue.loading();
    try {
      final transactions = await _databaseService.getAllTransactions();
      state = AsyncValue.data(transactions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addDebt(int customerId, double amount, {String? description}) async {
    try {
      final transaction = Transaction(
        customerId: customerId,
        amount: amount,
        type: TransactionType.debt,
        description: description,
      );
      await _databaseService.insertTransaction(transaction);
      await loadTransactions();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addPayment(int customerId, double amount, {String? description}) async {
    try {
      final transaction = Transaction(
        customerId: customerId,
        amount: amount,
        type: TransactionType.payment,
        description: description,
      );
      await _databaseService.insertTransaction(transaction);
      await loadTransactions();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addExpense(double amount, String category, {String? description}) async {
    try {
      final transaction = Transaction(
        amount: amount,
        type: TransactionType.expense,
        category: category,
        description: description,
      );
      await _databaseService.insertTransaction(transaction);
      await loadTransactions();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    try {
      await _databaseService.deleteTransaction(transactionId);
      await loadTransactions();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<List<Transaction>> getCustomerTransactions(int customerId) async {
    try {
      return await _databaseService.getCustomerTransactions(customerId);
    } catch (e) {
      return [];
    }
  }

  Future<List<Transaction>> getExpenses() async {
    try {
      return await _databaseService.getExpenses();
    } catch (e) {
      return [];
    }
  }
}

// ============= Statistics Provider =============
final statisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final databaseService = ref.read(databaseServiceProvider);
  
  final totalStats = await databaseService.getTotalStats();
  final customerStats = await databaseService.getCustomerStats();
  
  return {
    ...totalStats,
    ...customerStats,
  };
});

// ============= Customer Transactions Provider =============
final customerTransactionsProvider = FutureProvider.family<List<Transaction>, int>((ref, customerId) async {
  final databaseService = ref.read(databaseServiceProvider);
  return await databaseService.getCustomerTransactions(customerId);
});
