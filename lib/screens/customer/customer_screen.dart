import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/customer.dart';
import '../../models/transaction.dart';
import '../../providers/app_providers.dart';
import '../../constants/app_constants.dart';

class CustomerScreen extends ConsumerStatefulWidget {
  final Customer customer;

  const CustomerScreen({super.key, required this.customer});

  @override
  ConsumerState<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends ConsumerState<CustomerScreen> {
  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(customerTransactionsProvider(widget.customer.id!));
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: تعديل الزبون
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // معلومات الزبون
          _buildCustomerInfo(settings),
          
          const Divider(height: 1),
          
          // المعاملات
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Center(
                    child: Text('لا توجد معاملات بعد'),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return _buildTransactionItem(transaction, settings);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('خطأ: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'debt',
            onPressed: () => _showAddTransactionDialog(TransactionType.debt),
            backgroundColor: Colors.red,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'payment',
            onPressed: () => _showAddTransactionDialog(TransactionType.payment),
            backgroundColor: Colors.green,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(settings) {
    final numberFormat = NumberFormat('#,##0.00', 'ar');
    final balance = widget.customer.balance;
    final color = balance < 0 ? Colors.red : balance > 0 ? Colors.green : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      color: color.withOpacity(0.1),
      child: Column(
        children: [
          if (widget.customer.phoneNumber != null)
            Text(
              widget.customer.phoneNumber!,
              style: const TextStyle(fontSize: 16),
            ),
          const SizedBox(height: 8),
          Text(
            'الرصيد الحالي',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            '${numberFormat.format(balance.abs())} ${settings.currency}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            balance < 0 ? 'مدين' : balance > 0 ? 'دائن' : 'متوازن',
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction, settings) {
    final numberFormat = NumberFormat('#,##0.00', 'ar');
    final dateFormat = DateFormat('dd/MM/yyyy - HH:mm', 'ar');
    final isDebt = transaction.type == TransactionType.debt;
    final color = isDebt ? Colors.red : Colors.green;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(
            isDebt ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
          ),
        ),
        title: Text(
          isDebt ? 'دين' : 'دفعة',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.description != null && transaction.description!.isNotEmpty)
              Text(transaction.description!),
            Text(
              dateFormat.format(transaction.date),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Text(
          '${numberFormat.format(transaction.amount)} ${settings.currency}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  void _showAddTransactionDialog(TransactionType type) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type == TransactionType.debt ? 'إضافة دين' : 'إضافة دفعة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'الوصف (اختياري)',
                prefixIcon: Icon(Icons.description),
              ),
              maxLength: AppConstants.maxDescriptionLength,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الرجاء إدخال مبلغ صحيح')),
                );
                return;
              }

              Navigator.pop(context);

              if (type == TransactionType.debt) {
                await ref.read(transactionsProvider.notifier).addDebt(
                      widget.customer.id!,
                      amount,
                      description: descriptionController.text.trim().isEmpty
                          ? null
                          : descriptionController.text.trim(),
                    );
              } else {
                await ref.read(transactionsProvider.notifier).addPayment(
                      widget.customer.id!,
                      amount,
                      description: descriptionController.text.trim().isEmpty
                          ? null
                          : descriptionController.text.trim(),
                    );
              }

              ref.invalidate(customerTransactionsProvider(widget.customer.id!));
              ref.invalidate(customersProvider);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف ${widget.customer.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(customersProvider.notifier).deleteCustomer(widget.customer.id!);
              if (mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
