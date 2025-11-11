// widgets/weekly_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';

class WeeklyChart extends StatelessWidget {
  final List<Transaction> transactions;

  const WeeklyChart({Key? key, required this.transactions}) : super(key: key);

  // ✅ MÉTODO CORREGIDO - Cálculo correcto de la semana
  Map<String, dynamic> _getWeeklyData() {
    final now = DateTime.now();
    
    // ✅ CORRECCIÓN: Calcular correctamente el inicio de la semana (Lunes)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    // ✅ Crear lista de los 7 días de la semana
    List<DateTime> weekDays = [];
    for (int i = 0; i < 7; i++) {
      weekDays.add(startOfWeek.add(Duration(days: i)));
    }

    // ✅ Inicializar arrays para gastos e ingresos
    List<double> gastosDiarios = List.filled(7, 0.0);
    List<double> ingresosDiarios = List.filled(7, 0.0);

    // ✅ DEBUG: Verificar fechas
    print('📅 Semana calculada:');
    for (int i = 0; i < weekDays.length; i++) {
      print('   Día $i: ${weekDays[i]}');
    }

    // ✅ Calcular totales por día - COMPARACIÓN CORRECTA
    for (var transaction in transactions) {
      // Normalizar fecha de transacción (sin horas/minutos/segundos)
      final transactionDate = DateTime(
        transaction.date.year, 
        transaction.date.month, 
        transaction.date.day
      );

      // Buscar en qué día de la semana cae esta transacción
      for (int i = 0; i < weekDays.length; i++) {
        final weekDay = DateTime(
          weekDays[i].year, 
          weekDays[i].month, 
          weekDays[i].day
        );
        
        if (transactionDate == weekDay) {
          if (transaction.type == TransactionType.GASTO) {
            gastosDiarios[i] += transaction.amount;
          } else {
            ingresosDiarios[i] += transaction.amount;
          }
          break;
        }
      }
    }

    // ✅ DEBUG: Verificar resultados
    print('💰 Gastos por día: $gastosDiarios');
    print('💵 Ingresos por día: $ingresosDiarios');

    return {
      'gastos': gastosDiarios,
      'ingresos': ingresosDiarios,
      'weekDays': weekDays,
    };
  }

  // ... (el resto de tus métodos se mantienen igual)
  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
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

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final weeklyData = _getWeeklyData();
    final gastos = weeklyData['gastos'] as List<double>;
    final ingresos = weeklyData['ingresos'] as List<double>;
    
    final maxGasto = gastos.isNotEmpty ? gastos.reduce((a, b) => a > b ? a : b) : 0.0;
    final maxIngreso = ingresos.isNotEmpty ? ingresos.reduce((a, b) => a > b ? a : b) : 0.0;
    final maxY = (maxGasto > maxIngreso ? maxGasto : maxIngreso) * 1.2;

    final totalIngresos = ingresos.isNotEmpty ? ingresos.reduce((a, b) => a + b).toDouble() : 0.0;
    final totalGastos = gastos.isNotEmpty ? gastos.reduce((a, b) => a + b).toDouble() : 0.0;
    final balance = (totalIngresos - totalGastos).toDouble();

    return Container(
      color: const Color(0xFF0F0F23),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // RESUMEN SEMANAL
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
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
                children: [
                  const Text(
                    'Resumen Semanal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem('Ingresos', totalIngresos, const Color(0xFF10B981)),
                      _buildSummaryItem('Gastos', totalGastos, const Color(0xFFEC4899)),
                      _buildSummaryItem('Balance', balance, balance >= 0 ? const Color(0xFF10B981) : const Color(0xFFEC4899)),
                    ],
                  ),
                ],
              ),
            ),

            // GRÁFICO DE BARRAS
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
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
                    'Gastos vs Ingresos de la Semana',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        maxY: maxY == 0 ? 100 : maxY,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final days = ['L', 'MA', 'MI', 'J', 'V', 'S', 'D'];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    days[value.toInt()],
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          for (int i = 0; i < gastos.length; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: [
                                // BARRAS PARA GASTOS
                                BarChartRodData(
                                  toY: gastos[i],
                                  color: const Color(0xFFEC4899),
                                  width: 8,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                // BARRAS PARA INGRESOS
                                BarChartRodData(
                                  toY: ingresos[i],
                                  color: const Color(0xFF10B981),
                                  width: 8,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ],
                            ),
                        ],
                        gridData: FlGridData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('Ingresos', const Color(0xFF10B981)),
                      const SizedBox(width: 20),
                      _buildLegendItem('Gastos', const Color(0xFFEC4899)),
                    ],
                  ),
                ],
              ),
            ),

            // BOTÓN PARA BALANCE COMPLETO
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/balance');
                },
                icon: const Icon(Icons.bar_chart),
                label: const Text('Ver Balance Completo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}