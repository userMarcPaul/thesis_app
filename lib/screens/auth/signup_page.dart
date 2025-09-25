import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../client/client_preferences_form_page.dart';

class SignupPage extends StatefulWidget {
  final String role;
  final VoidCallback onSwitch;

  const SignupPage({
    super.key,
    required this.role,
    required this.onSwitch,
  });

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  // New state variable to track password visibility
  bool _isPasswordVisible = false; 

  // ✅ Email & Password Signup
  Future<void> _signupWithEmail() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
        String uid = userCredential.user!.uid;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ClientPreferencesFormPage(userId: uid),
          ),
        );
      } on FirebaseAuthException catch (e) {
        print("Signup failed: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? "An error occurred"),
          ),
        );
      }
    }
  }

  // ✅ Facebook Signup
  Future<void> _signupWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
        UserCredential userCredential = await _auth.signInWithCredential(facebookAuthCredential);
        String uid = userCredential.user!.uid;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ClientPreferencesFormPage(userId: uid),
          ),
        );
      }
    } catch (e) {
      print("Facebook signup failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Facebook signup failed: $e")),
      );
    }
  }

  // ✅ Apple Signup
  Future<void> _signupWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(oauthCredential);
      String uid = userCredential.user!.uid;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ClientPreferencesFormPage(userId: uid),
        ),
      );
    } catch (e) {
      print("Apple signup failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Apple signup failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create an Account",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Join us and start your journey!",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

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
                            children: [
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  prefixIcon: const Icon(Icons.email),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (val) => _email = val,
                                validator: (val) => val!.isEmpty || !val.contains('@')
                                    ? "Please enter a valid email"
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  prefixIcon: const Icon(Icons.lock),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  // Add the IconButton here
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      // Toggle the state and rebuild the widget
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                // Use the new state variable to control visibility
                                obscureText: !_isPasswordVisible,
                                onChanged: (val) => _password = val,
                                validator: (val) => val!.length < 6
                                    ? "Password must be at least 6 characters"
                                    : null,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _signupWithEmail,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Text(
                                  "Sign Up with Email",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "OR",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.facebook, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1877F2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _signupWithFacebook,
                      label: const Text(
                        "Sign Up with Facebook",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SignInWithAppleButton(
                      onPressed: _signupWithApple,
                      style: SignInWithAppleButtonStyle.black,
                      height: 50,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    const SizedBox(height: 48),

                    GestureDetector(
                      onTap: widget.onSwitch,
                      child: const Text(
                        "Already have an account? Log In",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
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