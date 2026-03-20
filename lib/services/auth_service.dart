import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const String _tenantKey = 'auth_tenant';

  User? _currentUser;
  String? _token;
  String? _tenantId;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  String? get token => _token;
  String? get tenantId => _tenantId;
  bool get isAuthenticated => _token != null && _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _tenantId = prefs.getString(_tenantKey);
    
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        _currentUser = User.fromJson(Map<String, dynamic>.from(
          Uri.splitQueryString(userJson).map((k, v) => MapEntry(k, v)),
        ));
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final api = ApiService();
      final response = await api.post('/auth/login', body: {
        'email': email,
        'password': password,
      });

      _token = response['access_token'] ?? response['token'];
      _tenantId = response['tenant_id'] ?? 'demo-tenant';
      _currentUser = response['user'] != null
          ? User.fromJson(response['user'])
          : User(
              id: response['user_id'] ?? 'demo-user',
              email: email,
              firstName: email.split('@').first,
              lastName: '',
              role: response['role'] ?? 'employee',
              tenantId: _tenantId!,
            );

      await _saveCredentials();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> demoLogin(String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _token = 'demo-token-${DateTime.now().millisecondsSinceEpoch}';
      _tenantId = 'demo-tenant';

      switch (role) {
        case 'employee':
          _currentUser = User(
            id: 'demo-employee-001',
            email: 'employee@demo.com',
            firstName: 'John',
            lastName: 'Employee',
            role: 'employee',
            tenantId: _tenantId!,
          );
          break;
        case 'manager':
          _currentUser = User(
            id: 'demo-manager-001',
            email: 'manager@demo.com',
            firstName: 'Jane',
            lastName: 'Manager',
            role: 'manager',
            tenantId: _tenantId!,
          );
          break;
        case 'hr':
          _currentUser = User(
            id: 'demo-hr-001',
            email: 'hr@demo.com',
            firstName: 'HR',
            lastName: 'Admin',
            role: 'hr_admin',
            tenantId: _tenantId!,
          );
          break;
        case 'admin':
          _currentUser = User(
            id: 'demo-admin-001',
            email: 'admin@demo.com',
            firstName: 'System',
            lastName: 'Admin',
            role: 'admin',
            tenantId: _tenantId!,
          );
          break;
        default:
          _currentUser = User(
            id: 'demo-user-001',
            email: 'user@demo.com',
            firstName: 'Demo',
            lastName: 'User',
            role: 'employee',
            tenantId: _tenantId!,
          );
      }

      await _saveCredentials();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    _tenantId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_tenantKey);

    notifyListeners();
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString(_tokenKey, _token!);
    }
    if (_tenantId != null) {
      await prefs.setString(_tenantKey, _tenantId!);
    }
    if (_currentUser != null) {
      final userJson = _currentUser!.toJson().entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      await prefs.setString(_userKey, userJson);
    }
  }

  ApiService get api => ApiService(tenantId: _tenantId, authToken: _token);

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
