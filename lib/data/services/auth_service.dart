import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final String baseUrl;
  final http.Client _client;
  String? _accessToken;

  AuthService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? ApiConstants.baseUrl,
        _client = client ?? http.Client();

  String? get accessToken => _accessToken;

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  Future<AuthResponse> login({
    required String email,
    required String password,
    String deviceName = 'flutter',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl${ApiConstants.login}');

      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
              'device_name': deviceName,
            }),
          )
          .timeout(const Duration(milliseconds: ApiConstants.connectionTimeout));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(body);
        _accessToken = authResponse.accessToken;
        return authResponse;
      }

      if (response.statusCode == 401) {
        throw ApiException(
          body['message'] ?? 'Invalid credentials',
          statusCode: 401,
        );
      }

      if (response.statusCode == 422) {
        throw ApiException(
          body['message'] ?? 'Validation error',
          statusCode: 422,
          errors: body['errors'] as Map<String, dynamic>?,
        );
      }

      throw ApiException(
        body['message'] ?? 'Login failed',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Login failed: ${e.toString()}');
    }
  }

  /// Login as customer using customer_id + customer_name (first-time login without email)
  Future<AuthResponse> customerLogin({
    required String customerId,
    required String customerName,
    String deviceName = 'flutter',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl${ApiConstants.customerLogin}');

      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'customer_id': customerId,
              'customer_name': customerName,
              'device_name': deviceName,
            }),
          )
          .timeout(const Duration(milliseconds: ApiConstants.connectionTimeout));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(body);
        _accessToken = authResponse.accessToken;
        return authResponse;
      }

      if (response.statusCode == 401 || response.statusCode == 404) {
        throw ApiException(
          body['message'] ?? 'Customer not found or name does not match',
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode == 422) {
        throw ApiException(
          body['message'] ?? 'Validation error',
          statusCode: 422,
          errors: body['errors'] as Map<String, dynamic>?,
        );
      }

      throw ApiException(
        body['message'] ?? 'Customer login failed',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Customer login failed: ${e.toString()}');
    }
  }

  /// Complete profile - set email and password for first-time customer login
  Future<AuthResponse> completeProfile({
    required String email,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl${ApiConstants.completeProfile}');

      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'email': email,
              'new_password': newPassword,
              'new_password_confirmation': newPasswordConfirmation,
            }),
          )
          .timeout(const Duration(milliseconds: ApiConstants.connectionTimeout));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(body);
        _accessToken = authResponse.accessToken;
        return authResponse;
      }

      if (response.statusCode == 401) {
        throw ApiException(
          body['message'] ?? 'Unauthenticated',
          statusCode: 401,
        );
      }

      if (response.statusCode == 422) {
        throw ApiException(
          body['message'] ?? 'Validation error',
          statusCode: 422,
          errors: body['errors'] as Map<String, dynamic>?,
        );
      }

      throw ApiException(
        body['message'] ?? 'Complete profile failed',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Complete profile failed: ${e.toString()}');
    }
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl${ApiConstants.register}');

      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'name': name,
              'email': email,
            }),
          )
          .timeout(const Duration(milliseconds: ApiConstants.connectionTimeout));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Register doesn't return token, user needs to login with default password
        return AuthResponse.fromJson(body);
      }

      if (response.statusCode == 422) {
        throw ApiException(
          body['message'] ?? 'Validation error',
          statusCode: 422,
          errors: body['errors'] as Map<String, dynamic>?,
        );
      }

      throw ApiException(
        body['message'] ?? 'Register failed',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Register failed: ${e.toString()}');
    }
  }

  Future<AuthResponse> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl${ApiConstants.changePassword}');

      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'current_password': currentPassword,
              'new_password': newPassword,
              'new_password_confirmation': newPasswordConfirmation,
            }),
          )
          .timeout(const Duration(milliseconds: ApiConstants.connectionTimeout));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(body);
        _accessToken = authResponse.accessToken;
        return authResponse;
      }

      if (response.statusCode == 401) {
        throw ApiException(
          body['message'] ?? 'Unauthenticated',
          statusCode: 401,
        );
      }

      if (response.statusCode == 422) {
        throw ApiException(
          body['message'] ?? 'Validation error',
          statusCode: 422,
          errors: body['errors'] as Map<String, dynamic>?,
        );
      }

      throw ApiException(
        body['message'] ?? 'Change password failed',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Change password failed: ${e.toString()}');
    }
  }

  Future<User> getProfile() async {
    try {
      final uri = Uri.parse('$baseUrl${ApiConstants.me}');

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(milliseconds: ApiConstants.connectionTimeout));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return User.fromJson(body);
      }

      if (response.statusCode == 401) {
        throw ApiException('Unauthenticated', statusCode: 401);
      }

      throw ApiException(
        body['message'] ?? 'Failed to get profile',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get profile: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      final uri = Uri.parse('$baseUrl${ApiConstants.logout}');

      await _client
          .post(uri, headers: _headers)
          .timeout(const Duration(milliseconds: ApiConstants.connectionTimeout));

      _accessToken = null;
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      // Always clear token on logout attempt
      _accessToken = null;
      if (e is ApiException) rethrow;
    }
  }

  Future<String> refreshToken({String deviceName = 'flutter'}) async {
    if (_accessToken == null) {
      throw ApiException('Unauthenticated', statusCode: 401);
    }

    try {
      final uri = Uri.parse('$baseUrl${ApiConstants.refresh}');

      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({'device_name': deviceName}),
          )
          .timeout(const Duration(milliseconds: ApiConstants.connectionTimeout));

      final body = response.body.isNotEmpty
          ? (jsonDecode(response.body) as Map<String, dynamic>)
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final newToken = body['access_token'] as String?;
        if (newToken == null || newToken.isEmpty) {
          throw ApiException('Invalid refresh token response', statusCode: response.statusCode);
        }
        _accessToken = newToken;
        return newToken;
      }

      if (response.statusCode == 401) {
        throw ApiException(body['message'] ?? 'Unauthenticated', statusCode: 401);
      }

      throw ApiException(
        body['message'] ?? 'Refresh token failed',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Refresh token failed: ${e.toString()}');
    }
  }

  void dispose() {
    _client.close();
  }
}
