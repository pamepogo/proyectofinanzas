// screens/optimized_home_screen.dart
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/optimized_transaction_service.dart';
import '../widgets/expense_list.dart';
import '../widgets/add_transaction_modal.dart';
import '../widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final OptimizedTransactionService _transactionService = OptimizedTransactionService();
  List<Transaction> _todayTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayTransactions();
  }

  // ✅ Solo cargar transacciones del día
  Future<void> _loadTodayTransactions() async {
    try {
      final transactions = await _transactionService.getTodayTransactions();
      setState(() {
        _todayTransactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando transacciones de hoy: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Error cargando transacciones: $e');
    }
  }

  // ✅ Refresh más rápido
  Future<void> _refreshData() async {
    _transactionService.clearCache(); // Limpiar cache
    await _loadTodayTransactions();
  }

  Future<void> _addTransaction(Transaction transaction) async {
    try {
      await _transactionService.addTransaction(transaction);
      await _refreshData(); // Usar refresh que incluye clear cache
      
      _showSuccessSnackbar('Transacción agregada exitosamente');
    } catch (e) {
      print('Error en _addTransaction: $e');
      _showErrorSnackbar('Error agregando transacción: $e');
      rethrow;
    }
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    try {
      if (transaction.id != null) {
        await _transactionService.deleteTransaction(transaction.id!);
        await _refreshData();
        
        _showSuccessSnackbar('Transacción eliminada');
      } else {
        _showErrorSnackbar('No se puede eliminar: ID no disponible');
      }
    } catch (e) {
      print('Error eliminando transacción: $e');
      _showErrorSnackbar('Error eliminando transacción: $e');
    }
  }

  void _showAddTransactionModal() {
    showDialog(
      context: context,
      builder: (context) =>
          AddTransactionModal(onTransactionAdded: _addTransaction),
    ).then((_) {
      _refreshData();
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
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
          Navigator.pop(context);
          Navigator.pushNamed(context, '/statistics');
        },
        onBalanceSelected: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/balance');
        },
        onSavingsSelected: () {
          Navigator.pop(context);
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
            onPressed: _refreshData,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        backgroundColor: const Color(0xFF6366F1),
        color: Colors.white,
        child: _isLoading
            ? _buildLoading()
            : _todayTransactions.isEmpty
                ? _buildEmptyState()
                : ExpenseList(
                    transactions: _todayTransactions,
                    onDismissed: _deleteTransaction,
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionModal,
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando transacciones...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey[600],
          ),
          SizedBox(height: 16),
          Text(
            'No hay transacciones hoy',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Agrega tu primera transacción',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _showAddTransactionModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: Text('Agregar Transacción'),
          ),
        ],
      ),
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