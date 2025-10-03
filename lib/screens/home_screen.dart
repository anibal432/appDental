// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'dental_tips_screen.dart';
import '../login/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) async {
    final authService = AuthService();
    await authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dental AI'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        children: [
          _MenuCard(
            title: 'Consejos Dentales',
            icon: Icons.tips_and_updates,
            color: Colors.blue,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DentalTipsScreen())),
          ),
          _MenuCard(
            title: 'Recordatorios',
            icon: Icons.notifications,
            color: Colors.orange,
            onTap: () => _showMessage(context, 'Próximamente'),
          ),
          _MenuCard(
            title: 'Mi Perfil',
            icon: Icons.person,
            color: Colors.purple,
            onTap: () => _showMessage(context, 'Próximamente'),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
