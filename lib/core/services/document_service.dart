import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../storage/token_storage.dart';

class DocumentService {
  static const String _baseUrl = 'http://localhost:8080';

  final Dio _dio;
  final TokenStorage _tokenStorage;

  DocumentService({
    Dio? dio,
    TokenStorage? tokenStorage,
  })  : _dio = dio ?? Dio(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  Future<void> downloadAndOpenQuotation(String quotationId,
      String quotationNumber) async {
    final token = await _tokenStorage.getToken();

    final response = await _dio.get(
      '$_baseUrl/api/v1/quotations/$quotationId/document',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
        responseType: ResponseType.bytes,
      ),
    );

    // Get temp directory
    final directory = await getTemporaryDirectory();
    final filePath =
        '${directory.path}/$quotationNumber.docx';

    // Write file
    final file = File(filePath);
    await file.writeAsBytes(response.data);

    // Open file
    await OpenFilex.open(filePath);
  }
}
