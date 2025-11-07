import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/category_service.dart';

class AddTransactionModal extends StatefulWidget {
  final Function(Transaction) onTransactionAdded;

  const AddTransactionModal({Key? key, required this.onTransactionAdded}) : super(key: key);

  @override
  _AddTransactionModalState createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  TransactionType _selectedType = TransactionType.GASTO;
  String _selectedCategory = 'Comida';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateCategories();
  }

  void _updateCategories() {
    setState(() {
      _selectedCategory = CategoryService.getCategoriesByType(_selectedType).first;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _selectedType == TransactionType.INGRESO;
    final primaryColor = isIncome ? const Color(0xFF10B981) : const Color(0xFF6366F1);
    
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 550),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Nueva Transacción',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Registra tu transacción',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTypeButton(TransactionType.INGRESO, 'Ingreso', Color(0xFF10B981)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTypeButton(TransactionType.GASTO, 'Gasto', Color(0xFF6366F1)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            style: const TextStyle(color: Colors.black, fontSize: 16),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                              });
                            },
                            items: CategoryService.getCategoriesByType(_selectedType)
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    Text(CategoryService.getCategoryIcon(value)),
                                    const SizedBox(width: 8),
                                    Text(value),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: isIncome 
                              ? 'Descripción del ingreso' 
                              : '¿En qué gastaste?',
                          hintText: isIncome
                              ? 'Ej: Salario, Venta...'
                              : 'Ej: Almuerzo, Transporte...',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          isDense: true,
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Describe la transacción';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Monto',
                          hintText: '0.00',
                          prefixText: '\$ ',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa el monto';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Monto válido';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _addTransaction(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            side: BorderSide(color: Colors.grey[400]!),
                          ),
                          child: const Text('Cancelar', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _addTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            isIncome ? 'Agregar Ingreso' : 'Agregar Gasto',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(TransactionType type, String text, Color color) {
    bool isSelected = _selectedType == type;
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _selectedType = type;
          _updateCategories();
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        side: BorderSide(color: isSelected ? color : Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? color : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Future<void> _addTransaction() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final transaction = Transaction(
          description: _descriptionController.text.trim(),
          amount: double.parse(_amountController.text),
          date: DateTime.now(),
          category: _selectedCategory,
          type: _selectedType,
        );
        
        await widget.onTransactionAdded(transaction);
        
        if (mounted) {
          Navigator.pop(context);
          _showSuccessMessage();
        }
      } catch (e) {
        if (mounted) {
          _showErrorMessage('Error al guardar: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showSuccessMessage() {
    String message = _selectedType == TransactionType.INGRESO
        ? '✅ Ingreso agregado correctamente'
        : '✅ Gasto agregado correctamente';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _selectedType == TransactionType.INGRESO ? Color(0xFF10B981) : Color(0xFF6366F1),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $message'),
        backgroundColor: Color(0xFFEC4899),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}