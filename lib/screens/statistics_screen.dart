import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/weekly_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final ExpenseService _expenseService = ExpenseService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final transactions = await _expenseService.getTransactions();
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error cargando estadísticas: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Transaction> get _weeklyTransactions {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return _transactions
        .where((transaction) => transaction.date
            .isAfter(startOfWeek.subtract(const Duration(days: 1))))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(
        currentRoute: '/statistics',
      ),
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        title: const Text(
          'Estadísticas',
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
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildIncomeExpenseChart(),
              ),
            ),
    );
  }

  Widget _buildIncomeExpenseChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gastos vs Ingresos de la Semana',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Gráfico semanal
          WeeklyChart(transactions: _weeklyTransactions),
        ],
      ),
    );
  }
}