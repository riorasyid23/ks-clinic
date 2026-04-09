import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

/// Provides the singleton [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Holds the current authentication state managed by [AuthNotifier].
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

/// Represents the possible states of authentication.
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  final String token;
  const AuthAuthenticated({required this.user, required this.token});
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

/// Manages login / logout and exposes [AuthState].
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthInitial());

  /// Attempt to login with the given credentials.
  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final response = await _repository.login(email, password);
      state = AuthAuthenticated(user: response.user, token: response.token);
    } on AuthException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError('Something went wrong. Please try again.');
    }
  }

  /// Clear session and reset to initial state.
  Future<void> logout() async {
    await _repository.logout();
    state = const AuthInitial();
  }

  /// Check if an existing session is available (for splash screen).
  Future<bool> tryAutoLogin() async {
    return await _repository.isLoggedIn();
  }
}
