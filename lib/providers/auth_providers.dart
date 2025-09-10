import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myecommerceapp/data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return authRepository.authStateChanges();
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AsyncValue.loading()) {
    _authRepository.authStateChanges().listen((user) {
      state = AsyncValue.data(user);
    });
  }

  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        username: username,
      );
      state = AsyncValue.data(user);
      return user;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  Future<User?> loginWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.loginWithEmail(email, password);
      state = AsyncValue.data(user);
      return user;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  Future<User?> loginWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.loginWithGoogle();
      state = AsyncValue.data(user);
      return user;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authRepository.resetPassword(email);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
      final authRepository = ref.read(authRepositoryProvider);
      return AuthNotifier(authRepository);
    });
