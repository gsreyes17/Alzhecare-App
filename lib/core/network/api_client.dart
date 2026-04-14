import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/session_storage.dart';

class ApiClient {
  ApiClient({required this.sessionStorage, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final SessionStorage sessionStorage;
  final http.Client _httpClient;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? queryParameters,
    String? tokenOverride,
  }) async {
    final response = await _httpClient.get(
      _buildUri(path, queryParameters),
      headers: await _headers(tokenOverride: tokenOverride),
    );
    return _decodeJsonResponse(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    String? tokenOverride,
  }) async {
    final response = await _httpClient.post(
      _buildUri(path),
      headers: await _headers(jsonBody: true, tokenOverride: tokenOverride),
      body: jsonEncode(body),
    );
    return _decodeJsonResponse(response);
  }

  Future<Map<String, dynamic>> patchJson(
    String path,
    Map<String, dynamic> body, {
    String? tokenOverride,
  }) async {
    final response = await _httpClient.patch(
      _buildUri(path),
      headers: await _headers(jsonBody: true, tokenOverride: tokenOverride),
      body: jsonEncode(body),
    );
    return _decodeJsonResponse(response);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Uint8List bytes,
    required String filename,
    Map<String, String>? fields,
    String? tokenOverride,
  }) async {
    final request = http.MultipartRequest('POST', _buildUri(path));
    request.headers.addAll(await _headers(tokenOverride: tokenOverride));
    if (fields != null) {
      request.fields.addAll(fields);
    }
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _decodeJsonResponse(response);
  }

  Uri _buildUri(String path, [Map<String, String>? queryParameters]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse(
      '${ApiConfig.baseUrl}$normalizedPath',
    ).replace(queryParameters: queryParameters);
  }

  Future<Map<String, String>> _headers({
    bool jsonBody = false,
    String? tokenOverride,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (jsonBody) {
      headers['Content-Type'] = 'application/json';
    }

    final token = tokenOverride ?? await sessionStorage.readToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Map<String, dynamic> _decodeJsonResponse(http.Response response) {
    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

    // Normaliza cualquier respuesta JSON a mapa para mantener estable la API interna.
    final body = switch (decoded) {
      Map _ => Map<String, dynamic>.from(decoded),
      List _ => <String, dynamic>{'items': decoded},
      null => <String, dynamic>{},
      _ => <String, dynamic>{'value': decoded},
    };

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final detail = body['detail'];
    final message = detail is String
        ? detail
        : 'Error HTTP ${response.statusCode}';
    throw ApiException(message, statusCode: response.statusCode, rawBody: body);
  }
}

class ApiException implements Exception {
  ApiException(this.message, {required this.statusCode, this.rawBody});

  final String message;
  final int statusCode;
  final Map<String, dynamic>? rawBody;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
