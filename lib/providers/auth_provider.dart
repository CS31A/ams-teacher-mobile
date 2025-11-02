import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../providers/services_provider.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final String? instructorId;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.instructorId,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    String? instructorId,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      instructorId: instructorId ?? this.instructorId,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier({
    required ApiService apiService,
  })  : _apiService = apiService,
        super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isAuthenticated = await StorageService.isAuthenticated();
    final instructorId = await StorageService.getInstructorId();

    state = state.copyWith(
      isAuthenticated: isAuthenticated,
      instructorId: instructorId,
    );
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.login(username, password);

      if (response['success'] == true && response['accessToken'] != null) {
        await StorageService.saveTokens(
          response['accessToken'] as String,
          response['refreshToken'] as String? ?? '',
        );

        // Fetch instructor profile to get ID
        try {
          final profileResponse = await _apiService.getInstructorProfile();

          if (profileResponse['success'] == true && profileResponse['data'] != null) {
            final profileData = profileResponse['data'] as Map<String, dynamic>;
            String? instructorId;
            
            if (profileData['id'] != null) {
              instructorId = profileData['id'].toString();
            } else if (profileData['Id'] != null) {
              instructorId = profileData['Id'].toString();
            }

            if (instructorId != null) {
              await StorageService.saveInstructorId(instructorId);
            }
          }
        } catch (profileError) {
          // Continue anyway, sections will load via JWT token
        }

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response['message'] as String? ?? 'Login failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to connect to server. Please check your internet connection.',
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      final token = await StorageService.getAccessToken();
      if (token != null) {
        await _apiService.logout(token);
      }
    } catch (e) {
      // Continue with logout even if API call fails
    }

    await StorageService.clearAll();
    state = const AuthState();
  }

  Future<void> checkAuth() async {
    await _checkAuthStatus();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    apiService: ref.watch(apiServiceProvider),
  );
});

