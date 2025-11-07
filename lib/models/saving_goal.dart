class SavingGoal {
  final String? id;
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

  Map<String, dynamic> toMap() {
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

  factory SavingGoal.fromMap(Map<String, dynamic> map) {
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
}