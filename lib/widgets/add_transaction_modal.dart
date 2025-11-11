import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/saving_goal.dart';
import '../services/saving_service.dart';

class AddTransactionModal extends StatefulWidget {
  final Function(Transaction) onTransactionAdded;
  final SavingService? savingService;

  const AddTransactionModal({
    Key? key,
    required this.onTransactionAdded,
    this.savingService,
  }) : super(key: key);

  @override
  _AddTransactionModalState createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  
  TransactionType _selectedType = TransactionType.GASTO;
  String _selectedCategory = 'Compras';
  String? _selectedSavingGoalId;
  List<SavingGoal> _savingGoals = [];
  bool _isLoadingGoals = false;

  // Categorías organizadas como en las imágenes
  final Map<String, List<String>> _categoriesByType = {
    'INGRESOS': [
      'Salario',
      'Jornada reducida',
      'Efectivo',
      'Otros'
    ],
    'GASTOS': [
      'Transporte',
      'Compras',
      'Mascota',
      'Social',
      'Verduras',
      'Frutas',
      'Aperitivos',
      'Entretenimiento',
      'Vivienda',
      'Cosmético',
    ]
  };

  @override
  void initState() {
    super.initState();
    _loadSavingGoals();
  }

  Future<void> _loadSavingGoals() async {
    if (widget.savingService == null) return;
    
    setState(() {
      _isLoadingGoals = true;
    });

    try {
      final goals = await widget.savingService!.getSavingGoals();
      setState(() {
        _savingGoals = goals;
        _isLoadingGoals = false;
      });
    } catch (e) {
      print('Error cargando metas de ahorro: $e');
      setState(() {
        _isLoadingGoals = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            const Text(
              'Nueva Transacción',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

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
              ),
              style: const TextStyle(color: Colors.white),
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
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),

            // Categoría COMO DROPDOWN
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Categoría',
                labelStyle: const TextStyle(color: Colors.white70),
                border: const OutlineInputBorder(),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6366F1)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                ),
                filled: true,
                fillColor: const Color(0xFF0F0F23),
              ),
              dropdownColor: const Color(0xFF1E1B4B),
              style: const TextStyle(color: Colors.white),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
              items: _getCurrentCategories().map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Selector de Meta de Ahorro (solo para ingresos) - COMO DROPDOWN
            if (_selectedType == TransactionType.INGRESO && widget.savingService != null) ...[
              _isLoadingGoals
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                    )
                  : DropdownButtonFormField<String>(
                      value: _selectedSavingGoalId,
                      decoration: InputDecoration(
                        labelText: 'Asignar a meta de ahorro',
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF6366F1)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0F0F23),
                      ),
                      dropdownColor: const Color(0xFF1E1B4B),
                      style: const TextStyle(color: Colors.white),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(
                            'No asignar',
                            style: TextStyle(
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        ..._savingGoals.map((goal) {
                          return DropdownMenuItem(
                            value: goal.id,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  goal.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Progreso: \$${goal.currentAmount.toStringAsFixed(0)} / \$${goal.targetAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedSavingGoalId = value;
                        });
                      },
                    ),
              const SizedBox(height: 8),
              if (_savingGoals.isEmpty && !_isLoadingGoals)
                const Text(
                  'No tienes metas de ahorro. Crea una en la pantalla de Ahorro.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              const SizedBox(height: 16),
            ],

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6366F1),
                      side: const BorderSide(color: Color(0xFF6366F1)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Agregar'),
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
      onTap: () {
        setState(() {
          _selectedType = type;
          // Resetear categoría y selección de meta si cambia el tipo
          _selectedCategory = _getCurrentCategories().first;
          if (type == TransactionType.GASTO) {
            _selectedSavingGoalId = null;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTransaction() {
    final description = _descriptionController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;

    if (description.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos'),
          backgroundColor: Color(0xFFEC4899),
        ),
      );
      return;
    }

    final transaction = Transaction(
      description: description,
      amount: amount,
      date: DateTime.now(),
      category: _selectedCategory,
      type: _selectedType,
      savingGoalId: _selectedSavingGoalId,
    );

    widget.onTransactionAdded(transaction);
    Navigator.pop(context);

    // Mostrar mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedSavingGoalId != null 
            ? 'Transacción agregada y asignada a meta de ahorro'
            : 'Transacción agregada exitosamente',
        ),
        backgroundColor: const Color(0xFF10B981),
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