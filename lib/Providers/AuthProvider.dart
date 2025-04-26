import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:police_app/config.dart' as config;

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _officerId = '';
  String _officerName = '';
  String _policeStation = '';
  String _officerRank = '';
  String _contact = '';
  String _email = '';
  String _token = ''; // JWT token for authentication
  bool _isLoading = false;
  String _error = '';

  // API URL - replace with your actual backend URL
  final String _baseUrl = config.baseUrl;
  // final String _baseUrl = 'https://police-app-backend-vos8.vercel.app';

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String get officerId => _officerId;
  String get officerName => _officerName;
  String get policeStation => _policeStation;
  String get officerRank => _officerRank;
  String get contactNumber => _contact;
  String get email => _email;
  String get token => _token;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Login method
  Future<bool> login(String officerSVC, String password) async {
    try {
      print('Attempting login for officerSVC: $officerSVC');
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'officerSVC': officerSVC, 'Password': password}),
      );
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _isLoggedIn = true;
        _token = data["data"]['token'];
        _officerId = data["data"]['officerSVC'];
        _officerName = data["data"]['fullName'];
        _policeStation = data["data"]['policeStation'];

        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token);
        await prefs.setString('officerSVC', _officerId);
        notifyListeners();
        print('Login successful');
        return true;
      }
      print('Login failed');
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Registration method
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      print('Attempting registration with data: $userData');
      final response = await http.post(
        Uri.parse('$_baseUrl/registration'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );
      print('Registration response status: ${response.statusCode}');
      print('Registration response body: ${response.body}');

      final data = jsonDecode(response.body);
      final message = data["success"] ?? "Unknown response";
      final error = data["error"] ?? "Unknown Error";

      if (response.statusCode == 201) {
        print(data["data"]);
        _isLoggedIn = true;
        _token = data["data"]['token'];
        _officerId = data["data"]['officerSVC'];
        _officerName = data["data"]['fullName'];
        _policeStation = data["data"]['policeStation'];

        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token);
        await prefs.setString('officerSVC', _officerId);

        notifyListeners();
        print('Registration successful');

        return {'success': true, 'message': message};
      }

      print('Registration failed');
      return {'success': false, 'message': error};
    } catch (e) {
      print('Registration error: $e');
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}'
      };
    }
  }

  // Logout method
  Future<void> logout() async {
    print('Logging out user $_officerId');
    _isLoggedIn = false;
    _officerId = '';
    _officerName = '';
    _policeStation = '';
    _token = '';

    // Remove token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('officerSVC');
    notifyListeners();
    print('User logged out');
  }

  // Check token validity and auto-login
  Future<bool> tryAutoLogin() async {
    try {
      // Get token from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final officerSVC = prefs.getString('officerSVC');

      print(token);
      print(officerSVC);

      if (token == null || officerSVC == null) {
        return false;
      }

      // Set token to class variable
      _token = token;

      print('Attempting auto-login with token: $token');
      final response = await http.post(
        Uri.parse('$_baseUrl/verify'),
        headers: {'Authorization': 'Bearer $token'},
        body: jsonEncode({'officerSVC': officerSVC}),
      );
      print('Auto-login response status: ${response.statusCode}');
      print('Auto-login response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _isLoggedIn = true;
        _officerId = data["data"]['officerSVC'];
        _officerName = data["data"]['fullName'];
        _policeStation = data["data"]['policeStation'];
        notifyListeners();
        print('Auto-login successful');
        return true;
      }
      print('Auto-login failed');
      return false;
    } catch (e) {
      print('Auto-login error: $e');
      return false;
    }
  }

  Future<bool> updateProfile({
    required String officerId,
    String? fullName,
    String? policeStation,
    String? rank,
    String? contactNumber,
    String? email,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final updateData = {
        'officerSVC': officerId,
        if (fullName != null) 'fullName': fullName,
        if (policeStation != null) 'policeStation': policeStation,
        if (rank != null) 'officerRank': rank,
        if (contactNumber != null) 'contactNumber': contactNumber,
        if (email != null) 'email': email,
      };

      print('Updating profile with data: $updateData');
      final response = await http.post(
        Uri.parse('$_baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(updateData),
      );
      print('Update profile response: ${response.statusCode}');
      print('Update profile body: ${response.body}');

      _isLoading = false;

      if (response.statusCode == 200) {
        print('Profile updated successfully');
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['error'] ?? 'Failed to update profile';
        print('Failed to update profile: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error updating profile: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> getProfileDetails(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      print('Get profile response: ${response.statusCode}');
      print('Get profile body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _officerId = data["data"]['officerSVC'];
        _officerName = data["data"]['fullName'];
        _policeStation = data["data"]['policeStation'];
        _officerRank = data["data"]['officerRank'];
        _contact = data["data"]['contactNumber'];
        _email = data["data"]['email'];

        notifyListeners();
        print(data["data"]);
        return data["data"];
      } else {
        print('Failed to fetch profile');
        return {};
      }
    } catch (e) {
      print('Error fetching profile: $e');
      return {};
    }
  }
}
