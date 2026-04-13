import 'dart:convert';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/models/quotation.dart';

class QuotationRepository {
  final ApiClient _client;

  QuotationRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<List<Quotation>> getAll() async {
    final response = await _client.get(ApiEndpoints.quotations);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Quotation.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Quotation>> getByStatus(String status) async {
    final response = await _client.get(ApiEndpoints.quotationsByStatus(status));
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Quotation.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Quotation> create(Map<String, dynamic> request) async {
    final response = await _client.post(ApiEndpoints.quotations, request);
    return Quotation.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Quotation> update(String id, Map<String, dynamic> request) async {
    final response = await _client.put(ApiEndpoints.quotationById(id), request);
    return Quotation.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Quotation> submit(String id) async {
    final response = await _client.post(ApiEndpoints.submitQuotation(id), {});
    return Quotation.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Quotation> approve(String id, String? approvalNotes) async {
    final response = await _client.post(
      ApiEndpoints.approveQuotation(id, approvalNotes),
      {},
    );
    return Quotation.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Quotation> reject(String id, String rejectionReason) async {
    final response = await _client.post(
      ApiEndpoints.rejectQuotation(id, rejectionReason),
      {},
    );
    return Quotation.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Quotation> cancel(String id) async {
    final response = await _client.post(ApiEndpoints.cancelQuotation(id), {});
    return Quotation.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _client.delete(ApiEndpoints.quotationById(id));
  }
}
