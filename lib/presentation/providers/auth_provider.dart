import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/user_model.dart';

// ── Service singleton ──────────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ── Raw Firebase auth stream ───────────────────────────────────────────────
final firebaseAuthStreamProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// ── Full user profile from Firestore ──────────────────────────────────────
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserModel?>>(
  (ref) => UserProfileNotifier(ref.watch(authServiceProvider)),
);

class UserProfileNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;

  UserProfileNotifier(this._authService) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await _authService.fetchCurrentUserProfile();
      state = AsyncValue.data(profile);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signUp(
          email: email, password: password, displayName: displayName);
      state = AsyncValue.data(user);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user =
          await _authService.signIn(email: email, password: password);
      state = AsyncValue.data(user);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AsyncValue.data(null);
  }

  Future<bool> checkVerification() async {
    final verified = await _authService.reloadAndCheckVerification();
    if (verified) await _load();
    return verified;
  }

  Future<void> resendVerification() async {
    await _authService.sendVerificationEmail();
  }

  Future<void> toggleNotifications(bool enabled) async {
    final profile = state.value;
    if (profile == null) return;
    await _authService.updateNotificationPreference(profile.uid, enabled);
    state = AsyncValue.data(UserModel(
      uid: profile.uid,
      email: profile.email,
      displayName: profile.displayName,
      emailVerified: profile.emailVerified,
      createdAt: profile.createdAt,
      notificationsEnabled: enabled,
    ));
  }

  Future<void> reload() => _load();
}
