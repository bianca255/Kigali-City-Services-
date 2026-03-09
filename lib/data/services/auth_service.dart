import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(displayName);
    
    // Send verification email with error handling
    try {
      await user.sendEmailVerification();
      print('✅ Verification email sent to $email');
    } catch (e) {
      print('⚠️ Failed to send verification email: $e');
      // Continue signup even if email fails
    }

    final userModel = UserModel(
      uid: user.uid,
      email: email,
      displayName: displayName,
      emailVerified: false,
      createdAt: DateTime.now(),
      notificationsEnabled: false,
    );
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toFirestore());
    return userModel;
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.reload();
    final doc =
        await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      // Update emailVerified in Firestore if changed
      if (user.emailVerified &&
          !(doc.data()?['emailVerified'] as bool? ?? false)) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({'emailVerified': true});
      }
      return UserModel.fromFirestore(doc);
    }
    return UserModel(
      uid: user.uid,
      email: user.email ?? email,
      displayName: user.displayName ?? '',
      emailVerified: user.emailVerified,
      createdAt: DateTime.now(),
    );
  }

  Future<void> signOut() async => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) async =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> sendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      print('✅ Verification email resent to ${_auth.currentUser?.email}');
    } catch (e) {
      print('⚠️ Failed to resend verification email: $e');
      rethrow; // Re-throw so UI can show error
    }
  }

  Future<bool> reloadAndCheckVerification() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<UserModel?> fetchCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc =
        await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) return UserModel.fromFirestore(doc);
    return null;
  }

  Future<void> updateNotificationPreference(
      String uid, bool enabled) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({'notificationsEnabled': enabled});
  }
}
