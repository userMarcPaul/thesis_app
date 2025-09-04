import 'package:flutter/material.dart';
import 'auth/auth_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  void navigateToAuth(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AuthPage(role: role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roles = [
      {
        'name': 'Administrator',
        'icon': Icons.admin_panel_settings,
        'color': Colors.blue,
        'role': 'admin'
      },
      {
        'name': 'Creative Professional',
        'icon': Icons.brush,
        'color': Colors.orange,
        'role': 'creative'
      },
      {
        'name': 'Client',
        'icon': Icons.person,
        'color': Colors.green,
        'role': 'client'
      },
    ];

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Image.asset(
                    'assets/systemlogo.png',
                    width: 100,
                    height: 100,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),

                  // System Title
                  const Text(
                    'Booking System For Biliran Creative Industries With',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Recommendation Algorithm',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Role Cards
                  ...roles.map(
                    (role) => GestureDetector(
                      onTap: () =>
                          navigateToAuth(context, role['role'] as String),
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                (role['color'] as Color).withOpacity(0.8),
                                role['color'] as Color
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  role['icon'] as IconData,
                                  size: 28,
                                  color: role['color'] as Color,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  role['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
