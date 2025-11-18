// widgets/add_transaction_modal.dart
import 'package:flutter/material.dart';
import '../models/transaction.dart';

class AddTransactionModal extends StatefulWidget {
  final Function(Transaction) onTransactionAdded;
  final Function(Transaction)? onTransactionUpdated;
  final Transaction? transactionToEdit;
  final double availableBalance;

  const AddTransactionModal({
    Key? key,
    required this.onTransactionAdded,
    this.onTransactionUpdated,
    this.transactionToEdit,
    this.availableBalance = 0,
  }) : super(key: key);

  @override
  _AddTransactionModalState createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  
  TransactionType _selectedType = TransactionType.GASTO;
  String? _selectedCategory;

  // Categorías organizadas como en las imágenes - SIN DUPLICADOS
  final Map<String, List<String>> _categoriesByType = {
    'INGRESOS': [
      'Salario',
      'Jornada reducida',
      'Ventas',
      'Renta'
    ],
    'GASTOS': [
      'Transporte',
      'Compras',
      'Mascotas',
      'Limpieza',
      'Vestimenta',
      'Zapatos',
      'Salud',
      'Mercado',
      'Vivienda',
      'Cosmético',
      'Higiene'
    ]
  };

  bool get _isEditing => widget.transactionToEdit != null;

  @override
  void initState() {
    super.initState();
    // Establecer categoría por defecto basada en el tipo
    _selectedCategory = _getCurrentCategories().first;
    
    if (_isEditing) {
      _initializeWithTransactionData();
    }
  }

  void _initializeWithTransactionData() {
    final transaction = widget.transactionToEdit!;
    _descriptionController.text = transaction.description;
    _amountController.text = transaction.amount.toStringAsFixed(2);
    _selectedType = transaction.type;
    _selectedCategory = transaction.category;
    
    // Verificar que la categoría exista en la lista actual
    final currentCategories = _getCurrentCategories();
    if (!currentCategories.contains(_selectedCategory)) {
      _selectedCategory = currentCategories.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCategories = _getCurrentCategories();
    
    return Dialog(
      backgroundColor: const Color(0xFF1E1B4B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditing ? 'Editar Transacción' : 'Nueva Transacción',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Indicador de saldo disponible (solo para gastos y no en edición)
            if (_selectedType == TransactionType.GASTO && !_isEditing) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F23),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.availableBalance >= 0 
                        ? const Color(0xFF10B981).withOpacity(0.3)
                        : const Color(0xFFEC4899).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.availableBalance >= 0 ? Icons.info : Icons.warning,
                      color: widget.availableBalance >= 0 
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEC4899),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.availableBalance >= 0 
                                ? 'Saldo disponible'
                                : 'Saldo negativo',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${widget.availableBalance.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: widget.availableBalance >= 0 
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEC4899),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Selector de Tipo (Ingreso/Gasto)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F23),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      TransactionType.INGRESO,
                      'Ingreso',
                      const Color(0xFF10B981),
                    ),
                  ),
                  Expanded(
                    child: _buildTypeButton(
                      TransactionType.GASTO,
                      'Gasto',
                      const Color(0xFFEC4899),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Descripción
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6366F1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                ),
                filled: true,
                fillColor: Color(0xFF0F0F23),
              ),
              style: const TextStyle(color: Colors.white),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Monto
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Monto',
                labelStyle: TextStyle(color: Colors.white70),
                prefixText: '\$',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6366F1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                ),
                filled: true,
                fillColor: Color(0xFF0F0F23),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),

            // Categoría
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6366F1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                ),
                filled: true,
                fillColor: Color(0xFF0F0F23),
              ),
              dropdownColor: const Color(0xFF1E1B4B),
              style: const TextStyle(color: Colors.white),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
              items: currentCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6366F1),
                      side: const BorderSide(color: Color(0xFF6366F1)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isEditing ? 'Actualizar' : 'Agregar',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getCurrentCategories() {
    return _selectedType == TransactionType.INGRESO 
        ? _categoriesByType['INGRESOS']! 
        : _categoriesByType['GASTOS']!;
  }

  Widget _buildTypeButton(TransactionType type, String label, Color color) {
    final isSelected = _selectedType == type;
    
    return GestureDetector(
      onTap: _isEditing ? null : () {
        setState(() {
          _selectedType = type;
          // Resetear categoría basada en el nuevo tipo
          _selectedCategory = _getCurrentCategories().first;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              type == TransactionType.INGRESO ? Icons.arrow_upward : Icons.arrow_downward,
              color: isSelected ? color : Colors.white54,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    final description = _descriptionController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;

    // Validaciones
    if (description.isEmpty) {
      _showErrorSnackbar('Por favor, ingresa una descripción');
      return;
    }

    if (amount <= 0) {
      _showErrorSnackbar('El monto debe ser mayor a cero');
      return;
    }

    if (_selectedCategory == null) {
      _showErrorSnackbar('Por favor, selecciona una categoría');
      return;
    }

    // Validar si es gasto y supera el saldo disponible (solo para nuevos gastos)
    if (!_isEditing && 
        _selectedType == TransactionType.GASTO && 
        amount > widget.availableBalance) {
      _showErrorSnackbar(
        'Saldo insuficiente. Disponible: \$${widget.availableBalance.toStringAsFixed(2)}'
      );
      return;
    }

    // Crear la transacción
    final transaction = Transaction(
      id: _isEditing ? widget.transactionToEdit!.id : null,
      description: description,
      amount: amount,
      date: _isEditing ? widget.transactionToEdit!.date : DateTime.now(),
      category: _selectedCategory!,
      type: _selectedType,
      // savingGoalId se elimina completamente
    );

    // Ejecutar la acción correspondiente
    if (_isEditing) {
      widget.onTransactionUpdated?.call(transaction);
    } else {
      widget.onTransactionAdded(transaction);
    }

    Navigator.pop(context);

    // Mostrar mensaje de confirmación
    _showSuccessSnackbar(
      _isEditing 
        ? 'Transacción actualizada exitosamente'
        : 'Transacción agregada exitosamente'
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEC4899),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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