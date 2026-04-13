import 'dart:typed_data';

import '../network/api_client.dart';
import '../storage/token_storage.dart';
import 'document_service_web.dart'
    if (dart.library.io) 'document_service_mobile.dart';

class DocumentService {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  DocumentService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  Future<void> downloadAndOpenQuotation(
    String quotationId,
    String quotationNumber,
  ) async {
    final token = await _tokenStorage.getToken();

    final response = await _apiClient.getBytes(
      '/api/v1/quotations/$quotationId/document',
      token: token,
    );

    final bytes = response.bodyBytes;
    final fileName = '$quotationNumber.docx';

    await saveAndOpenFile(Uint8List.fromList(bytes), fileName);
  }
}
