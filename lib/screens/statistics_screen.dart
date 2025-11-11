// screens/optimized_statistics_screen.dart
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/optimized_transaction_service.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/weekly_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final OptimizedTransactionService _transactionService = OptimizedTransactionService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final transactions = await _transactionService.getTransactionsAsFuture();
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
      
      // DEBUG: Verificar datos
      print('📊 Total transacciones cargadas: ${_transactions.length}');
      print('📅 Rango de fechas:');
      if (_transactions.isNotEmpty) {
        _transactions.sort((a, b) => a.date.compareTo(b.date));
        print('   Más antigua: ${_transactions.first.date}');
        print('   Más reciente: ${_transactions.last.date}');
      }
      
    } catch (e) {
      print('Error cargando estadísticas: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Error cargando estadísticas: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    _transactionService.clearCache();
    await _loadData();
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoading()
          : WeeklyChart(transactions: _transactions), // ✅ Usar directamente WeeklyChart
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
            'Cargando estadísticas...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}