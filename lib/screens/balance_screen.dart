import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../widgets/custom_drawer.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({Key? key}) : super(key: key);

  @override
  _BalanceScreenState createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  final ExpenseService _expenseService = ExpenseService();
  List<Transaction> _transactions = [];
  Map<String, double> _totals = {'ingresos': 0, 'gastos': 0, 'balance': 0};
  Map<String, double> _monthlyData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final transactions = await _expenseService.getTransactions();
      final totals = await _expenseService.getTotals();
      final monthlyData = await _calculateMonthlyData(transactions);
      
      setState(() {
        _transactions = transactions;
        _totals = totals;
        _monthlyData = monthlyData;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error cargando datos de balance: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, double>> _calculateMonthlyData(List<Transaction> transactions) async {
    Map<String, double> monthly = {};
    
    // Inicializar todos los meses del año actual
    final now = DateTime.now();
    for (int i = 1; i <= 12; i++) {
      final monthKey = '${now.year}-${i.toString().padLeft(2, '0')}';
      monthly[monthKey] = 0.0;
    }
    
    // Calcular balance por mes
    for (var transaction in transactions) {
      final monthKey = '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
      if (monthly.containsKey(monthKey)) {
        monthly[monthKey] = monthly[monthKey]! + transaction.signedAmount;
      }
    }
    
    return monthly;
  }

  String _getMonthName(String monthKey) {
    final months = {
      '01': 'Ene', '02': 'Feb', '03': 'Mar', '04': 'Abr',
      '05': 'May', '06': 'Jun', '07': 'Jul', '08': 'Ago',
      '09': 'Sep', '10': 'Oct', '11': 'Nov', '12': 'Dic'
    };
    return months[monthKey.split('-')[1]] ?? monthKey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        currentRoute: '/balance',
      ),
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        title: const Text('Balance General'),
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
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🎯 RESUMEN PRINCIPAL
                  _buildMainSummary(),
                  const SizedBox(height: 24),
                  
                  // 📈 BALANCE ANUAL
                  _buildAnnualBalance(),
                  const SizedBox(height: 24),
                  
                  // 📊 ESTADÍSTICAS POR CATEGORÍA
                  _buildCategoryStats(),
                  const SizedBox(height: 24),
                  
                  // 📅 ÚLTIMAS TRANSACCIONES
                  _buildRecentTransactions(),
                ],
              ),
            ),
    );
  }

  Widget _buildMainSummary() {
    final isPositive = _totals['balance']! >= 0;
    final primaryColor = isPositive ? const Color(0xFF10B981) : const Color(0xFFEC4899);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.15),
            primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Balance General',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '\$${_totals['balance']!.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          Text(
            isPositive ? 'Superávit' : 'Déficit',
            style: TextStyle(
              fontSize: 16,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Ingresos', _totals['ingresos']!, const Color(0xFF10B981), Icons.arrow_upward),
              _buildSummaryItem('Gastos', _totals['gastos']!, const Color(0xFFEC4899), Icons.arrow_downward),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAnnualBalance() {
    final monthlyEntries = _monthlyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E1B4B),
            Color(0xFF0F0F23),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Balance Anual',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tendencias mensuales',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(const Color(0xFF6366F1).withOpacity(0.2)),
              dataRowColor: MaterialStateProperty.all(Colors.transparent),
              columns: const [
                DataColumn(label: Text('Mes', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1)))),
                DataColumn(label: Text('Ingresos', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)))),
                DataColumn(label: Text('Gastos', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEC4899)))),
                DataColumn(label: Text('Balance', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1)))),
              ],
              rows: monthlyEntries.map((entry) {
                final monthTransactions = _transactions.where((t) {
                  final tMonthKey = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
                  return tMonthKey == entry.key;
                }).toList();
                
                double ingresos = monthTransactions
                    .where((t) => t.type == TransactionType.INGRESO)
                    .fold(0, (sum, t) => sum + t.amount);
                
                double gastos = monthTransactions
                    .where((t) => t.type == TransactionType.GASTO)
                    .fold(0, (sum, t) => sum + t.amount);
                
                double balance = ingresos - gastos;
                
                return DataRow(cells: [
                  DataCell(Text(
                    _getMonthName(entry.key),
                    style: const TextStyle(color: Colors.white),
                  )),
                  DataCell(Text(
                    '\$${ingresos.toStringAsFixed(2)}',
                    style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                  )),
                  DataCell(Text(
                    '\$${gastos.toStringAsFixed(2)}',
                    style: const TextStyle(color: Color(0xFFEC4899), fontWeight: FontWeight.bold),
                  )),
                  DataCell(Text(
                    '\$${balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: balance >= 0 ? const Color(0xFF10B981) : const Color(0xFFEC4899),
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStats() {
    // Calcular totales por categoría
    Map<String, double> categoryTotals = {};
    
    for (var transaction in _transactions) {
      categoryTotals.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }
    
    final categoryEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E1B4B),
            Color(0xFF0F0F23),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gastos por Categoría',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...categoryEntries.take(6).map((entry) => _buildCategoryItem(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String category, double amount) {
    final percentage = (_totals['gastos']! > 0) ? (amount / _totals['gastos']! * 100) : 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              category,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final recentTransactions = _transactions.take(5).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E1B4B),
            Color(0xFF0F0F23),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF06B6D4).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Últimas Transacciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...recentTransactions.map((transaction) => _buildTransactionItem(transaction)),
          if (recentTransactions.isEmpty)
            Center(
              child: Text(
                'No hay transacciones recientes',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isIncome = transaction.type == TransactionType.INGRESO;
    final color = isIncome ? const Color(0xFF10B981) : const Color(0xFFEC4899);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              transaction.typeIcon,
              style: TextStyle(
                fontSize: 16,
                color: color,
              ),
            ),
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
        subtitle: Text(
          '${transaction.category} • ${_formatDate(transaction.date)}',
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        trailing: Text(
          isIncome
              ? '+\$${transaction.amount.toStringAsFixed(2)}'
              : '-\$${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}