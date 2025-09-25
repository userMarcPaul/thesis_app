import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../role_selection_page.dart';
import '../client/client_home_page.dart';

class LoginPage extends StatefulWidget {
  final String role;
  final VoidCallback onSwitch;

  const LoginPage({super.key, required this.role, required this.onSwitch});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;
  // State variable to track password visibility
  bool _isPasswordVisible = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);

    try {
      // Firebase login
      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);

      final uid = userCred.user!.uid;

      // Fetch Firestore profile
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      if (!doc.exists) {
        _showErrorDialog("Error", "User profile not found.");
        await FirebaseAuth.instance.signOut();
        return;
      }

      final userData = doc.data() as Map<String, dynamic>;
      final storedRole = userData["role"];

      // Role mismatch
      if (storedRole != widget.role) {
        _showErrorDialog(
          "Access Denied",
          "This account is registered as *$storedRole* and cannot log in as ${widget.role}.",
        );
        await FirebaseAuth.instance.signOut();
        return;
      }

      // Redirect based on the user's role
      if (storedRole == "client") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ClientHomePage(clientName: userData['name']),
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The background color is now a solid white, like the signup page
      backgroundColor: Colors.white,
      
      body: Center(
        // ScrollConfiguration and SingleChildScrollView prevent the scrollbar from showing
        // and allow the content to be scrollable if needed on small screens
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              // ConstrainedBox ensures the content card has a consistent max width
              // on large screens (e.g., desktops)
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    // The Card now matches the styling of the signup page
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
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
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),

                              // TextFormField styling is updated to match the signup page
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  prefixIcon: const Icon(Icons.email),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                onSaved: (v) => _email = v!.trim(),
                                validator: (v) =>
                                    v!.contains('@') ? null : 'Invalid email',
                              ),
                              const SizedBox(height: 15),

                              TextFormField(
                                // Toggles password visibility based on the state variable
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  prefixIcon: const Icon(Icons.lock),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  // Add the IconButton here to toggle visibility
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                onSaved: (v) => _password = v!.trim(),
                                validator: (v) =>
                                    v!.length >= 6 ? null : 'Min 6 chars',
                              ),
                              const SizedBox(height: 25),

                              _loading
                                  ? const CircularProgressIndicator()
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        // ElevatedButton styling is updated to match the signup page
                                        backgroundColor: Colors.deepPurple,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
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
                                onTap: widget.onSwitch,
                                child: const Text(
                                  // This text style now matches the signup page
                                  "Don't have an account? Create one",
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
