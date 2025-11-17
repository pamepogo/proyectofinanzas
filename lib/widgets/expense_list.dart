// widgets/expense_list.dart - Actualiza tu widget existente
import 'package:flutter/material.dart';
import '../models/transaction.dart';

class ExpenseList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(Transaction) onDismissed;
  final Function(Transaction) onEdit; // Nueva propiedad para editar

  const ExpenseList({
    Key? key,
    required this.transactions,
    required this.onDismissed,
    required this.onEdit, // Agrega esta línea
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Dismissible(
          key: Key(transaction.id ?? '${transaction.amount}-${DateTime.now()}'),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.blue,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.edit, color: Colors.white),
                SizedBox(width: 8),
                Text('Editar', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              // Editar - no necesitamos confirmación para dismiss
              onEdit(transaction);
              return false; // No eliminar el item
            } else {
              // Eliminar - pedir confirmación
              return await _showDeleteConfirmation(context, transaction.description);
            }
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              onDismissed(transaction);
            }
          },
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Color(0xFF1E1B4B),
            child: ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor(transaction.category),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(transaction.category),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                transaction.description,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${transaction.category} • ${_formatTime(transaction.date)}',
                style: TextStyle(color: Colors.white70),
              ),
              trailing: Text(
                '${transaction.type == TransactionType.INGRESO ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: transaction.type == TransactionType.INGRESO 
                      ? Colors.green 
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                // Tocar para editar
                onEdit(transaction);
              },
            ),
          ),
        );
      },
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, String description) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1B4B),
        title: Text(
          'Eliminar Transacción',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar "$description"?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF6366F1)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Comida': Colors.orange,
      'Transporte': Colors.blue,
      'Compras': Colors.purple,
      'Mascota': Colors.brown,
      'Social': Colors.pink,
      'Verduras': Colors.green,
      'Frutas': Colors.lightGreen,
      'Aperitivos': Colors.amber,
      'Entretenimiento': Colors.deepPurple,
      'Vivienda': Colors.indigo,
      'Cosmético': Colors.purpleAccent,
      'Salario': Colors.green,
      'Jornada reducida': Colors.lightGreen,
      'Efectivo': Colors.teal,
      'Otros': Colors.grey,
    };
    return colors[category] ?? Color(0xFF6366F1);
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Comida': Icons.restaurant,
      'Transporte': Icons.directions_car,
      'Compras': Icons.shopping_cart,
      'Mascota': Icons.pets,
      'Social': Icons.people,
      'Verduras': Icons.eco,
      'Frutas': Icons.apple,
      'Aperitivos': Icons.fastfood,
      'Entretenimiento': Icons.movie,
      'Vivienda': Icons.home,
      'Cosmético': Icons.spa,
      'Salario': Icons.work,
      'Jornada reducida': Icons.schedule,
      'Efectivo': Icons.attach_money,
      'Otros': Icons.category,
    };
    return icons[category] ?? Icons.receipt;
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}