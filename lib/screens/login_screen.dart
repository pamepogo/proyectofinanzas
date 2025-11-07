import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final String _demoEmail = "usuario@gmail.com";
  final String _demoPassword = "123456";

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(milliseconds: 1500));

      if (_emailController.text == _demoEmail && 
          _passwordController.text == _demoPassword) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email o contraseña incorrectos'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _skipLogin() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo con ícono de finanzas
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: const Color(0xFFEC4899).withOpacity(0.3),
                        blurRadius: 25,
                        offset: const Offset(8, 0),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.monetization_on_rounded, // Ícono de dinero
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 25),
                
                // Títulos
                const Text(
                  'Bienvenido a',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF06B6D4),
                  ),
                ),
                const SizedBox(height: 5),
                ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'PLANIFICASH',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu aliado en gestión financiera',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 35),
                
                // Formulario
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Campo Email
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF06B6D4).withOpacity(0.4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF06B6D4).withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'tu@email.com',
                              hintStyle: TextStyle(color: Colors.white54),
                              prefixIcon: Icon(Icons.email_outlined, size: 20, color: Color(0xFF06B6D4)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Ingresa tu email';
                              if (!value.contains('@')) return 'Email inválido';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Campo Contraseña
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF8B5CF6).withOpacity(0.4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Tu contraseña',
                              hintStyle: const TextStyle(color: Colors.white54),
                              prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Color(0xFF8B5CF6)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword 
                                      ? Icons.visibility_outlined 
                                      : Icons.visibility_off_outlined,
                                  size: 18,
                                  color: const Color(0xFFEC4899),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
                              if (value.length < 6) return 'Mínimo 6 caracteres';
                              return null;
                            },
                            onFieldSubmitted: (_) => _login(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Botón de login
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF6366F1).withOpacity(0.5),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'ACCEDER A MIS FINANZAS',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Opción de registro
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '¿No tienes cuenta?',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: const Text(
                                'Crear cuenta',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Botón para saltar
                TextButton(
                  onPressed: _skipLogin,
                  child: Text(
                    'Continuar sin cuenta',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white54,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}