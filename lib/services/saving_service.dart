import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/saving_goal.dart';
import './optimized_transaction_service.dart';
import '../models/transaction.dart' as my_models;

class SavingService {
  final OptimizedTransactionService _transactionService;
  final CollectionReference _savingsCollection =
      FirebaseFirestore.instance.collection('saving_goals');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SavingService(this._transactionService);

  String? get _currentUserId => _auth.currentUser?.uid;

  void _checkAuthentication() {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado. Inicia sesión nuevamente.');
    }
  }

  Future<void> createSavingGoal(SavingGoal goal) async {
    try {
      _checkAuthentication();
      final userId = _currentUserId!;

      final docRef = _savingsCollection.doc();
      final goalWithId = goal.copyWith(
        id: docRef.id,
        userId: userId,
      );
      
      await docRef.set(goalWithId.toMap());
    } catch (e) {
      print('Error en createSavingGoal: $e');
      rethrow;
    }
  }

  Future<List<SavingGoal>> getSavingGoals() async {
    try {
      _checkAuthentication();
      final userId = _currentUserId!;

      // SOLUCIÓN TEMPORAL: Obtener sin ordenar para evitar el índice
      final querySnapshot = await _savingsCollection
          .where('userId', isEqualTo: userId)
          .get();

      // Ordenar localmente
      final goals = querySnapshot.docs
          .map((doc) => SavingGoal.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return goals;
    } catch (e) {
      print('Error en getSavingGoals: $e');
      rethrow;
    }
  }

  Future<SavingGoal?> getSavingGoal(String id) async {
    try {
      _checkAuthentication();
      final userId = _currentUserId!;

      final doc = await _savingsCollection.doc(id).get();
      if (doc.exists) {
        final goal = SavingGoal.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        if (goal.userId == userId) {
          return goal;
        } else {
          throw Exception('No tienes permisos para acceder a esta meta');
        }
      }
      return null;
    } catch (e) {
      print('Error en getSavingGoal: $e');
      rethrow;
    }
  }

  Future<void> updateSavingGoal(SavingGoal goal) async {
    try {
      _checkAuthentication();
      
      if (goal.id == null) {
        throw Exception('No se puede actualizar: ID no disponible');
      }

      final userId = _currentUserId!;

      final existingGoal = await getSavingGoal(goal.id!);
      if (existingGoal == null) {
        throw Exception('Meta no encontrada o no tienes permisos');
      }
      
      await _savingsCollection.doc(goal.id!).update(goal.toMap());
    } catch (e) {
      print('Error en updateSavingGoal: $e');
      rethrow;
    }
  }

  Future<void> deleteSavingGoal(String id) async {
    try {
      _checkAuthentication();
      final userId = _currentUserId!;

      final goal = await getSavingGoal(id);
      if (goal == null) {
        throw Exception('Meta no encontrada o no tienes permisos');
      }

      await _savingsCollection.doc(id).delete();
    } catch (e) {
      print('Error en deleteSavingGoal: $e');
      rethrow;
    }
  }

  Future<void> addToSavingGoal(String goalId, double amount) async {
    try {
      _checkAuthentication();
      
      if (amount <= 0) {
        throw Exception('La cantidad debe ser mayor a cero');
      }

      final goal = await getSavingGoal(goalId);
      if (goal == null) throw Exception('Meta no encontrada');

      final updatedGoal = goal.copyWith(
        currentAmount: goal.currentAmount + amount,
      );

      await updateSavingGoal(updatedGoal);
    } catch (e) {
      print('Error en addToSavingGoal: $e');
      rethrow;
    }
  }

  Future<void> withdrawFromSavingGoal(String goalId, double amount) async {
    try {
      _checkAuthentication();
      
      if (amount <= 0) {
        throw Exception('La cantidad debe ser mayor a cero');
      }

      final goal = await getSavingGoal(goalId);
      if (goal == null) throw Exception('Meta no encontrada');

      if (goal.currentAmount < amount) {
        throw Exception('Saldo insuficiente en la meta. Disponible: \$${goal.currentAmount.toStringAsFixed(2)}');
      }

      final updatedGoal = goal.copyWith(
        currentAmount: goal.currentAmount - amount,
      );

      await updateSavingGoal(updatedGoal);
    } catch (e) {
      print('Error en withdrawFromSavingGoal: $e');
      rethrow;
    }
  }

  Future<void> transferToSavingGoal(String goalId, double amount, String description) async {
    try {
      _checkAuthentication();
      
      if (amount <= 0) {
        throw Exception('La cantidad debe ser mayor a cero');
      }

      final goal = await getSavingGoal(goalId);
      if (goal == null) throw Exception('Meta no encontrada');

      final incomeTransaction = my_models.Transaction(
        description: description.isEmpty ? 'Transferencia a ${goal.name}' : description,
        amount: amount,
        date: DateTime.now(),
        category: 'Transferencia a Ahorro',
        type: my_models.TransactionType.INGRESO,
      );

      await _transactionService.addTransaction(incomeTransaction);
      await addToSavingGoal(goalId, amount);
    } catch (e) {
      print('Error en transferToSavingGoal: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSavingsSummary() async {
    try {
      _checkAuthentication();
      
      final goals = await getSavingGoals();
      
      double totalTarget = 0;
      double totalCurrent = 0;
      int completedGoals = 0;
      int activeGoals = 0;

      for (final goal in goals) {
        totalTarget += goal.targetAmount;
        totalCurrent += goal.currentAmount;
        
        if (goal.currentAmount >= goal.targetAmount) {
          completedGoals++;
        } else {
          activeGoals++;
        }
      }

      final totalProgress = totalTarget > 0 ? totalCurrent / totalTarget : 0.0;

      return {
        'totalGoals': goals.length,
        'completedGoals': completedGoals,
        'activeGoals': activeGoals,
        'totalTarget': totalTarget,
        'totalCurrent': totalCurrent,
        'totalProgress': totalProgress,
        'remainingAmount': totalTarget - totalCurrent,
      };
    } catch (e) {
      print('Error en getSavingsSummary: $e');
      rethrow;
    }
  }

  Future<List<SavingGoal>> getUpcomingGoals() async {
    try {
      _checkAuthentication();
      
      final goals = await getSavingGoals();
      final now = DateTime.now();
      final threshold = now.add(const Duration(days: 30));

      return goals.where((goal) {
        return goal.targetDate.isBefore(threshold) && 
               goal.currentAmount < goal.targetAmount;
      }).toList();
    } catch (e) {
      print('Error en getUpcomingGoals: $e');
      rethrow;
    }
  }

  Future<List<SavingGoal>> getCompletedGoals() async {
    try {
      _checkAuthentication();
      
      final goals = await getSavingGoals();
      return goals.where((goal) => goal.currentAmount >= goal.targetAmount).toList();
    } catch (e) {
      print('Error en getCompletedGoals: $e');
      rethrow;
    }
  }

  Future<void> resetSavingGoal(String goalId) async {
    try {
      _checkAuthentication();
      
      final goal = await getSavingGoal(goalId);
      if (goal == null) throw Exception('Meta no encontrada');

      final resetGoal = goal.copyWith(
        currentAmount: 0,
        createdAt: DateTime.now(),
      );

      await updateSavingGoal(resetGoal);
    } catch (e) {
      print('Error en resetSavingGoal: $e');
      rethrow;
    }
  }

  Future<void> adjustTargetAmount(String goalId, double newTargetAmount) async {
    try {
      _checkAuthentication();
      
      if (newTargetAmount <= 0) {
        throw Exception('El monto objetivo debe ser mayor a cero');
      }

      final goal = await getSavingGoal(goalId);
      if (goal == null) throw Exception('Meta no encontrada');

      final updatedGoal = goal.copyWith(
        targetAmount: newTargetAmount,
      );

      await updateSavingGoal(updatedGoal);
    } catch (e) {
      print('Error en adjustTargetAmount: $e');
      rethrow;
    }
  }

  Future<void> migrateExistingGoals() async {
    try {
      _checkAuthentication();
      final userId = _currentUserId!;

      final querySnapshot = await _savingsCollection
          .where('userId', isNull: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No hay metas para migrar');
        return;
      }

      final batch = FirebaseFirestore.instance.batch();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'userId': userId});
      }

      await batch.commit();
      print('${querySnapshot.docs.length} metas migradas exitosamente para el usuario $userId');
    } catch (e) {
      print('Error migrando metas: $e');
      rethrow;
    }
  }
}