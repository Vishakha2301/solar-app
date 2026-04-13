import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String path, {String? token}) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: headers,
    );
  }

  Future<http.Response> getBytes(String path, {String? token}) async {
    final headers = {
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: headers,
    );
  }

  Future<http.Response> put(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return _client.put(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String path, {String? token}) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return _client.delete(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: headers,
    );
  }
}
