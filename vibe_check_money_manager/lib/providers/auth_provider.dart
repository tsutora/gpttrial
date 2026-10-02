import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Firebase instances
final firebaseAuthProvider = Provider<fb.FirebaseAuth>((ref) {
  return fb.FirebaseAuth.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn();
});

// Current user state
final authStateProvider = StreamProvider<fb.User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// Auth notifier for sign in/out
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<fb.User?>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<fb.User?>> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AsyncValue.loading()) {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final firebaseAuth = ref.read(firebaseAuthProvider);
    state = AsyncValue.data(firebaseAuth.currentUser);
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final googleSignIn = ref.read(googleSignInProvider);
      final firebaseAuth = ref.read(firebaseAuthProvider);

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        state = AsyncValue.data(null);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await firebaseAuth.signInWithCredential(credential);
      state = AsyncValue.data(result.user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signOut() async {
    try {
      final googleSignIn = ref.read(googleSignInProvider);
      final firebaseAuth = ref.read(firebaseAuthProvider);

      await googleSignIn.signOut();
      await firebaseAuth.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
