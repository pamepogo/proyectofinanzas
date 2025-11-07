import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../widgets/expense_list.dart';
import '../widgets/add_transaction_modal.dart';
import '../widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExpenseService _expenseService = ExpenseService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    await _loadTransactions();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await _expenseService.getTransactions();
      setState(() {
        _transactions = transactions;
      });
    } catch (e) {
      print('❌ Error cargando transacciones: $e');
    }
  }

  Future<void> _addTransaction(Transaction transaction) async {
    try {
      await _expenseService.addTransaction(transaction);
      await _loadTransactions();
    } catch (e) {
      print('❌ Error en _addTransaction: $e');
      rethrow;
    }
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    try {
      await _expenseService.deleteTransaction(transaction.id!);
      await _loadTransactions();
    } catch (e) {
      print('❌ Error eliminando transacción: $e');
    }
  }

  void _showAddTransactionModal() {
    showDialog(
      context: context,
      builder: (context) =>
          AddTransactionModal(onTransactionAdded: _addTransaction),
    ).then((_) {
      _loadTransactions();
    });
  }

  List<Transaction> get _todayTransactions {
    final today = DateTime.now();
    return _transactions
        .where((transaction) =>
            transaction.date.year == today.year &&
            transaction.date.month == today.month &&
            transaction.date.day == today.day)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      drawer: CustomDrawer(
        currentRoute: '/home',
        onHomeSelected: () {
          // Ya estamos en home, solo cerramos el drawer
        },
        onStatisticsSelected: () {
          // Navegar a estadísticas - AHORA FUNCIONAL
          Navigator.pop(context); // Cerrar drawer primero
          Navigator.pushNamed(context, '/statistics');
        },
        onBalanceSelected: () {
          Navigator.pop(context); // Cerrar drawer primero
          Navigator.pushNamed(context, '/balance');
        },
        onSavingsSelected: () {
          Navigator.pop(context); // Cerrar drawer primero
          Navigator.pushNamed(context, '/savings');
        },
        onLogoutSelected: _logout,
      ),
      appBar: AppBar(
        title: const Text(
          'PLANIFICASH',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadTransactions(),
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            )
          : Container(
              color: const Color(0xFF0F0F23),
              child: ExpenseList(
                transactions: _todayTransactions,
                onDismissed: _deleteTransaction,
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionModal,
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      // ELIMINADO: Bottom Navigation Bar
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF6366F1)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Color(0xFFEC4899)),
            ),
          ),
        ],
      ),
    );
  }
}