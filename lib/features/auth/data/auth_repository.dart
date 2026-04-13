import 'dart:convert';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRepository({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  Future<void> login(String identifier, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.authLogin,
      {'identifier': identifier, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await _tokenStorage.saveAuth(
        token: data['token'] as String,
        username: data['username'] as String,
        role: data['role'] as String,
      );
    } else if (response.statusCode == 401) {
      throw Exception('Invalid username or password');
    } else {
      throw Exception('Login failed. Please try again.');
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearAuth();
  }

  Future<String?> getToken() => _tokenStorage.getToken();
  Future<String?> getUsername() => _tokenStorage.getUsername();
  Future<String?> getRole() => _tokenStorage.getRole();
  Future<bool> isLoggedIn() => _tokenStorage.hasToken();
}
