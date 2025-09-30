class Customer {
  final int? id;
  final String name;
  final String? phoneNumber;
  final double balance; // الرصيد: موجب = دائن، سالب = مدين

  Customer({
    this.id,
    required this.name,
    this.phoneNumber,
    this.balance = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'balance': balance,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      balance: map['balance']?.toDouble() ?? 0.0,
    );
  }

  Customer copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    double? balance,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      balance: balance ?? this.balance,
    );
  }

  @override
  String toString() {
    return 'Customer{id: $id, name: $name, phoneNumber: $phoneNumber, balance: $balance}';
  }
}
