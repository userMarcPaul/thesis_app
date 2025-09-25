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

    // Max width for the container on large screens
    double containerMaxWidth = 500;

    return Scaffold(
      // Set the background color to white to match the signup page design
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Use a transparent app bar with a centered title for a clean look
        title: const Text(
          "Select Your Role",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          // Use SingleChildScrollView to prevent overflow and enable scrolling if needed
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              // Constrain the box to a max width for a better reading experience on large screens
              constraints: BoxConstraints(
                maxWidth: containerMaxWidth,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Please choose your account type to proceed.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Use the map function to generate the role cards
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
