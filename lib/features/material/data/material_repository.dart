import 'dart:convert';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/models/material_item.dart';

class MaterialRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  MaterialRepository({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  Future<String?> get _token => _tokenStorage.getToken();

  Future<List<MaterialItem>> getAll() async {
    final token = await _token;
    final response = await _apiClient.get(ApiEndpoints.materials, token: token);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => MaterialItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load materials');
  }

  Future<List<MaterialItem>> getByCategory(String category) async {
    final token = await _token;
    final response = await _apiClient.get(
      ApiEndpoints.materialsByCategory(category),
      token: token,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => MaterialItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load materials by category');
  }

  Future<List<MaterialItem>> getByComponentKey(String componentKey) async {
    final token = await _token;
    final response = await _apiClient.get(
      ApiEndpoints.materialsByComponentKey(componentKey),
      token: token,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => MaterialItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load materials by component key');
  }

  Future<List<MaterialItem>> search(String brandName) async {
    final token = await _token;
    final response = await _apiClient.get(
      ApiEndpoints.searchMaterials(brandName),
      token: token,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => MaterialItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Search failed');
  }

  Future<List<MaterialCategoryInfo>> getCategories() async {
    final token = await _token;
    final response = await _apiClient.get(
      ApiEndpoints.materialCategories,
      token: token,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => MaterialCategoryInfo.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load categories');
  }

  Future<MaterialItem> create(Map<String, dynamic> request) async {
    final token = await _token;
    final response = await _apiClient.post(
      ApiEndpoints.materials,
      request,
      token: token,
    );
    if (response.statusCode == 201) {
      return MaterialItem.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to create material');
  }

  Future<MaterialItem> update(String id, Map<String, dynamic> request) async {
    final token = await _token;
    final response = await _apiClient.put(
      ApiEndpoints.materialById(id),
      request,
      token: token,
    );
    if (response.statusCode == 200) {
      return MaterialItem.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to update material');
  }

  Future<void> deactivate(String id) async {
    final token = await _token;
    final response = await _apiClient.delete(
      ApiEndpoints.materialById(id),
      token: token,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete material');
    }
  }
}
