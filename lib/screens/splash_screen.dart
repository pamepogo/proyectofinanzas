import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    _controller.forward();
    
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF1E1B4B),
              Color(0xFF0F0F23),
            ],
            center: Alignment.center,
            radius: 1.2,
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo con ícono de finanzas
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFF06B6D4)],
                      stops: [0.0, 0.3, 0.7, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.5),
                        blurRadius: 30,
                        offset: const Offset(-5, -5),
                      ),
                      BoxShadow(
                        color: const Color(0xFFEC4899).withOpacity(0.5),
                        blurRadius: 30,
                        offset: const Offset(5, 5),
                      ),
                      BoxShadow(
                        color: const Color(0xFF06B6D4).withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded, // Ícono de billetera
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Nombre de la app
                ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFFEC4899), Color(0xFF06B6D4)],
                      stops: [0.0, 0.5, 1.0],
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'PLANIFICASH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                
                // Slogan
                const Text(
                  'Controla tu dinero inteligentemente',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Loading indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 20),
                
                // Texto de carga
                const Text(
                  'Cargando tu economía...',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}