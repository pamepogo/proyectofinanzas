// Define TransactionType primero
enum TransactionType {
  INGRESO,
  GASTO,
}

class Transaction {
  int? id;
  String description;
  double amount;
  DateTime date;
  String category;
  TransactionType type;

  Transaction({
    this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
  });

  double get signedAmount {
    return type == TransactionType.INGRESO ? amount : -amount;
  }

  int get colorType {
    return type == TransactionType.INGRESO ? 0xFF4CAF50 : 0xFFF44336;
  }

  String get typeIcon {
    return type == TransactionType.INGRESO ? '💰' : '💸';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'category': category,
      'type': type == TransactionType.INGRESO ? 'INGRESO' : 'GASTO',
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      category: map['category'],
      type: map['type'] == 'INGRESO' ? TransactionType.INGRESO : TransactionType.GASTO,
    );
  }
}