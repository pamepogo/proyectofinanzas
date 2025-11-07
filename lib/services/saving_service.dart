import '../models/saving_goal.dart';

class SavingService {
  // Lista temporal (luego la conectas a tu base de datos)
  List<SavingGoal> _savingGoals = [];

  Future<List<SavingGoal>> getSavingGoals() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simular delay
    return _savingGoals;
  }

  Future<void> addSavingGoal(SavingGoal goal) async {
    _savingGoals.add(goal);
  }

  Future<void> addToSavingGoal(String goalId, double amount) async {
    final goal = _savingGoals.firstWhere((g) => g.id == goalId);
    goal.currentAmount += amount;
  }

  Future<void> updateSavingGoal(SavingGoal updatedGoal) async {
    final index = _savingGoals.indexWhere((g) => g.id == updatedGoal.id);
    if (index != -1) {
      _savingGoals[index] = updatedGoal;
    }
  }

  Future<void> deleteSavingGoal(String goalId) async {
    _savingGoals.removeWhere((g) => g.id == goalId);
  }
}