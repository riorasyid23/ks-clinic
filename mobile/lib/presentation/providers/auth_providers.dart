import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';

/// Provides the singleton [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Holds the current authentication state managed by [AuthNotifier].
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier(ref.read(authRepositoryProvider));

  // Optional: check session on startup or resume
  // notifier.checkSession();

  return notifier;
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

class AuthSessionExpired extends AuthState {
  const AuthSessionExpired();
}

/// Manages login / logout and exposes [AuthState].
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  Timer? _expiryTimer;

  AuthNotifier(this._repository) : super(const AuthInitial()) {
    // Check session every minute to catch expiry while app is running
    _expiryTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => checkSession(),
    );
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

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

  /// Check if an existing session is available and not expired.
  Future<bool> checkSession() async {
    final token = await _repository.getToken();
    if (token == null || token.isEmpty) return false;

    final expiry = await _repository.getExpiryAt();
    if (expiry != null && DateTime.now().isAfter(expiry)) {
      // Only set to expired if we were previously logged in or investigating session
      if (state is! AuthInitial && state is! AuthSessionExpired) {
        state = const AuthSessionExpired();
      }
      return false;
    }

    // If we are technically logged in but state is initial, update state
    // (This helps with auto-login from splash)
    if (state is AuthInitial) {
      // We might need to fetch user profile here if wanted,
      // but for simple expiry check, returns true is enough.
    }

    return true;
  }

  /// Updates the currently authenticated user state.
  void updateAuthUser(User newUser) {
    if (state is AuthAuthenticated) {
      final current = state as AuthAuthenticated;
      state = AuthAuthenticated(user: newUser, token: current.token);
    }
  }
}
