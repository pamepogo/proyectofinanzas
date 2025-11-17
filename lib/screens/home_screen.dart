// screens/optimized_home_screen.dart
import 'package:flutter/material.dart';
import '../models/transaction.dart' as my_models;
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
  List<my_models.Transaction> _todayTransactions = [];
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

  // ✅ Calcular totales del día
  Map<String, double> _calculateDailyTotals() {
    double totalIncome = 0;
    double totalExpenses = 0;

    for (var transaction in _todayTransactions) {
      if (transaction.type == my_models.TransactionType.INGRESO) {
        totalIncome += transaction.amount;
      } else {
        totalExpenses += transaction.amount;
      }
    }

    return {
      'income': totalIncome,
      'expenses': totalExpenses,
      'balance': totalIncome - totalExpenses,
    };
  }

  // ✅ Validar si hay saldo suficiente para un gasto
  bool _hasSufficientBalance(double expenseAmount) {
    final totals = _calculateDailyTotals();
    final availableBalance = totals['income']! - totals['expenses']!;
    return availableBalance >= expenseAmount;
  }

  // ✅ Mostrar alerta de saldo insuficiente
  void _showInsufficientBalanceAlert(double expenseAmount) {
    final totals = _calculateDailyTotals();
    final availableBalance = totals['income']! - totals['expenses']!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'Saldo Insuficiente',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No puedes agregar este gasto porque supera tu saldo disponible.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            _buildBalanceInfoRow('Gasto intentado:', '-\$${expenseAmount.toStringAsFixed(2)}', Colors.red),
            _buildBalanceInfoRow('Saldo disponible:', '\$${availableBalance.toStringAsFixed(2)}', 
                                availableBalance >= 0 ? Colors.green : Colors.red),
            _buildBalanceInfoRow('Ingresos del día:', '\$${totals['income']!.toStringAsFixed(2)}', Colors.green),
            _buildBalanceInfoRow('Gastos del día:', '-\$${totals['expenses']!.toStringAsFixed(2)}', Colors.red),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Entendido',
              style: TextStyle(color: Color(0xFF6366F1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _addTransaction(my_models.Transaction transaction) async {
    try {
      // Validar si es un gasto y supera el saldo disponible
      if (transaction.type == my_models.TransactionType.GASTO && 
          !_hasSufficientBalance(transaction.amount)) {
        _showInsufficientBalanceAlert(transaction.amount);
        return;
      }

      await _transactionService.addTransaction(transaction);
      await _refreshData();
      
      _showSuccessSnackbar('Transacción agregada exitosamente');
    } catch (e) {
      print('Error en _addTransaction: $e');
      _showErrorSnackbar('Error agregando transacción: $e');
      rethrow;
    }
  }

  Future<void> _updateTransaction(my_models.Transaction transaction) async {
    try {
      // Validar si es un gasto y supera el saldo disponible
      if (transaction.type == my_models.TransactionType.GASTO) {
        // Para edición, necesitamos excluir el gasto original del cálculo
        final originalTransaction = _todayTransactions.firstWhere(
          (t) => t.id == transaction.id,
          orElse: () => transaction,
        );
        
        final totalsWithoutOriginal = _calculateTotalsWithoutTransaction(originalTransaction);
        final availableBalance = totalsWithoutOriginal['income']! - totalsWithoutOriginal['expenses']!;
        
        if (transaction.amount > availableBalance) {
          _showInsufficientBalanceAlert(transaction.amount);
          return;
        }
      }

      await _transactionService.updateTransaction(transaction);
      await _refreshData();
      _showSuccessSnackbar('Transacción actualizada exitosamente');
    } catch (e) {
      print('Error en _updateTransaction: $e');
      _showErrorSnackbar('Error actualizando transacción: $e');
      rethrow;
    }
  }

  // ✅ Calcular totales excluyendo una transacción específica (para edición)
  Map<String, double> _calculateTotalsWithoutTransaction(my_models.Transaction transactionToExclude) {
    double totalIncome = 0;
    double totalExpenses = 0;

    for (var transaction in _todayTransactions) {
      if (transaction.id == transactionToExclude.id) continue;
      
      if (transaction.type == my_models.TransactionType.INGRESO) {
        totalIncome += transaction.amount;
      } else {
        totalExpenses += transaction.amount;
      }
    }

    return {
      'income': totalIncome,
      'expenses': totalExpenses,
      'balance': totalIncome - totalExpenses,
    };
  }

  Future<void> _deleteTransaction(my_models.Transaction transaction) async {
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
    final totals = _calculateDailyTotals();
    final availableBalance = totals['income']! - totals['expenses']!;
    
    showDialog(
      context: context,
      builder: (context) => AddTransactionModal(
        onTransactionAdded: _addTransaction,
        availableBalance: availableBalance, 
      ),
    ).then((_) {
      _refreshData();
    });
  }

  void _showEditTransactionModal(my_models.Transaction transaction) {
    final totalsWithoutOriginal = _calculateTotalsWithoutTransaction(transaction);
    // ignore: unused_local_variable
    final availableBalance = totalsWithoutOriginal['income']! - totalsWithoutOriginal['expenses']!;
    
    showDialog(
      context: context,
      builder: (context) => AddTransactionModal(
        onTransactionAdded: _addTransaction,
        onTransactionUpdated: _updateTransaction,
      ),
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
    final dailyTotals = _calculateDailyTotals();
    final availableBalance = dailyTotals['income']! - dailyTotals['expenses']!;

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
            : Column(
                children: [
                  // Resumen del día
                  _buildDailySummary(dailyTotals, availableBalance),
                  const SizedBox(height: 8),
                  
                  // Lista de transacciones
                  Expanded(
                    child: _todayTransactions.isEmpty
                        ? _buildEmptyState()
                        : ExpenseList(
                            transactions: _todayTransactions,
                            onDismissed: _deleteTransaction,
                            onEdit: _showEditTransactionModal,
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionModal,
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDailySummary(Map<String, double> totals, double availableBalance) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: availableBalance < 0 
              ? Colors.red.withOpacity(0.5)
              : const Color(0xFF6366F1).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Resumen del Día',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (availableBalance < 0) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Saldo negativo - Controla tus gastos',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Ingresos',
                totals['income']!,
                Colors.green,
                Icons.arrow_upward,
              ),
              _buildSummaryItem(
                'Gastos',
                totals['expenses']!,
                Colors.red,
                Icons.arrow_downward,
              ),
              _buildSummaryItem(
                'Disponible',
                availableBalance,
                availableBalance >= 0 ? Colors.blue : Colors.orange,
                availableBalance >= 0 ? Icons.account_balance_wallet : Icons.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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