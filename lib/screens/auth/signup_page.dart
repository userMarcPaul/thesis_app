// lib/screens/auth/signup_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';


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
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // ✅ Email + Password Sign-Up with Verification (Option A)
   Future<void> _signupWithEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        User? user = userCredential.user;
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Verification email sent. Please verify before logging in.",
              ),
            ),
          );

          await _auth.signOut(); // Block access until verified
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Sign-up failed")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }


  // ✅ Google Sign-Up
  Future<void> _signupWithGoogle() async {
    try {
      
      final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId: '817740614273-dke1l5ef6o9ffp15b983c8rs9l860ba9.apps.googleusercontent.com',
);

final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final uid = userCredential.user!.uid;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ClientPreferencesFormPage(userId: uid),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In failed: $e")),
      );
    }
  }

  // ✅ Facebook Sign-Up
  Future<void> _signupWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(result.accessToken!.tokenString);
        UserCredential userCredential =
            await _auth.signInWithCredential(facebookAuthCredential);

        String uid = userCredential.user!.uid;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ClientPreferencesFormPage(userId: uid),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Facebook signup failed: $e")),
      );
    }
  }

  // ✅ Apple Sign-Up
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

      UserCredential userCredential =
          await _auth.signInWithCredential(oauthCredential);
      String uid = userCredential.user!.uid;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ClientPreferencesFormPage(userId: uid),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Apple signup failed: $e")),
      );
    }
  }

  // ✅ Phone Sign-Up (OTP)
  Future<void> _signupWithPhone() async {
  TextEditingController otpController = TextEditingController();
  String completePhoneNumber = "";

  await showDialog(
    context: context,
    builder: (context) {
      String verificationId = "";

      return AlertDialog(
        title: const Text("Sign Up with Phone"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IntlPhoneField(
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              initialCountryCode: 'PH', // 🇵🇭 default to Philippines
              onChanged: (phone) {
                completePhoneNumber = phone.completeNumber;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (completePhoneNumber.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid number")),
                );
                return;
              }

              await _auth.verifyPhoneNumber(
                phoneNumber: completePhoneNumber,
                verificationCompleted: (PhoneAuthCredential credential) async {
                  await _auth.signInWithCredential(credential);
                },
                verificationFailed: (FirebaseAuthException e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Verification failed: ${e.message}")),
                  );
                },
                codeSent: (String verId, int? resendToken) {
                  verificationId = verId;
                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Enter OTP"),
                      content: TextField(
                        controller: otpController,
                        decoration: const InputDecoration(labelText: "OTP"),
                        keyboardType: TextInputType.number,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            final smsCode = otpController.text.trim();
                            final credential = PhoneAuthProvider.credential(
                                verificationId: verificationId,
                                smsCode: smsCode);

                            final userCredential = await _auth.signInWithCredential(credential);
                            final uid = userCredential.user!.uid;

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ClientPreferencesFormPage(userId: uid),
                              ),
                            );
                          },
                          child: const Text("Verify"),
                        ),
                      ],
                    ),
                  );
                },
                codeAutoRetrievalTimeout: (String verificationId) {},
              );
            },
            child: const Text("Send Code"),
          ),
        ],
      );
    },
  );
}


  // 🧱 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create an Account",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Join us and start your journey!",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
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
                            validator: (val) =>
                                val!.isEmpty || !val.contains('@')
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
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                }),
                              ),
                            ),
                            obscureText: !_isPasswordVisible,
                            onChanged: (val) => _password = val,
                            validator: (val) => val!.length < 6
                                ? "Password must be at least 6 characters"
                                : null,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _signupWithEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize:
                                  const Size(double.infinity, 50),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
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
                      child: Text("OR", style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: const Icon(Icons.phone, color: Colors.white),
                  onPressed: _signupWithPhone,
                  label: const Text("Sign Up with Phone"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                  onPressed: _signupWithGoogle,
                  label: const Text("Sign Up with Google"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.facebook, color: Colors.white),
                  onPressed: _signupWithFacebook,
                  label: const Text("Sign Up with Facebook"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 50),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
