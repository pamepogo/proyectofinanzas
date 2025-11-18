import 'package:flutter/material.dart';
import '../models/saving_goal.dart';
import '../services/saving_service.dart';
import '../services/optimized_transaction_service.dart';
import '../widgets/custom_drawer.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({Key? key}) : super(key: key);

  @override
  _SavingsScreenState createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final OptimizedTransactionService _transactionService = OptimizedTransactionService();
  late final SavingService _savingService;
  List<SavingGoal> _savingGoals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _savingService = SavingService(_transactionService);
    _loadSavingGoals();
  }

  Future<void> _loadSavingGoals() async {
    try {
      final goals = await _savingService.getSavingGoals();
      setState(() {
        _savingGoals = goals;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando metas de ahorro: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Error cargando metas: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    _transactionService.clearCache();
    await _loadSavingGoals();
  }

  Future<void> _addSavingGoal(SavingGoal goal) async {
    try {
      await _savingService.createSavingGoal(goal);
      await _refreshData();
      
      _showSuccessSnackbar('Meta "${goal.name}" creada exitosamente');
    } catch (e) {
      print('Error creando meta: $e');
      _showErrorSnackbar('Error creando meta: $e');
    }
  }

  Future<void> _updateSavingGoal(SavingGoal goal) async {
    try {
      await _savingService.updateSavingGoal(goal);
      await _refreshData();
      
      _showSuccessSnackbar('Meta "${goal.name}" actualizada');
    } catch (e) {
      print('Error actualizando meta: $e');
      _showErrorSnackbar('Error actualizando meta: $e');
    }
  }

  Future<void> _addToSavingGoal(SavingGoal goal, double amount) async {
    try {
      await _savingService.addToSavingGoal(goal.id!, amount);
      await _refreshData();
      
      _showSuccessSnackbar('\$${amount.toStringAsFixed(2)} agregado a ${goal.name}');
    } catch (e) {
      print('Error agregando dinero: $e');
      _showErrorSnackbar('Error agregando dinero: $e');
    }
  }

  Future<void> _withdrawFromSavingGoal(SavingGoal goal, double amount) async {
    try {
      await _savingService.withdrawFromSavingGoal(goal.id!, amount);
      await _refreshData();
      
      _showSuccessSnackbar('\$${amount.toStringAsFixed(2)} retirado de ${goal.name}');
    } catch (e) {
      print('Error retirando dinero: $e');
      _showErrorSnackbar('Error retirando dinero: $e');
    }
  }

  Future<void> _deleteSavingGoal(SavingGoal goal) async {
    try {
      await _savingService.deleteSavingGoal(goal.id!);
      await _refreshData();
      
      _showSuccessSnackbar('Meta "${goal.name}" eliminada');
    } catch (e) {
      print('Error eliminando meta: $e');
      _showErrorSnackbar('Error eliminando meta: $e');
    }
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

  void _showAddMoneyDialog(SavingGoal goal) {
    final amountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        title: Text(
          'Agregar a ${goal.name}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Meta: \$${goal.targetAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ahorrado: \$${goal.currentAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad a ahorrar',
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
            const SizedBox(height: 8),
            Text(
              'Faltan: \$${(goal.targetAmount - goal.currentAmount).toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 12,
              ),
            ),
          ],
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
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                _addToSavingGoal(goal, amount);
                Navigator.pop(context);
              } else {
                _showErrorSnackbar('Ingresa una cantidad válida mayor a cero');
              }
            },
            child: const Text(
              'Ahorrar',
              style: TextStyle(color: Color(0xFF10B981)),
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(SavingGoal goal) {
    final amountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        title: Text(
          'Retirar de ${goal.name}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ahorro actual: \$${goal.currentAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '⚠️ Solo retira si realmente lo necesitas',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad a retirar',
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
          ],
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
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                if (amount <= goal.currentAmount) {
                  _withdrawFromSavingGoal(goal, amount);
                  Navigator.pop(context);
                } else {
                  _showErrorSnackbar('No puedes retirar más de lo que tienes ahorrado');
                }
              } else {
                _showErrorSnackbar('Ingresa una cantidad válida mayor a cero');
              }
            },
            child: const Text(
              'Retirar',
              style: TextStyle(color: Color(0xFFEC4899)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(
        currentRoute: '/savings',
      ),
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        title: const Text(
          'Mis Metas de Ahorro',
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
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        backgroundColor: const Color(0xFF6366F1),
        color: Colors.white,
        child: _isLoading
            ? _buildLoading()
            : _savingGoals.isEmpty
                ? _buildEmptyState()
                : _buildGoalsList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
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
            'Cargando metas...',
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
            Icons.savings,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 20),
          const Text(
            'No tienes metas de ahorro',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Presiona el botón + para crear tu primera meta',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savingGoals.length,
      itemBuilder: (context, index) {
        final goal = _savingGoals[index];
        return _buildGoalCard(goal);
      },
    );
  }

  Widget _buildGoalCard(SavingGoal goal) {
    final progress = goal.targetAmount > 0 ? goal.currentAmount / goal.targetAmount : 0.0;
    final daysRemaining = goal.targetDate.difference(DateTime.now()).inDays;
    final isCompleted = goal.currentAmount >= goal.targetAmount;
    final remainingAmount = goal.targetAmount - goal.currentAmount;

    return Card(
      color: const Color(0xFF1E1B4B),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  goal.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        goal.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? const Color(0xFF10B981) : const Color(0xFF6366F1)
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ahorrado: \$${goal.currentAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                      ),
                    ),
                    if (remainingAmount > 0)
                      Text(
                        'Faltan: \$${remainingAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                  ],
                ),
                Text(
                  'Meta: \$${goal.targetAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress * 100).toStringAsFixed(1)}% completado • ${daysRemaining.clamp(0, 365)} días restantes',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white60,
              ),
            ),
            
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showAddMoneyDialog(goal),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Agregar Dinero'),
                  ),
                ),
                const SizedBox(width: 8),
                
                if (goal.currentAmount > 0)
                  OutlinedButton(
                    onPressed: () => _showWithdrawDialog(goal),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEC4899),
                      side: const BorderSide(color: Color(0xFFEC4899)),
                    ),
                    child: const Text('Retirar'),
                  ),
                const SizedBox(width: 8),
                
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditGoalDialog(goal),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFEC4899)),
                  onPressed: () => _showDeleteDialog(goal),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEditGoalDialog(
        onSave: _addSavingGoal,
      ),
    );
  }

  void _showEditGoalDialog(SavingGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AddEditGoalDialog(
        goal: goal,
        onSave: _updateSavingGoal,
      ),
    );
  }

  void _showDeleteDialog(SavingGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        title: const Text(
          'Eliminar Meta',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${goal.name}"?',
          style: const TextStyle(color: Colors.white70),
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
              _deleteSavingGoal(goal);
              Navigator.pop(context);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Color(0xFFEC4899)),
            ),
          ),
        ],
      ),
    );
  }
}

