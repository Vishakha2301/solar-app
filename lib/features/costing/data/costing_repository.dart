import 'dart:convert';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/models/saved_costing.dart';

class UnauthorizedException implements Exception {
  const UnauthorizedException();
}

class CostingRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  CostingRepository({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  Future<String?> get _token => _tokenStorage.getToken();

  void _checkUnauthorized(int statusCode) {
    if (statusCode == 401) throw const UnauthorizedException();
  }

  Future<List<SavedCosting>> getAll() async {
    final token = await _token;
    final response = await _apiClient.get(ApiEndpoints.costings, token: token);
    _checkUnauthorized(response.statusCode);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => SavedCosting.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load costings');
  }

  Future<SavedCosting> create(SavedCosting costing) async {
    final token = await _token;
    final response = await _apiClient.post(
      ApiEndpoints.costings,
      costing.toJson(),
      token: token,
    );
    _checkUnauthorized(response.statusCode);
    if (response.statusCode == 201) {
      return SavedCosting.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to create costing');
  }

  Future<SavedCosting> update(String id, SavedCosting costing) async {
    final token = await _token;
    final response = await _apiClient.put(
      ApiEndpoints.costingById(id),
      costing.toJson(),
      token: token,
    );
    _checkUnauthorized(response.statusCode);
    if (response.statusCode == 200) {
      return SavedCosting.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to update costing');
  }

  Future<void> delete(String id) async {
    final token = await _token;
    final response = await _apiClient.delete(
      ApiEndpoints.costingById(id),
      token: token,
    );
    _checkUnauthorized(response.statusCode);
    if (response.statusCode != 204) {
      throw Exception('Failed to delete costing');
    }
  }
}
