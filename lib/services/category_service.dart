import '../models/transaction.dart';

class CategoryService {
  static final List<String> gastosCategories = [
    'Comida', 'Transporte', 'Compras', 'Mascota', 'Social',
    'Entretenimiento', 'Vivienda', 'Cosméticos', 'Hogar',
    'Salud', 'Educación', 'Otros Gastos'
  ];

  static final List<String> ingresosCategories = [
    'Salario', 'Inversiones', 'Regalos', 'Freelance', 
    'Negocio', 'Otros Ingresos'
  ];

  static Map<String, int> categoryColors = {
    'Comida': 0xFFFF6B6B, 'Transporte': 0xFF4ECDC4, 'Compras': 0xFFFFD166,
    'Mascota': 0xFF6A0572, 'Social': 0xFF118AB2, 'Entretenimiento': 0xFF06D6A0,
    'Vivienda': 0xFF073B4C, 'Cosméticos': 0xFFFFA69E, 'Hogar': 0xFF6A8E7F,
    'Salud': 0xFFA41623, 'Educación': 0xFF1A535C, 'Otros Gastos': 0xFF6D6875,
    'Salario': 0xFF4CAF50, 'Inversiones': 0xFF2196F3, 'Regalos': 0xFF9C27B0,
    'Freelance': 0xFFFF9800, 'Negocio': 0xFF795548, 'Otros Ingresos': 0xFF607D8B,
  };

  static int getCategoryColor(String category) {
    return categoryColors[category] ?? 0xFF6D6875;
  }

  static String getCategoryIcon(String category) {
    final icons = {
      'Comida': '🍔', 'Transporte': '🚗', 'Compras': '🛍️', 'Mascota': '🐾',
      'Social': '👥', 'Entretenimiento': '🎬', 'Vivienda': '🏠', 'Cosméticos': '💄',
      'Hogar': '🏡', 'Salud': '⚕️', 'Educación': '📚', 'Otros Gastos': '📦',
      'Salario': '💰', 'Inversiones': '📈', 'Regalos': '🎁', 'Freelance': '💻',
      'Negocio': '🏢', 'Otros Ingresos': '💳',
    };
    return icons[category] ?? '📋';
  }

  static List<String> getCategoriesByType(TransactionType type) {
    return type == TransactionType.INGRESO ? ingresosCategories : gastosCategories;
  }
}