class AddEditGoalDialog extends StatefulWidget {
  final SavingGoal? goal;
  final Function(SavingGoal) onSave;

  const AddEditGoalDialog({
    Key? key,
    this.goal,
    required this.onSave,
  }) : super(key: key);

  @override
  _AddEditGoalDialogState createState() => _AddEditGoalDialogState();
}

class _AddEditGoalDialogState extends State<AddEditGoalDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));
  String _selectedIcon = '💰';

  final List<String> _icons = ['💰', '🏠', '🚗', '✈️', '🎓', '💍', '📱', '💻'];

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _nameController.text = widget.goal!.name;
      _descriptionController.text = widget.goal!.description;
      _targetAmountController.text = widget.goal!.targetAmount.toStringAsFixed(2);
      _targetDate = widget.goal!.targetDate;
      _selectedIcon = widget.goal!.icon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1B4B),
      title: Text(
        widget.goal == null ? 'Nueva Meta de Ahorro' : 'Editar Meta',
        style: const TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la meta',
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
            TextField(
              controller: _targetAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Meta de ahorro',
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
            Row(
              children: [
                const Text(
                  'Fecha objetivo:',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: _selectDate,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6366F1),
                      backgroundColor: const Color(0xFF0F0F23),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFF6366F1)),
                      ),
                    ),
                    child: Text(
                      '${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                      style: const TextStyle(color: Color(0xFF6366F1)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Selecciona un ícono:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _icons.map((icon) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selectedIcon == icon 
                          ? const Color(0xFF6366F1).withOpacity(0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedIcon == icon 
                            ? const Color(0xFF6366F1)
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
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
          onPressed: _saveGoal,
          child: const Text(
            'Guardar',
            style: TextStyle(color: Color(0xFF10B981)),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              surface: Color(0xFF1E1B4B),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1E1B4B),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _targetDate) {
      setState(() => _targetDate = picked);
    }
  }

  void _saveGoal() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final targetAmount = double.tryParse(_targetAmountController.text) ?? 0;

    if (name.isEmpty || targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos obligatorios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final goal = SavingGoal(
      id: widget.goal?.id,
      name: name,
      description: description,
      targetAmount: targetAmount,
      currentAmount: widget.goal?.currentAmount ?? 0,
      targetDate: _targetDate,
      createdAt: widget.goal?.createdAt ?? DateTime.now(),
      icon: _selectedIcon,
    );

    widget.onSave(goal);
    Navigator.pop(context);
  }
}