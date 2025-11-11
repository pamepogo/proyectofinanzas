// services/saving_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/saving_goal.dart';
import '../models/transaction.dart' as my_models;
import 'optimized_transaction_service.dart';

class SavingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OptimizedTransactionService _transactionService;

  SavingService(this._transactionService);

  // ✅ CONSULTA SIMPLE para metas
  Future<List<SavingGoal>> getSavingGoals() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      // SOLO filtrar por usuario - sin ordenamiento complejo
      final snapshot = await _firestore
          .collection('saving_goals')
          .where('userId', isEqualTo: user.uid)
          .get();
      
      final goals = snapshot.docs.map((doc) => SavingGoal.fromFirestore(doc)).toList();
      
      // Ordenar en memoria por fecha de creación
      goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return goals;
    } catch (e) {
      print('Error obteniendo metas de ahorro: $e');
      throw e;
    }
  }

  // ✅ STREAM simple para metas
  Stream<List<SavingGoal>> getSavingGoalsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('saving_goals')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final goals = snapshot.docs.map((doc) => SavingGoal.fromFirestore(doc)).toList();
          goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return goals;
        });
  }

  // ✅ CREAR meta
  Future<void> createSavingGoal(SavingGoal goal) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');
      
      await _firestore.collection('saving_goals').add({
        'name': goal.name,
        'description': goal.description,
        'targetAmount': goal.targetAmount,
        'currentAmount': goal.currentAmount,
        'targetDate': Timestamp.fromDate(goal.targetDate),
        'createdAt': Timestamp.fromDate(goal.createdAt),
        'icon': goal.icon,
        'userId': user.uid,
      });
    } catch (e) {
      print('Error creando meta de ahorro: $e');
      throw e;
    }
  }

  // ✅ ACTUALIZAR meta
  Future<void> updateSavingGoal(SavingGoal updatedGoal) async {
    try {
      await _firestore.collection('saving_goals').doc(updatedGoal.id).update({
        'name': updatedGoal.name,
        'description': updatedGoal.description,
        'targetAmount': updatedGoal.targetAmount,
        'targetDate': Timestamp.fromDate(updatedGoal.targetDate),
        'icon': updatedGoal.icon,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error actualizando meta: $e');
      throw e;
    }
  }

  // ✅ AGREGAR dinero a meta
  Future<void> addToSavingGoal(String goalId, double amount) async {
    try {
      final goal = await getGoalById(goalId);
      if (goal != null) {
        final newAmount = goal.currentAmount + amount;
        await _firestore.collection('saving_goals').doc(goalId).update({
          'currentAmount': newAmount,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Crear transacción de ahorro
        await _transactionService.addTransaction(
          my_models.Transaction(
            amount: amount,
            description: 'Aporte a meta: ${goal.name}',
            category: 'Ahorro',
            date: DateTime.now(),
            type: my_models.TransactionType.GASTO,
          ),
        );
      }
    } catch (e) {
      print('Error agregando dinero a meta: $e');
      throw e;
    }
  }

  // ✅ ELIMINAR meta
  Future<void> deleteSavingGoal(String goalId) async {
    try {
      await _firestore.collection('saving_goals').doc(goalId).delete();
    } catch (e) {
      print('Error eliminando meta de ahorro: $e');
      throw e;
    }
  }

  // ✅ OBTENER meta por ID
  Future<SavingGoal?> getGoalById(String goalId) async {
    try {
      final doc = await _firestore.collection('saving_goals').doc(goalId).get();
      return doc.exists ? SavingGoal.fromFirestore(doc) : null;
    } catch (e) {
      print('Error obteniendo meta por ID: $e');
      return null;
    }
  }

  // ✅ MÉTODOS ADICIONALES
  Future<double> getTotalSaved() async {
    try {
      final List<SavingGoal> goals = await getSavingGoals();
      double total = 0.0;
      for (final goal in goals) {
        total += goal.currentAmount;
      }
      return total;
    } catch (e) {
      print('Error calculando total ahorrado: $e');
      return 0.0;
    }
  }

  Future<List<SavingGoal>> getUpcomingGoals() async {
    try {
      final List<SavingGoal> goals = await getSavingGoals();
      goals.sort((a, b) {
        final progressA = a.targetAmount > 0 ? a.currentAmount / a.targetAmount : 0;
        final progressB = b.targetAmount > 0 ? b.currentAmount / b.targetAmount : 0;
        return progressB.compareTo(progressA);
      });
      return goals.take(3).toList();
    } catch (e) {
      print('Error obteniendo metas próximas: $e');
      return [];
    }
  }
}