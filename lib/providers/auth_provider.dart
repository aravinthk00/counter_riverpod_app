import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/db_helper.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());

  final DatabaseHelper db = DatabaseHelper.instance;

  void clearError() {
    if (state.status == AuthStatus.error) {
      state = AuthState.initial();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      clearError();
      state = AuthState.loading();
      final user = await db.getUser(email, password);
      
      if (user != null) {
        state = AuthState.authenticated(user.id, email);
      } else {
        state = AuthState.error('Invalid email or password');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signup(String email, String password) async {
    try {
      clearError();
      state = AuthState.loading();
      final id = await db.createUser(email, password);
      state = AuthState.authenticated(id, email);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signout(String id) async {
    try {
      clearError();
      state = AuthState.loading();
      await db.logout(id);
      state = AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error('Failed to logout: $e');
    }
  }
}

enum AuthStatus { initial, loading, authenticated, error, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? email;
  final String? id;
  final String? error;

  AuthState({required this.status, this.id, this.email, this.error});

  factory AuthState.initial() => AuthState(status: AuthStatus.initial);
  factory AuthState.loading() => AuthState(status: AuthStatus.loading);
  factory AuthState.authenticated(String id, String email) =>
      AuthState(status: AuthStatus.authenticated, id: id, email: email);
  factory AuthState.error(String error) =>
      AuthState(status: AuthStatus.error, error: error);
  factory AuthState.unauthenticated() =>
      AuthState(status: AuthStatus.unauthenticated);
}

final counterProvider = StateProvider<int>((ref) => 0); // Counter Provider
