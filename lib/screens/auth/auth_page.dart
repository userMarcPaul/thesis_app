import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';

class AuthPage extends StatefulWidget {
  final String role; // 'client', 'creative', 'admin'

  const AuthPage({super.key, required this.role});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLogin = true; // default is login

  void toggle() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showLogin
          ? LoginPage(
              role: widget.role,
              onSwitch: toggle, // 👈 switch to signup
            )
          : SignupPage(
              role: widget.role,
              onSwitch: toggle, // 👈 switch to login
            ),
    );
  }
}
