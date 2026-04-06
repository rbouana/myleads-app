import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String userName;
  final String userEmail;
  final String? error;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.userName = '',
    this.userEmail = '',
    this.error,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? userName,
    String? userEmail,
    String? error,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
      : super(AuthState(
          isLoggedIn: StorageService.isLoggedIn,
          userName: StorageService.userName,
          userEmail: StorageService.userEmail,
        ));

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.isNotEmpty && password.length >= 6) {
      StorageService.isLoggedIn = true;
      StorageService.userEmail = email;
      state = state.copyWith(
        isLoggedIn: true,
        isLoading: false,
        userEmail: email,
      );
      return true;
    }

    state = state.copyWith(
      isLoading: false,
      error: 'Email ou mot de passe invalide',
    );
    return false;
  }

  Future<bool> signup(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    await Future.delayed(const Duration(milliseconds: 800));

    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      StorageService.isLoggedIn = true;
      StorageService.userName = name;
      StorageService.userEmail = email;
      state = state.copyWith(
        isLoggedIn: true,
        isLoading: false,
        userName: name,
        userEmail: email,
      );
      return true;
    }

    state = state.copyWith(
      isLoading: false,
      error: 'Veuillez remplir tous les champs correctement',
    );
    return false;
  }

  void logout() {
    StorageService.isLoggedIn = false;
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
