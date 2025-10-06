import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../providers/app_providers.dart';

class CustomerCard extends ConsumerWidget {
  final Customer customer;
  final VoidCallback onTap;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final numberFormat = NumberFormat('#,##0.00', 'ar');
    
    Color balanceColor;
    IconData balanceIcon;
    String balanceText;

    if (customer.isDebtor) {
      balanceColor = Colors.red;
      balanceIcon = Icons.arrow_upward;
      balanceText = 'مدين';
    } else if (customer.isCreditor) {
      balanceColor = Colors.green;
      balanceIcon = Icons.arrow_downward;
      balanceText = 'دائن';
    } else {
      balanceColor = Colors.grey;
      balanceIcon = Icons.check_circle_outline;
      balanceText = 'متوازن';
    }

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: balanceColor.withOpacity(0.1),
          child: Icon(
            balanceIcon,
            color: balanceColor,
          ),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.phoneNumber != null && customer.phoneNumber!.isNotEmpty)
              Text(
                customer.phoneNumber!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              balanceText,
              style: TextStyle(
                color: balanceColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${numberFormat.format(customer.balance.abs())} ${settings.currency}',
              style: TextStyle(
                color: balanceColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
