import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String local = 'http://192.168.18.8:8000';
  static const String produccion = 'https://backendalzheimer.onrender.com';

  static String get baseUrl => _currentUrl;
  static String _currentUrl = local;

  static const String _urlKey = 'selectedBackendUrl';

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUrl = prefs.getString(_urlKey) ?? local;
  }

  static Future<void> changeBaseUrl(String newUrl) async {
    _currentUrl = newUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_urlKey, newUrl);
  }

  static Map<String, String> getAvailableUrls() {
    return {'Local': local, 'Producción': produccion};
  }

  static String getCurrentUrlName() {
    final urls = getAvailableUrls();
    return urls.entries
        .firstWhere(
          (entry) => entry.value == _currentUrl,
          orElse: () => MapEntry('Personalizado', _currentUrl),
        )
        .key;
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  static Future<Map<String, String>> _buildHeaders({bool includeAuth = true}) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (includeAuth) {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    Uri uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    return http.get(uri, headers: await _buildHeaders());
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        ...await _buildHeaders(),
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );
  }

  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    return http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        ...await _buildHeaders(),
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );
  }

  static Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    return http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        ...await _buildHeaders(),
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    return http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _buildHeaders(),
    );
  }

  static Future<http.Response> multipartRequest(
    String endpoint,
    File imageFile,
    {Map<String, String>? fields}
  ) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));

    request.headers.addAll(await _buildHeaders());
    if (fields != null && fields.isNotEmpty) {
      request.fields.addAll(fields);
    }
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: 'imagen_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
    );

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
