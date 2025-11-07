import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Las contraseñas no coinciden'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(milliseconds: 2000));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 1000));
      Navigator.pushReplacementNamed(context, '/login');

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    Color borderColor = const Color(0xFF06B6D4),
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, size: 20, color: borderColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    Color borderColor = const Color(0xFF06B6D4),
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: borderColor),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 18,
              color: const Color(0xFFEC4899),
            ),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        validator: validator,
      ),
    );
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
                // Botón de volver
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, size: 24, color: Color(0xFF06B6D4)),
                    onPressed: _goToLogin,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEC4899), Color(0xFF8B5CF6), Color(0xFF6366F1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEC4899).withOpacity(0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 25,
                        offset: const Offset(8, 0),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 25),
                
                // Títulos
                ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF10B981)],
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'CREAR CUENTA',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Únete a la revolución financiera',
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
                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildField(
                          controller: _nameController,
                          hintText: 'Nombre completo',
                          icon: Icons.person_outline_rounded,
                          borderColor: const Color(0xFF10B981), // Esmeralda luminosa
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Ingresa tu nombre';
                            if (value.length < 2) return 'Nombre muy corto';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        _buildField(
                          controller: _emailController,
                          hintText: 'tu@email.com',
                          icon: Icons.email_outlined,
                          borderColor: const Color(0xFF06B6D4), // Cian eléctrico
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Ingresa tu email';
                            if (!value.contains('@')) return 'Email inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        _buildPasswordField(
                          controller: _passwordController,
                          hintText: 'Contraseña',
                          obscureText: _obscurePassword,
                          onToggle: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          borderColor: const Color(0xFF8B5CF6), // Púrpura brillante
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Ingresa contraseña';
                            if (value.length < 6) return 'Mínimo 6 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirmar contraseña',
                          obscureText: _obscureConfirmPassword,
                          onToggle: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                          borderColor: const Color(0xFFEC4899), // Rosa neón
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Confirma contraseña';
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        
                        // Botón de registro
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEC4899)),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _register,
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
                                        colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFEC4899).withOpacity(0.5),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'CREAR CUENTA',
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
                        
                        const SizedBox(height: 22),
                        
                        // Enlace al login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '¿Ya tienes cuenta?',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: _goToLogin,
                              child: const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF10B981), // Esmeralda luminosa
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}