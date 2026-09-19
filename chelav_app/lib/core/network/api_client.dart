import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String _defaultUrlKey = 'chelav_api_base_url';
  static const String _tokenKey = 'chelav_auth_token';

  // Default base URL
  static String get defaultBaseUrl {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      if (origin.isNotEmpty && !origin.contains('localhost') && !origin.contains('127.0.0.1')) {
        return '$origin/api';
      }
      return 'http://localhost:5001/api';
    }
    return 'http://10.0.2.2:5001/api'; // Android emulator localhost
  }

  String _baseUrl = defaultBaseUrl;
  String? _token;

  String get baseUrl => _baseUrl;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(_defaultUrlKey) ?? defaultBaseUrl;
    _token = prefs.getString(_tokenKey);
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    if (!_baseUrl.endsWith('/api')) {
      _baseUrl = '$_baseUrl/api';
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultUrlKey, _baseUrl);
  }

  Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, token);
    }
  }

  Map<String, String> _headers() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams);
    try {
      final res = await http.get(uri, headers: _headers()).timeout(const Duration(seconds: 8));
      return _processResponse(res);
    } catch (e) {
      debugPrint('[ApiClient GET Error] $endpoint: $e');
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, dynamic body) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    try {
      final res = await http
          .post(uri, headers: _headers(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 8));
      return _processResponse(res);
    } catch (e) {
      debugPrint('[ApiClient POST Error] $endpoint: $e');
      rethrow;
    }
  }

  Future<dynamic> put(String endpoint, dynamic body) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    try {
      final res = await http
          .put(uri, headers: _headers(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 8));
      return _processResponse(res);
    } catch (e) {
      debugPrint('[ApiClient PUT Error] $endpoint: $e');
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    try {
      final res = await http.delete(uri, headers: _headers()).timeout(const Duration(seconds: 8));
      return _processResponse(res);
    } catch (e) {
      debugPrint('[ApiClient DELETE Error] $endpoint: $e');
      rethrow;
    }
  }

  dynamic _processResponse(http.Response res) {
    dynamic json;
    try {
      json = jsonDecode(res.body);
    } catch (_) {
      json = {'message': res.body};
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json;
    } else {
      final msg = json is Map && json['message'] != null ? json['message'] : 'Server error: ${res.statusCode}';
      throw ApiException(msg, statusCode: res.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, {this.statusCode = 500});

  @override
  String toString() => message;
}
