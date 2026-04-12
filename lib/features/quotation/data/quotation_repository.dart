import '../../../core/network/api_client.dart';
import '../domain/models/quotation.dart';

class QuotationRepository {
  final ApiClient _client;

  QuotationRepository({ApiClient? client})
      : _client = client ?? ApiClient();

  Future<List<Quotation>> getAll() async {
    final response = await _client.get('/api/v1/quotations');
    return (response as List).map((e) => Quotation.fromJson(e)).toList();
  }

  Future<List<Quotation>> getByStatus(String status) async {
    final response =
        await _client.get('/api/v1/quotations/status/$status');
    return (response as List).map((e) => Quotation.fromJson(e)).toList();
  }

  Future<Quotation> create(Map<String, dynamic> request) async {
    final response = await _client.post('/api/v1/quotations', request);
    return Quotation.fromJson(response);
  }

  Future<Quotation> update(String id, Map<String, dynamic> request) async {
    final response =
        await _client.put('/api/v1/quotations/$id', request);
    return Quotation.fromJson(response);
  }

  Future<Quotation> submit(String id) async {
    final response =
        await _client.post('/api/v1/quotations/$id/submit', {});
    return Quotation.fromJson(response);
  }

  Future<Quotation> approve(String id, String? approvalNotes) async {
    final query =
        approvalNotes != null ? '?approvalNotes=$approvalNotes' : '';
    final response = await _client
        .post('/api/v1/quotations/$id/approve$query', {});
    return Quotation.fromJson(response);
  }

  Future<Quotation> reject(String id, String rejectionReason) async {
    final response = await _client.post(
        '/api/v1/quotations/$id/reject?rejectionReason=$rejectionReason',
        {});
    return Quotation.fromJson(response);
  }

  Future<Quotation> cancel(String id) async {
    final response =
        await _client.post('/api/v1/quotations/$id/cancel', {});
    return Quotation.fromJson(response);
  }

  Future<void> delete(String id) async {
    await _client.delete('/api/v1/quotations/$id');
  }
}
