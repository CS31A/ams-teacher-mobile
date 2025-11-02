import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginState {
  final bool isLoading;
  final String? errorMessage;
  final bool isPasswordVisible;

  const LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.isPasswordVisible = false,
  });

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isPasswordVisible,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }
}

class LoginNotifier extends StateNotifier<LoginState> {
  final Ref _ref;

  LoginNotifier({
    required Ref ref,
  })  : _ref = ref,
        super(const LoginState());

  void togglePasswordVisibility() {
    state = state.copyWith(
      isPasswordVisible: !state.isPasswordVisible,
    );
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      await _ref.read(authProvider.notifier).login(username, password);
      
      final authState = _ref.read(authProvider);
      
      if (!authState.isAuthenticated) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: authState.error ?? 'Login failed',
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to connect to server. Please check your internet connection.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(ref: ref);
});

