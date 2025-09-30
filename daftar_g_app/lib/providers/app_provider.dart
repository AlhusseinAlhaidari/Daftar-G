import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/transaction.dart' as app_transaction;
import '../services/database_service.dart';

class AppProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<Customer> _customers = [];
  List<app_transaction.Transaction> _transactions = [];
  List<app_transaction.Transaction> _expenses = [];
  
  bool _isLoading = false;

  List<Customer> get customers => _customers;
  List<app_transaction.Transaction> get transactions => _transactions;
  List<app_transaction.Transaction> get expenses => _expenses;
  bool get isLoading => _isLoading;

  // حساب إجمالي الديون (المبالغ المستحقة للتاجر)
  double get totalDebts {
    return _customers
        .where((customer) => customer.balance < 0)
        .fold(0.0, (sum, customer) => sum + customer.balance.abs());
  }

  // حساب إجمالي المبالغ الدائنة (المبالغ المستحقة للزبائن)
  double get totalCredits {
    return _customers
        .where((customer) => customer.balance > 0)
        .fold(0.0, (sum, customer) => sum + customer.balance);
  }

  // حساب إجمالي المصروفات
  double get totalExpenses {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _customers = await _databaseService.getAllCustomers();
      _transactions = await _databaseService.getAllTransactions();
      _expenses = await _databaseService.getExpenses();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // عمليات الزبائن
  Future<void> addCustomer(String name, {String? phoneNumber}) async {
    try {
      final customer = Customer(name: name, phoneNumber: phoneNumber);
      await _databaseService.insertCustomer(customer);
      await loadData();
    } catch (e) {
      debugPrint('Error adding customer: $e');
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      await _databaseService.updateCustomer(customer);
      await loadData();
    } catch (e) {
      debugPrint('Error updating customer: $e');
    }
  }

  Future<void> deleteCustomer(int customerId) async {
    try {
      await _databaseService.deleteCustomer(customerId);
      await loadData();
    } catch (e) {
      debugPrint('Error deleting customer: $e');
    }
  }

  // عمليات المعاملات
  Future<void> addDebt(int customerId, double amount, {String? description}) async {
    try {
      final transaction = app_transaction.Transaction(
        customerId: customerId,
        amount: amount,
        type: app_transaction.TransactionType.debt,
        description: description,
        date: DateTime.now(),
      );
      await _databaseService.insertTransaction(transaction);
      await _databaseService.updateCustomerBalance(customerId);
      await loadData();
    } catch (e) {
      debugPrint('Error adding debt: $e');
    }
  }

  Future<void> addPayment(int customerId, double amount, {String? description}) async {
    try {
      final transaction = app_transaction.Transaction(
        customerId: customerId,
        amount: amount,
        type: app_transaction.TransactionType.payment,
        description: description,
        date: DateTime.now(),
      );
      await _databaseService.insertTransaction(transaction);
      await _databaseService.updateCustomerBalance(customerId);
      await loadData();
    } catch (e) {
      debugPrint('Error adding payment: $e');
    }
  }

  Future<void> addExpense(double amount, {String? description}) async {
    try {
      final transaction = app_transaction.Transaction(
        amount: amount,
        type: app_transaction.TransactionType.expense,
        description: description,
        date: DateTime.now(),
      );
      await _databaseService.insertTransaction(transaction);
      await loadData();
    } catch (e) {
      debugPrint('Error adding expense: $e');
    }
  }

  Future<List<app_transaction.Transaction>> getCustomerTransactions(int customerId) async {
    try {
      return await _databaseService.getCustomerTransactions(customerId);
    } catch (e) {
      debugPrint('Error getting customer transactions: $e');
      return [];
    }
  }

  // البحث في الزبائن
  List<Customer> searchCustomers(String query) {
    if (query.isEmpty) return _customers;
    
    return _customers.where((customer) {
      return customer.name.toLowerCase().contains(query.toLowerCase()) ||
             (customer.phoneNumber?.contains(query) ?? false);
    }).toList();
  }
}
