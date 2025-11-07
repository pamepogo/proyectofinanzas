import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import '../models/expense.dart';

class ExpenseService {
  static sql.Database? _database;

  Future<sql.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<sql.Database> _initDatabase() async {
    try {
      String path = join(await sql.getDatabasesPath(), 'gastito.db');
      final db = await sql.openDatabase(
        path,
        version: 3,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );
      return db;
    } catch (e) {
      print('❌ Error al inicializar base de datos: $e');
      rethrow;
    }
  }

  Future<void> _createDatabase(sql.Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        date INTEGER NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDatabase(sql.Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE expenses ADD COLUMN category TEXT NOT NULL DEFAULT "Otros"');
    }
    
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE transactions_new(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          description TEXT NOT NULL,
          amount REAL NOT NULL,
          date INTEGER NOT NULL,
          category TEXT NOT NULL,
          type TEXT NOT NULL
        )
      ''');
      
      final List<Map<String, dynamic>> oldData = await db.query('expenses');
      for (var data in oldData) {
        await db.insert('transactions_new', {
          'description': data['description'],
          'amount': data['amount'],
          'date': data['date'],
          'category': data['category'] ?? 'Otros Gastos',
          'type': 'GASTO'
        });
      }
      
      await db.execute('DROP TABLE expenses');
      await db.execute('ALTER TABLE transactions_new RENAME TO transactions');
    }
  }

  Future<int> addTransaction(Transaction transaction) async {
    try {
      final db = await database;
      return await db.insert('transactions', transaction.toMap());
    } catch (e) {
      print('❌ Error al agregar transacción: $e');
      rethrow;
    }
  }

  Future<List<Transaction>> getTransactions() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        orderBy: 'date DESC',
      );
      return maps.map((map) => Transaction.fromMap(map)).toList();
    } catch (e) {
      print('❌ Error al obtener transacciones: $e');
      return [];
    }
  }

  Future<double> getCurrentBalance() async {
    try {
      final transactions = await getTransactions();
      double balance = 0;
      for (var transaction in transactions) {
        balance += transaction.signedAmount;
      }
      return balance;
    } catch (e) {
      print('❌ Error al calcular saldo: $e');
      return 0;
    }
  }

  Future<Map<String, double>> getTotals() async {
    try {
      final transactions = await getTransactions();
      double totalIngresos = 0;
      double totalGastos = 0;
      
      for (var transaction in transactions) {
        if (transaction.type == TransactionType.INGRESO) {
          totalIngresos += transaction.amount;
        } else {
          totalGastos += transaction.amount;
        }
      }
      
      return {
        'ingresos': totalIngresos,
        'gastos': totalGastos,
        'balance': totalIngresos - totalGastos,
      };
    } catch (e) {
      print('❌ Error al calcular totales: $e');
      return {'ingresos': 0, 'gastos': 0, 'balance': 0};
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      final db = await database;
      await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('❌ Error al eliminar transacción: $e');
      rethrow;
    }
  }
}