import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient apiClient;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDemoMode = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => apiClient.isAuthenticated || _isDemoMode;
  bool get isDemoMode => _isDemoMode;

  AuthProvider({required this.apiClient});

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      await apiClient.init();
      if (apiClient.isAuthenticated) {
        final res = await apiClient.get('/auth/me');
        if (res['success'] == true && res['user'] != null) {
          _user = UserModel.fromJson(res['user']);
        }
      }
    } catch (e) {
      debugPrint('[AuthProvider init Error] $e');
      // Token might have expired, clear it
      await apiClient.setToken(null);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post('/auth/login', {
        'email': email.trim(),
        'password': password,
      });

      if (res['success'] == true) {
        final token = res['token'];
        await apiClient.setToken(token);
        _user = UserModel.fromJson(res['user']);
        _isDemoMode = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post('/auth/register', {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      });

      if (res['success'] == true) {
        final token = res['token'];
        await apiClient.setToken(token);
        _user = UserModel.fromJson(res['user']);
        _isDemoMode = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await apiClient.setToken(null);
    _user = null;
    _isDemoMode = false;
    notifyListeners();
  }

  void enterDemoMode() {
    _isDemoMode = true;
    _user = UserModel(
      id: 'demo_user',
      name: 'Demo Account',
      email: 'demo@chelav.app',
      currency: 'INR',
    );
    notifyListeners();
  }
}
