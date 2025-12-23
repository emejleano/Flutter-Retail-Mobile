import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class ApiService {
  final String baseUrl;
  final http.Client _client;
  String? _accessToken;
  Future<String?> Function()? _tokenRefresher;

  static final ApiService shared = ApiService._internal();

  ApiService({String? baseUrl, http.Client? client})
      : this._internal(baseUrl: baseUrl, client: client);

  ApiService._internal({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? ApiConstants.baseUrl,
        _client = client ?? http.Client();

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  void setTokenRefresher(Future<String?> Function()? refresher) {
    _tokenRefresher = refresher;
  }

  String? get accessToken => _accessToken;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  Future<http.Response> _sendWithRetryOn401(
    Future<http.Response> Function(Map<String, String> headers) send,
  ) async {
    final first = await send(_headers);

    if (first.statusCode == 401 && _tokenRefresher != null && _accessToken != null) {
      final newToken = await _tokenRefresher!.call();
      if (newToken != null && newToken.isNotEmpty) {
        setAccessToken(newToken);
        final second = await send(_headers);
        return second;
      }
    }

    return first;
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams?.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );

      final response = await _sendWithRetryOn401(
        (headers) => _client
            .get(uri, headers: headers)
            .timeout(const Duration(milliseconds: ApiConstants.connectionTimeout)),
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await _sendWithRetryOn401(
        (headers) => _client
            .post(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(
              const Duration(milliseconds: ApiConstants.connectionTimeout),
            ),
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await _sendWithRetryOn401(
        (headers) => _client
            .put(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(
              const Duration(milliseconds: ApiConstants.connectionTimeout),
            ),
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await _sendWithRetryOn401(
        (headers) => _client
            .patch(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(
              const Duration(milliseconds: ApiConstants.connectionTimeout),
            ),
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await _sendWithRetryOn401(
        (headers) => _client
            .delete(uri, headers: headers)
            .timeout(
              const Duration(milliseconds: ApiConstants.connectionTimeout),
            ),
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final String rawBody = response.body;
    dynamic decoded;
    if (rawBody.isNotEmpty) {
      try {
        decoded = jsonDecode(rawBody);
      } catch (_) {
        decoded = null;
      }
    }

    final Map<String, dynamic> body = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded == null || decoded is Map<String, dynamic>) {
        return body;
      }
      throw ApiException(
        'Unexpected response format',
        statusCode: response.statusCode,
      );
    }

    final fallbackMessage = rawBody.isNotEmpty
        ? (rawBody.length > 300 ? '${rawBody.substring(0, 300)}…' : rawBody)
        : 'Request failed';

    switch (response.statusCode) {
      case 400:
        throw ApiException(
          body['message'] ?? fallbackMessage,
          statusCode: 400,
          errors: body['errors'] as Map<String, dynamic>?,
        );
      case 401:
        throw ApiException(
          body['message'] ?? fallbackMessage,
          statusCode: 401,
        );
      case 403:
        throw ApiException(
          body['message'] ?? fallbackMessage,
          statusCode: 403,
        );
      case 404:
        throw ApiException(
          body['message'] ?? fallbackMessage,
          statusCode: 404,
        );
      case 422:
        throw ApiException(
          body['message'] ?? fallbackMessage,
          statusCode: 422,
          errors: body['errors'] as Map<String, dynamic>?,
        );
      case 500:
        throw ApiException(
          body['message'] ?? fallbackMessage,
          statusCode: 500,
        );
      default:
        throw ApiException(
          body['message'] ?? fallbackMessage,
          statusCode: response.statusCode,
        );
    }
  }

  Future<List<dynamic>> getList(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await _sendWithRetryOn401(
        (headers) => _client
            .get(uri, headers: headers)
            .timeout(const Duration(milliseconds: ApiConstants.connectionTimeout)),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List<dynamic>) return decoded;
        throw ApiException('Unexpected response format', statusCode: response.statusCode);
      }

      // Delegate error parsing through existing handler (expects object body)
      _handleResponse(response);
      return const <dynamic>[];
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  void dispose() {
    _client.close();
  }
}
