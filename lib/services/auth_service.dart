import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Sign up a new user
  /// role can be 'admin', 'client', or 'creative'
  /// extraData can include category, bio, sample rate, portfolio URLs
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    Map<String, dynamic>? extraData,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = cred.user!.uid;

    // Explicitly declare type to avoid addAll issues
    final Map<String, dynamic> data = {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'isVerified': role == 'creative' ? false : true,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Merge extra fields safely
    if (extraData != null) data.addAll(extraData);

    await _db.collection('users').doc(uid).set(data);

    return cred;
  }

  /// Sign in existing user
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Sign out user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user model
  Future<AppUser?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return AppUser.fromMap(data);
  }
}
