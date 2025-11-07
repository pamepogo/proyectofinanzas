import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback? onHomeSelected;
  final VoidCallback? onStatisticsSelected;
  final VoidCallback? onBalanceSelected;
  final VoidCallback? onSavingsSelected;
  final VoidCallback? onLogoutSelected;
  final String currentRoute;

  const CustomDrawer({
    Key? key,
    this.onHomeSelected,
    this.onStatisticsSelected,
    this.onBalanceSelected,
    this.onSavingsSelected,
    this.onLogoutSelected,
    required this.currentRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1E1B4B),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header del Drawer
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF6366F1),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                const Text(
                  'PLANIFICASH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Control Financiero',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Elementos del menú
          _buildDrawerItem(
            context: context,
            icon: Icons.today,
            title: 'Hoy',
            isSelected: currentRoute == '/home',
            onTap: onHomeSelected ?? () {
              Navigator.pop(context);
              if (currentRoute != '/home') {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.bar_chart,
            title: 'Estadísticas',
            isSelected: currentRoute == '/statistics',
            onTap: onStatisticsSelected ?? () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/statistics');
            },
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.account_balance_wallet,
            title: 'Balance General',
            isSelected: currentRoute == '/balance',
            onTap: onBalanceSelected ?? () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/balance');
            },
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.savings,
            title: 'Ahorro',
            isSelected: currentRoute == '/savings',
            onTap: onSavingsSelected ?? () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/savings');
            },
          ),

          const Divider(
            color: Colors.white24,
            height: 20,
            thickness: 1,
          ),

          // Cerrar Sesión
          _buildDrawerItem(
            context: context,
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            isSelected: false,
            onTap: onLogoutSelected ?? () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
            color: const Color(0xFFEC4899),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF6366F1).withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: color ?? (isSelected ? const Color(0xFF6366F1) : Colors.white70),
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: color ?? (isSelected ? const Color(0xFF6366F1) : Colors.white),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        trailing: isSelected
            ? const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF6366F1),
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: TextStyle(color: Colors.white70),
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
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Color(0xFFEC4899)),
            ),
          ),
        ],
      ),
    );
  }
}