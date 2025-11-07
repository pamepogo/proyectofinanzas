import 'package:flutter/material.dart';
import 'package:gastito/screens/statistics_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/balance_screen.dart';
import 'screens/savings_screen.dart';

void main() {
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
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/balance': (context) => const BalanceScreen(),
        '/statistics': (context) => const StatisticsScreen(),
        '/savings': (context) => const SavingsScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
