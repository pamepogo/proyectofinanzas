// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gastito/firebase_options.dart';
import 'package:gastito/screens/statistics_screen.dart';
import 'package:gastito/services/optimized_transaction_service.dart'; 
import 'package:gastito/services/saving_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/balance_screen.dart';
import 'screens/savings_screen.dart' as savings_screen; // Alias para evitar conflicto

// Proveedor de servicios - usa solo OptimizedTransactionService
final OptimizedTransactionService transactionService = OptimizedTransactionService();
final SavingService savingService = SavingService(transactionService);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GastitoApp());
}

class GastitoApp extends StatelessWidget {
  const GastitoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planificash',
      theme: ThemeData(
        primaryColor: const Color(0xFF6366F1),
        scaffoldBackgroundColor: const Color(0xFF0F0F23),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/balance': (context) => const BalanceScreen(),
        '/statistics': (context) => const StatisticsScreen(),
        '/savings': (context) => const savings_screen.SavingsScreen(), // Usa el alias
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          // Usuario autenticado
          return const HomeScreen();
        } else {
          // Usuario no autenticado
          return const LoginScreen();
        }
      },
    );
  }
}