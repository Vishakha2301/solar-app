import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'document_service_web.dart'
    if (dart.library.io) 'document_service_mobile.dart';

class DocumentService {
  static const String _baseUrl = 'http://localhost:8080';

  final Dio _dio;
  final TokenStorage _tokenStorage;

  DocumentService({
    Dio? dio,
    TokenStorage? tokenStorage,
  })  : _dio = dio ?? Dio(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  Future<void> downloadAndOpenQuotation(
      String quotationId, String quotationNumber) async {
    final token = await _tokenStorage.getToken();

    final response = await _dio.get(
      '$_baseUrl/api/v1/quotations/$quotationId/document',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        responseType: ResponseType.bytes,
      ),
    );

    final bytes = Uint8List.fromList(response.data);
    final fileName = '$quotationNumber.docx';

    await saveAndOpenFile(bytes, fileName);
  }
}

