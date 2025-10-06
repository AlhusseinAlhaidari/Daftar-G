import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/app_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(statisticsProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
      ),
      body: statisticsAsync.when(
        data: (stats) => _buildReports(context, stats, settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('خطأ: $error')),
      ),
    );
  }

  Widget _buildReports(BuildContext context, Map<String, dynamic> stats, settings) {
    final numberFormat = NumberFormat('#,##0.00', 'ar');
    final totalDebts = stats['totalDebts'] as double? ?? 0.0;
    final totalCredits = stats['totalCredits'] as double? ?? 0.0;
    final totalExpenses = stats['totalExpenses'] as double? ?? 0.0;
    final debtors = stats['debtors'] as int? ?? 0;
    final creditors = stats['creditors'] as int? ?? 0;
    final balanced = stats['balanced'] as int? ?? 0;
    
    final netIncome = totalDebts - totalExpenses;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ملخص مالي
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الملخص المالي',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(),
                _buildStatRow('إجمالي الديون', totalDebts, settings.currency, Colors.red),
                _buildStatRow('إجمالي الدائنين', totalCredits, settings.currency, Colors.green),
                _buildStatRow('إجمالي المصروفات', totalExpenses, settings.currency, Colors.orange),
                const Divider(),
                _buildStatRow(
                  'صافي الدخل',
                  netIncome,
                  settings.currency,
                  netIncome >= 0 ? Colors.green : Colors.red,
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // إحصائيات الزبائن
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إحصائيات الزبائن',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(),
                _buildCountRow('عدد المدينين', debtors, Colors.red),
                _buildCountRow('عدد الدائنين', creditors, Colors.green),
                _buildCountRow('عدد المتوازنين', balanced, Colors.grey),
                const Divider(),
                _buildCountRow(
                  'إجمالي الزبائن',
                  debtors + creditors + balanced,
                  Colors.blue,
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, double value, String currency, Color color, {bool isBold = false}) {
    final numberFormat = NumberFormat('#,##0.00', 'ar');
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${numberFormat.format(value)} $currency',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountRow(String label, int count, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
