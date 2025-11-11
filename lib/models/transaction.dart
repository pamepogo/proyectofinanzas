import 'package:cloud_firestore/cloud_firestore.dart';

// Define TransactionType primero
enum TransactionType {
  // ignore: constant_identifier_names
  INGRESO,
  // ignore: constant_identifier_names
  GASTO,
}

class Transaction {
  String? id; // ✅ Cambiado de int? a String? (Firestore document ID)
  String description;
  double amount;
  DateTime date;
  String category;
  TransactionType type;
  String? savingGoalId;

  Transaction({
    this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.savingGoalId,
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

  // ✅ Adaptado para Firestore
  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'amount': amount,
      'date': Timestamp.fromDate(date), // ✅ Usa Timestamp de Firebase
      'category': category,
      'type': type == TransactionType.INGRESO ? 'INGRESO' : 'GASTO',
      'savingGoalId': savingGoalId,
      'createdAt': FieldValue.serverTimestamp(), // ✅ Para ordenamiento
    };
  }

  // ✅ Factory method desde Firestore Document
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id, // ✅ Usa el ID del documento de Firestore
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(), // ✅ Convierte Timestamp a DateTime
      category: data['category'] ?? 'Otros',
      type: data['type'] == 'INGRESO' ? TransactionType.INGRESO : TransactionType.GASTO,
      savingGoalId: data['savingGoalId'],
    );
  }

  // ✅ Método para compatibilidad (si aún necesitas milliseconds)
  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'category': category,
      'type': type == TransactionType.INGRESO ? 'INGRESO' : 'GASTO',
      'savingGoalId': savingGoalId,
    };
  }

  // ✅ Factory method para compatibilidad
  factory Transaction.fromLocalMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id']?.toString(), // ✅ Convierte a string si es necesario
      description: map['description'],
      amount: map['amount'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      category: map['category'],
      type: map['type'] == 'INGRESO' ? TransactionType.INGRESO : TransactionType.GASTO,
      savingGoalId: map['savingGoalId'],
    );
  }
}