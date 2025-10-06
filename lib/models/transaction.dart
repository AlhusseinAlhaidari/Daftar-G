enum TransactionType {
  debt, // دين (مشتريات)
  payment, // دفعة (سداد)
  expense, // مصروف
}

class Transaction {
  final int? id;
  final int? customerId;
  final double amount;
  final TransactionType type;
  final String? description;
  final String? category; // فئة المصروف
  final DateTime date;

  Transaction({
    this.id,
    this.customerId,
    required this.amount,
    required this.type,
    this.description,
    this.category,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  // تحويل من Map إلى Transaction
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      customerId: map['customerId'] as int?,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values[map['type'] as int],
      description: map['description'] as String?,
      category: map['category'] as String?,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
    );
  }

  // تحويل من Transaction إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'amount': amount,
      'type': type.index,
      'description': description,
      'category': category,
      'date': date.millisecondsSinceEpoch,
    };
  }

  // نسخ مع تعديل
  Transaction copyWith({
    int? id,
    int? customerId,
    double? amount,
    TransactionType? type,
    String? description,
    String? category,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, customerId: $customerId, amount: $amount, type: $type, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.customerId == customerId &&
        other.amount == amount &&
        other.type == type &&
        other.description == description &&
        other.category == category;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        customerId.hashCode ^
        amount.hashCode ^
        type.hashCode ^
        description.hashCode ^
        category.hashCode;
  }
}
