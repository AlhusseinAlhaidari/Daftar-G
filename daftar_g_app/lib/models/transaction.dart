enum TransactionType {
  debt, // دين (مشتريات)
  payment, // سداد
  expense, // مصروف
}

class Transaction {
  final int? id;
  final int? customerId; // null للمصروفات
  final double amount;
  final TransactionType type;
  final String? description;
  final DateTime date;

  Transaction({
    this.id,
    this.customerId,
    required this.amount,
    required this.type,
    this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'amount': amount,
      'type': type.index,
      'description': description,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      customerId: map['customerId'],
      amount: map['amount']?.toDouble() ?? 0.0,
      type: TransactionType.values[map['type']],
      description: map['description'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
    );
  }

  Transaction copyWith({
    int? id,
    int? customerId,
    double? amount,
    TransactionType? type,
    String? description,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'Transaction{id: $id, customerId: $customerId, amount: $amount, type: $type, description: $description, date: $date}';
  }
}
