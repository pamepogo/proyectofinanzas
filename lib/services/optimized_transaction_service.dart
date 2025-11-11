// services/optimized_transaction_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction.dart' as my_models;

class OptimizedTransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'transactions';

  List<my_models.Transaction>? _cachedTransactions;
  DateTime? _lastFetchTime;

  // ✅ CONSULTA SIMPLE - Sin índices compuestos
  Future<List<my_models.Transaction>> getTransactionsAsFuture() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final now = DateTime.now();
    
    if (_cachedTransactions != null && 
        _lastFetchTime != null && 
        now.difference(_lastFetchTime!).inMinutes < 5) {
      return _cachedTransactions!;
    }

    try {
      // SOLO filtrar por usuario - Firestore puede manejar esto sin índice
      final querySnapshot = await _firestore
          .collection(_collectionPath)
          .where('userId', isEqualTo: user.uid)
          .get();

      // Ordenar en memoria (más eficiente que índice compuesto)
      final transactions = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return my_models.Transaction(
          id: doc.id,
          amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
          description: data['description'] as String? ?? '',
          category: data['category'] as String? ?? '',
          date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
          type: data['type'] == 'INGRESO' 
              ? my_models.TransactionType.INGRESO 
              : my_models.TransactionType.GASTO,
        );
      }).toList();

      // ORDENAR EN MEMORIA por fecha (más rápido que índice)
      transactions.sort((a, b) => b.date.compareTo(a.date));

      _cachedTransactions = transactions;
      _lastFetchTime = now;

      return transactions;
    } catch (e) {
      print('Error fetching transactions: $e');
      return _cachedTransactions ?? [];
    }
  }

  // ✅ CONSULTA SIMPLE para transacciones de hoy
  Future<List<my_models.Transaction>> getTodayTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      // Primero obtener todas las transacciones del usuario
      final allTransactions = await getTransactionsAsFuture();
      
      // Filtrar en memoria por fecha de hoy
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      return allTransactions.where((transaction) {
        return transaction.date.isAfter(startOfDay) && 
               transaction.date.isBefore(endOfDay);
      }).toList();
    } catch (e) {
      print('Error fetching today transactions: $e');
      return [];
    }
  }

  // ✅ STREAM simple
  Stream<List<my_models.Transaction>> getTransactionsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final transactions = snapshot.docs.map((doc) {
            final data = doc.data();
            return my_models.Transaction(
              id: doc.id,
              amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
              description: data['description'] as String? ?? '',
              category: data['category'] as String? ?? '',
              date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
              type: data['type'] == 'INGRESO' 
                  ? my_models.TransactionType.INGRESO 
                  : my_models.TransactionType.GASTO,
            );
          }).toList();
          
          // Ordenar en memoria
          transactions.sort((a, b) => b.date.compareTo(a.date));
          return transactions;
        });
  }

  // ✅ AGREGAR transacción
  Future<void> addTransaction(my_models.Transaction transaction) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');
      
      await _firestore.collection(_collectionPath).add({
        'amount': transaction.amount,
        'description': transaction.description,
        'category': transaction.category,
        'date': Timestamp.fromDate(transaction.date),
        'type': transaction.type == my_models.TransactionType.INGRESO ? 'INGRESO' : 'GASTO',
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      clearCache();
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  // ✅ ELIMINAR transacción
  Future<void> deleteTransaction(String id) async {
    try {
      await _firestore.collection(_collectionPath).doc(id).delete();
      clearCache();
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  void clearCache() {
    _cachedTransactions = null;
    _lastFetchTime = null;
  }
}