import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/models/quotation.dart';

class QuotationRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  QuotationRepository({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  Future<String?> get _token => _tokenStorage.getToken();

  Future<List<Quotation>> getAll() async {
    final token = await _token;
    final response =
        await _apiClient.get('/api/v1/quotations', token: token);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => Quotation.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load quotations');
  }

  Future<Quotation> getById(String id) async {
    final token = await _token;
    final response =
        await _apiClient.get('/api/v1/quotations/$id', token: token);
    if (response.statusCode == 200) {
      return Quotation.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Quotation not found');
  }

  Future<List<Quotation>> getByStatus(String status) async {
    final token = await _token;
    final response = await _apiClient.get(
        '/api/v1/quotations/status/$status',
        token: token);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => Quotation.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load quotations by status');
  }

  Future<List<Quotation>> getByCustomer(String customerId) async {
    final token = await _token;
    final response = await _apiClient.get(
        '/api/v1/quotations/customer/$customerId',
        token: token);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => Quotation.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load quotations by customer');
  }

  Future<Quotation> create(Map<String, dynamic> request) async {
    final token = await _token;
    final response = await _apiClient.post(
      '/api/v1/quotations',
      request,
      token: token,
    );
    if (response.statusCode == 201) {
      return Quotation.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to create quotation');
  }

  Future<Quotation> update(String id, Map<String, dynamic> request) async {
    final token = await _token;
    final response = await _apiClient.put(
      '/api/v1/quotations/$id',
      request,
      token: token,
    );
    if (response.statusCode == 200) {
      return Quotation.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to update quotation');
  }

  Future<Quotation> submit(String id) async {
    final token = await _token;
    final response = await _apiClient.post(
      '/api/v1/quotations/$id/submit',
      {},
      token: token,
    );
    if (response.statusCode == 200) {
      return Quotation.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to submit quotation');
  }

  Future<Quotation> approve(String id, String? approvalNotes) async {
    final token = await _token;
    final url = approvalNotes != null
        ? '/api/v1/quotations/$id/approve?approvalNotes=$approvalNotes'
        : '/api/v1/quotations/$id/approve';
    final response = await _apiClient.post(url, {}, token: token);
    if (response.statusCode == 200) {
      return Quotation.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to approve quotation');
  }

  Future<Quotation> reject(String id, String rejectionReason) async {
    final token = await _token;
    final response = await _apiClient.post(
      '/api/v1/quotations/$id/reject?rejectionReason=$rejectionReason',
      {},
      token: token,
    );
    if (response.statusCode == 200) {
      return Quotation.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to reject quotation');
  }

  Future<void> delete(String id) async {
    final token = await _token;
    final response = await _apiClient.delete(
      '/api/v1/quotations/$id',
      token: token,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete quotation');
    }
  }
}