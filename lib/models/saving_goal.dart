import 'package:cloud_firestore/cloud_firestore.dart';

class SavingGoal {
  final String? id;
  final String? userId;
  final String name;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final String icon;

  const SavingGoal({
    this.id,
    this.userId,
    required this.name,
    required this.description,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.targetDate,
    required this.createdAt,
    this.icon = '💰',
  });

  SavingGoal copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    DateTime? createdAt,
    String? icon,
  }) {
    return SavingGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': Timestamp.fromDate(targetDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'icon': icon,
    };
  }

  factory SavingGoal.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        return DateTime.now();
      }
    }

    return SavingGoal(
      id: documentId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0).toDouble(),
      targetDate: parseTimestamp(map['targetDate']),
      createdAt: parseTimestamp(map['createdAt']),
      icon: map['icon'] ?? '💰',
    );
  }

  double get progress {
    return targetAmount > 0 ? currentAmount / targetAmount : 0.0;
  }

  int get daysRemaining {
    final now = DateTime.now();
    final difference = targetDate.difference(now);
    return difference.inDays.clamp(0, 365 * 10);
  }

  bool get isCompleted {
    return currentAmount >= targetAmount;
  }

  double get remainingAmount {
    return (targetAmount - currentAmount).clamp(0, double.infinity);
  }

  @override
  String toString() {
    return 'SavingGoal(id: $id, name: $name, currentAmount: $currentAmount, targetAmount: $targetAmount)';
  }
}