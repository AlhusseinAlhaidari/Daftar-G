class Customer {
  final int? id;
  final String name;
  final String? phoneNumber;
  final double balance;
  final DateTime createdAt;

  Customer({
    this.id,
    required this.name,
    this.phoneNumber,
    this.balance = 0.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // تحويل من Map إلى Customer
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String?,
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  // تحويل من Customer إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'balance': balance,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // نسخ مع تعديل
  Customer copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    double? balance,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // هل الزبون مدين (رصيد سالب)
  bool get isDebtor => balance < 0;

  // هل الزبون دائن (رصيد موجب)
  bool get isCreditor => balance > 0;

  // هل الرصيد صفر
  bool get isBalanced => balance == 0;

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, phoneNumber: $phoneNumber, balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer &&
        other.id == id &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.balance == balance;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        phoneNumber.hashCode ^
        balance.hashCode;
  }
}
