import 'package:cloud_firestore/cloud_firestore.dart';

class SavingGoal {
  final String? id; // ✅ Ya es String, perfecto para Firestore
  final String name;
  final String description;
  final double targetAmount;
  double currentAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final String icon;

  SavingGoal({
    this.id,
    required this.name,
    required this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.createdAt,
    required this.icon,
  });

  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0;
  double get remaining => targetAmount - currentAmount;
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;
  bool get isCompleted => currentAmount >= targetAmount;

  // ✅ Adaptado para Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': Timestamp.fromDate(targetDate), // ✅ Usa Timestamp
      'createdAt': Timestamp.fromDate(createdAt), // ✅ Usa Timestamp
      'icon': icon,
      'updatedAt': FieldValue.serverTimestamp(), // ✅ Para updates
    };
  }

  // ✅ Factory method desde Firestore Document
  factory SavingGoal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavingGoal(
      id: doc.id, // ✅ Usa el ID del documento de Firestore
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      targetAmount: (data['targetAmount'] ?? 0).toDouble(),
      currentAmount: (data['currentAmount'] ?? 0).toDouble(),
      targetDate: (data['targetDate'] as Timestamp).toDate(), // ✅ Convierte Timestamp
      createdAt: (data['createdAt'] as Timestamp).toDate(), // ✅ Convierte Timestamp
      icon: data['icon'] ?? '💰',
    );
  }

  // ✅ Método para compatibilidad (si aún necesitas milliseconds)
  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'icon': icon,
    };
  }

  // ✅ Factory method para compatibilidad
  factory SavingGoal.fromLocalMap(Map<String, dynamic> map) {
    return SavingGoal(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      targetAmount: map['targetAmount'],
      currentAmount: map['currentAmount'],
      targetDate: DateTime.fromMillisecondsSinceEpoch(map['targetDate']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      icon: map['icon'],
    );
  }

  // ✅ Método para crear copia con valores actualizados
  SavingGoal copyWith({
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? icon,
  }) {
    return SavingGoal(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt,
      icon: icon ?? this.icon,
    );
  }
}