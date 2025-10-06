import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/app_providers.dart';
import '../../models/customer.dart';
import '../../constants/app_constants.dart';
import '../customer/add_customer_screen.dart';
import '../customer/customer_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';
import '../../widgets/customer_card.dart';
import '../../widgets/statistics_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);
    final statisticsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('دفترچي'),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.chartLine),
            tooltip: 'التقارير',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'الإعدادات',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(customersProvider);
          ref.invalidate(statisticsProvider);
        },
        child: Column(
          children: [
            // الإحصائيات
            statisticsAsync.when(
              data: (stats) => _buildStatistics(stats),
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => const SizedBox.shrink(),
            ),
            
            // شريط البحث
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث عن زبون...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            
            // قائمة الزبائن
            Expanded(
              child: customersAsync.when(
                data: (customers) {
                  final filteredCustomers = _filterCustomers(customers);
                  
                  if (filteredCustomers.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: AppConstants.paddingLarge + 56,
                    ),
                    itemCount: filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = filteredCustomers[index];
                      return CustomerCard(
                        customer: customer,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerScreen(customer: customer),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('حدث خطأ: ${error.toString()}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(customersProvider);
                        },
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCustomerScreen()),
          );
          
          if (result == true && mounted) {
            ref.invalidate(customersProvider);
            ref.invalidate(statisticsProvider);
          }
        },
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة زبون'),
      ),
    );
  }

  Widget _buildStatistics(Map<String, dynamic> stats) {
    final totalDebts = stats['totalDebts'] as double? ?? 0.0;
    final totalCredits = stats['totalCredits'] as double? ?? 0.0;
    final totalExpenses = stats['totalExpenses'] as double? ?? 0.0;
    final settings = ref.watch(settingsProvider);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        children: [
          Expanded(
            child: StatisticsCard(
              title: 'إجمالي الديون',
              value: totalDebts,
              currency: settings.currency,
              icon: FontAwesomeIcons.arrowTrendUp,
              color: Colors.red,
            ),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: StatisticsCard(
              title: 'إجمالي الدائنين',
              value: totalCredits,
              currency: settings.currency,
              icon: FontAwesomeIcons.arrowTrendDown,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: StatisticsCard(
              title: 'المصروفات',
              value: totalExpenses,
              currency: settings.currency,
              icon: FontAwesomeIcons.receipt,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? FontAwesomeIcons.users : Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty
                ? 'لا يوجد زبائن بعد'
                : 'لم يتم العثور على نتائج',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'اضغط على زر "إضافة زبون" للبدء'
                : 'جرب البحث بكلمات مختلفة',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  List<Customer> _filterCustomers(List<Customer> customers) {
    if (_searchQuery.isEmpty) {
      return customers;
    }
    
    final query = _searchQuery.toLowerCase();
    return customers.where((customer) {
      return customer.name.toLowerCase().contains(query) ||
             (customer.phoneNumber?.contains(query) ?? false);
    }).toList();
  }
}
