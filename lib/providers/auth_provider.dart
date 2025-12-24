import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';
import '../data/services/api_service.dart';

enum UserRole { admin, customer }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _mustChangePassword = false;
  UserRole _role = UserRole.customer;
  String _userName = '';
  String _userEmail = '';
  String? _accessToken;
  String? _errorMessage;
  User? _user;
  String? _defaultPassword; // Shown after register
  
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get mustChangePassword => _mustChangePassword;
  UserRole get role => _role;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String? get accessToken => _accessToken;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  bool get isAdmin => _role == UserRole.admin;
  String? get defaultPassword => _defaultPassword;
  
  /// Get customer ID for orders. Uses user ID to generate customer reference.
  /// In real app, this would come from API linking user to dim_customer.
  String? get customerId {
    if (_user != null) {
      // Generate customer ID based on user initials and ID
      final initials = _userName.split(' ')
          .take(2)
          .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
          .join('');
      return '$initials-${_user!.id.toString().padLeft(5, '0')}';
    }
    return null;
  }
  
  AuthProvider() {
    _loadAuthState();

    ApiService.shared.setTokenRefresher(() async {
      final newToken = await refreshToken();
      return newToken;
    });
  }
  
  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
    final roleString = prefs.getString(AppConstants.keyUserRole) ?? 'customer';
    _role = roleString == 'admin' ? UserRole.admin : UserRole.customer;
    _userName = prefs.getString(AppConstants.keyUserName) ?? '';
    _userEmail = prefs.getString('user_email') ?? '';
    _accessToken = prefs.getString('access_token');
    
    if (_accessToken != null) {
      _authService.setAccessToken(_accessToken);
      ApiService.shared.setAccessToken(_accessToken);
    }
    
    notifyListeners();
  }
  
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _defaultPassword = null;
    notifyListeners();
    
    try {
      final authResponse = await _authService.login(
        email: email,
        password: password,
      );
      
      _user = authResponse.user;
      _accessToken = authResponse.accessToken;
      _mustChangePassword = authResponse.mustChangePassword;
      ApiService.shared.setAccessToken(_accessToken);
      _role = authResponse.user.role == 'admin' ? UserRole.admin : UserRole.customer;
      _userName = authResponse.user.name;
      _userEmail = authResponse.user.email;
      _isLoggedIn = true;
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await prefs.setString(
        AppConstants.keyUserRole,
        _role == UserRole.admin ? 'admin' : 'customer',
      );
      await prefs.setString(AppConstants.keyUserName, _userName);
      await prefs.setString('user_email', _userEmail);
      await prefs.setString('access_token', _accessToken!);
      await prefs.setBool('must_change_password', _mustChangePassword);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login as customer using customer_id + customer_name (first-time login without email)
  Future<bool> customerLogin(String customerId, String customerName) async {
    _isLoading = true;
    _errorMessage = null;
    _defaultPassword = null;
    notifyListeners();

    try {
      final authResponse = await _authService.customerLogin(
        customerId: customerId,
        customerName: customerName,
      );

      _user = authResponse.user;
      _accessToken = authResponse.accessToken;
      _mustChangePassword = authResponse.mustChangePassword;
      ApiService.shared.setAccessToken(_accessToken);
      _role = authResponse.user.role == 'admin' ? UserRole.admin : UserRole.customer;
      _userName = authResponse.user.name;
      _userEmail = authResponse.user.email;
      _isLoggedIn = true;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await prefs.setString(
        AppConstants.keyUserRole,
        _role == UserRole.admin ? 'admin' : 'customer',
      );
      await prefs.setString(AppConstants.keyUserName, _userName);
      await prefs.setString('user_email', _userEmail);
      await prefs.setString('access_token', _accessToken!);
      await prefs.setBool('must_change_password', _mustChangePassword);

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Customer login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Complete profile - set email and password (for first-time customer login)
  Future<bool> completeProfile({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await _authService.completeProfile(
        email: email,
        newPassword: newPassword,
        newPasswordConfirmation: confirmPassword,
      );

      // Update token and user after profile completion
      _accessToken = authResponse.accessToken;
      _user = authResponse.user;
      _userEmail = email;
      _mustChangePassword = false;
      ApiService.shared.setAccessToken(_accessToken);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', _accessToken!);
      await prefs.setString('user_email', email);
      await prefs.setBool('must_change_password', false);

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Complete profile failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.logout();
    } catch (e) {
      // Ignore logout errors, still clear local state
    }
    
    _isLoggedIn = false;
    _mustChangePassword = false;
    _role = UserRole.customer;
    _userName = '';
    _userEmail = '';
    _accessToken = null;
    _defaultPassword = null;
    ApiService.shared.setAccessToken(null);
    _user = null;
    _errorMessage = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyIsLoggedIn);
    await prefs.remove(AppConstants.keyUserRole);
    await prefs.remove(AppConstants.keyUserName);
    await prefs.remove('user_email');
    await prefs.remove('access_token');
    await prefs.remove('must_change_password');
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> refreshProfile() async {
    if (_accessToken == null) return;
    
    try {
      _user = await _authService.getProfile();
      _userName = _user!.name;
      _userEmail = _user!.email;
      _role = _user!.role == 'admin' ? UserRole.admin : UserRole.customer;
      _mustChangePassword = _user!.mustChangePassword;
      notifyListeners();
    } catch (e) {
      // If refresh fails, user might need to re-login
      if (e is ApiException && e.statusCode == 401) {
        await logout();
      }
    }
  }

  Future<String?> refreshToken() async {
    if (_accessToken == null) return null;

    try {
      final newToken = await _authService.refreshToken();
      _accessToken = newToken;
      ApiService.shared.setAccessToken(newToken);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', newToken);

      notifyListeners();
      return newToken;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await logout();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Register new customer account (name + email only)
  /// Returns true if successful, user should then login with default password
  Future<bool> register({
    required String name,
    required String email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _defaultPassword = null;
    notifyListeners();

    try {
      final authResponse = await _authService.register(
        name: name,
        email: email,
      );

      // Register doesn't log user in, just returns the default password info
      _defaultPassword = authResponse.defaultPassword ?? 'password';
      _userEmail = email;
      _userName = name;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Register failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Change password (required after first login with default password)
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: confirmPassword,
      );

      // Update token and user after password change
      _accessToken = authResponse.accessToken;
      _user = authResponse.user;
      _mustChangePassword = false;
      ApiService.shared.setAccessToken(_accessToken);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', _accessToken!);
      await prefs.setBool('must_change_password', false);

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Change password failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearDefaultPassword() {
    _defaultPassword = null;
    notifyListeners();
  }
}
