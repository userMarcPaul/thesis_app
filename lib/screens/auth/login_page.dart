import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'signup_page.dart';
import '../role_selection_page.dart';

class LoginPage extends StatefulWidget {
  final String role;
  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);

    try {
      // Sign in with Firebase
      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final uid = userCred.user!.uid;

      // Fetch user data
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      if (!doc.exists) {
        _showErrorDialog("Error", "User profile not found.");
        await FirebaseAuth.instance.signOut();
        return;
      }

      final userData = doc.data() as Map<String, dynamic>;
      final storedRole = userData["role"];

      // ✅ Check role match
      if (storedRole != widget.role) {
        _showErrorDialog(
          "Access Denied",
          "This account is registered as *$storedRole* and cannot log in as ${widget.role}.",
        );
        await FirebaseAuth.instance.signOut();
        return;
      }

      // ✅ Redirect based on role
      if (storedRole == "client") {
        Navigator.pushReplacementNamed(context, "/client_home");
      } else if (storedRole == "creative") {
        Navigator.pushReplacementNamed(context, "/creative_home");
      } else if (storedRole == "admin") {
        Navigator.pushReplacementNamed(context, "/admin_dashboard");
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog("Login Failed", e.message ?? "Invalid credentials.");
    } catch (e) {
      _showErrorDialog("Error", e.toString());
    }

    setState(() => _loading = false);
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.blue),
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
      ),
    );
  }

  Widget _socialIconButton(Widget child, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.white,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RoleSelectionPage(),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Login as ${widget.role.toUpperCase()}",
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 20),

                              TextFormField(
                                decoration:
                                    _inputDecoration("Email", Icons.email),
                                onSaved: (v) => email = v!.trim(),
                                validator: (v) =>
                                    v!.contains('@') ? null : 'Invalid email',
                              ),
                              const SizedBox(height: 15),

                              TextFormField(
                                obscureText: true,
                                decoration:
                                    _inputDecoration("Password", Icons.lock),
                                onSaved: (v) => password = v!.trim(),
                                validator: (v) =>
                                    v!.length >= 6 ? null : 'Min 6 chars',
                              ),
                              const SizedBox(height: 25),

                              _loading
                                  ? const CircularProgressIndicator()
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        minimumSize:
                                            const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      onPressed: _submit,
                                      child: const Text(
                                        "Login",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                              const SizedBox(height: 20),

                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          SignupPage(role: widget.role),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Don't have an account? Create one",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Social logos
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _socialIconButton(
                                    const Icon(Icons.facebook,
                                        size: 30, color: Colors.blue),
                                    () {
                                      // TODO: Facebook login
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                  _socialIconButton(
                                    const Text(
                                      "G",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    () {
                                      // TODO: Google login
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
