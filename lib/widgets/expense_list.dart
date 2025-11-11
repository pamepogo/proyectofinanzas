import 'package:flutter/material.dart';
import '../models/transaction.dart';

class ExpenseList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(Transaction) onDismissed;

  const ExpenseList({
    Key? key,
    required this.transactions,
    required this.onDismissed,
  }) : super(key: key);

  Map<String, double> get totals {
    double ingresos = 0;
    double gastos = 0;
    
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.INGRESO) {
        ingresos += transaction.amount;
      } else {
        gastos += transaction.amount;
      }
    }
    
    return {
      'ingresos': ingresos,
      'gastos': gastos,
      'balance': ingresos - gastos,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = totals['balance']! >= 0;
    final primaryColor = isPositive ? const Color(0xFF10B981) : const Color(0xFFEC4899);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
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
                'Saldo Actual',
                style: TextStyle(
                  fontSize: 16,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${totals['balance']!.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTotalItem('Ingresos', totals['ingresos']!, const Color(0xFF10B981)),
                  _buildTotalItem('Gastos', totals['gastos']!, const Color(0xFFEC4899)),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay transacciones',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const Text(
                        'Toca el botón + para agregar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final isIncome = transaction.type == TransactionType.INGRESO;
                    final color = isIncome ? const Color(0xFF10B981) : const Color(0xFFEC4899);
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Dismissible(
                        key: Key(transaction.id.toString()),
                        background: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEC4899),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) => onDismissed(transaction),
                        child: Card(
                          color: const Color(0xFF1E1B4B),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: color.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
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
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              '${transaction.category} • ${transaction.date.hour}:${transaction.date.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  isIncome 
                                      ? '+\$${transaction.amount.toStringAsFixed(2)}'
                                      : '-\$${transaction.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: color,
                                  ),
                                ),
                                Text(
                                  isIncome ? 'Ingreso' : 'Gasto',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTotalItem(String label, double amount, Color color) {
    return Column(
      children: [
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
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}