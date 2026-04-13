import 'dart:convert';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/models/customer.dart';

class CustomerRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  CustomerRepository({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  Future<String?> get _token => _tokenStorage.getToken();

  Future<List<Customer>> getAll() async {
    final token = await _token;
    final response = await _apiClient.get(ApiEndpoints.customers, token: token);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => Customer.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load customers');
  }

  Future<Customer> getById(String id) async {
    final token = await _token;
    final response = await _apiClient.get(ApiEndpoints.customerById(id), token: token);
    if (response.statusCode == 200) {
      return Customer.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Customer not found');
  }

  Future<List<Customer>> search(String name) async {
    final token = await _token;
    final response = await _apiClient.get(
      ApiEndpoints.searchCustomers(name),
      token: token,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => Customer.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Search failed');
  }

  Future<Customer> create(Map<String, dynamic> request) async {
    final token = await _token;
    final response = await _apiClient.post(
      ApiEndpoints.customers,
      request,
      token: token,
    );
    if (response.statusCode == 201) {
      return Customer.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to create customer');
  }

  Future<Customer> update(String id, Map<String, dynamic> request) async {
    final token = await _token;
    final response = await _apiClient.put(
      ApiEndpoints.customerById(id),
      request,
      token: token,
    );
    if (response.statusCode == 200) {
      return Customer.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to update customer');
  }

  Future<void> deactivate(String id) async {
    final token = await _token;
    final response = await _apiClient.delete(
      ApiEndpoints.customerById(id),
      token: token,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete customer');
    }
  }
}
