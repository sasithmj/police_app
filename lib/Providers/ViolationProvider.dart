import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:police_app/config.dart' as config;
class ViolationProvider with ChangeNotifier {
  // API URL - use the same base URL as AuthProvider
  final String _baseUrl = config.baseUrl;
  // final String _baseUrl = 'https://police-app-backend-vos8.vercel.app';
  String _token = '';
  List<Map<String, dynamic>> _violations = [];
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<Map<String, dynamic>> get violations => _violations;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Set token from AuthProvider
  void setToken(String token) {
    _token = token;
  }

  // Create a new violation
  Future<bool> createViolation(Map<String, dynamic> formData) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print('Creating violation with data: $formData');

      final response = await http.post(
        Uri.parse('$_baseUrl/violations/violation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token'
        },
        body: jsonEncode({'formData': formData}),
      );
      print('Create violation response status: ${response.statusCode}');
      print('Create violation response body: ${response.body}');

      _isLoading = false;

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Violation created successfully');
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['error'] ?? 'Failed to create violation';
        print('Violation creation failed: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error creating violation: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> getViolationById(String id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print('Fetching violation with ID: $id');
      final response = await http.get(
        Uri.parse('$_baseUrl/violations/violation/$id'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      print('Get violation response status: ${response.statusCode}');
      print('Get violation response body: ${response.body}');

      _isLoading = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final violation = Map<String, dynamic>.from(data['violation']);
        print('Violation fetched: $violation');
        notifyListeners();
        return violation;
      } else {
        final data = jsonDecode(response.body);
        _error = data['error'] ?? 'Failed to fetch violation';
        print('Failed to fetch violation: $_error');
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching violation: $e';
      print(_error);
      notifyListeners();
      return null;
    }
  }

  Future<bool> getViolationsByOfficer(String officerId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print('Fetching violations for officer: $officerId');
      final response = await http.post(
        Uri.parse('$_baseUrl/violations/officer'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'officerId': officerId}),
      );
      print('Get violations by officer response: ${response.statusCode}');
      print('Get violations by officer body: ${response.body}');

      _isLoading = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _violations = List<Map<String, dynamic>>.from(data['violations']);
        print('Retrieved ${_violations.length} violations for officer');
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['error'] ?? 'Failed to fetch officer violations';
        print('Failed to fetch officer violations: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching officer violations: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  // Get violations with optional filters
  Future<bool> getViolations({
    String? id,
    String? touristName,
    String? touristPassport,
    String? touristCountry,
    String? violationType,
    String? violationDate,
    String? officerId,
    String? status,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Build filter object based on provided parameters
      final Map<String, dynamic> filters = {};

      if (id != null) filters['_id'] = id;
      if (touristName != null) filters['tourist.name'] = touristName;
      if (touristPassport != null) filters['tourist.passport'] = touristPassport;
      if (touristCountry != null) filters['tourist.country'] = touristCountry;
      if (violationType != null) filters['violation.type'] = violationType;
      if (violationDate != null) filters['violation.date'] = violationDate;
      if (officerId != null) filters['officer.id'] = officerId;
      if (status != null) filters['status'] = status;

      print('Getting violations with filters: $filters');
      final response = await http.post(
        Uri.parse('$_baseUrl/violations/getviolation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token'
        },
        body: jsonEncode(filters),
      );
      print('Get violations response status: ${response.statusCode}');
      print('Get violations response body: ${response.body}');

      _isLoading = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _violations = List<Map<String, dynamic>>.from(data['violations']);
        print('Retrieved ${_violations.length} violations');
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['error'] ?? 'Failed to fetch violations';
        print('Failed to fetch violations: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching violations: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  // Update violation status
  Future<bool> updateViolationStatus(String violationId, String status,
      Map<String, dynamic>? paymentDetails) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print('Updating violation status: ID=$violationId, status=$status');
      final response = await http.put(
        Uri.parse('$_baseUrl/violation/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token'
        },
        body: jsonEncode({
          'violationId': violationId,
          'status': status,
          if (paymentDetails != null) 'paymentDetails': paymentDetails,
        }),
      );
      print('Update violation status response: ${response.statusCode}');
      print('Update violation status body: ${response.body}');

      _isLoading = false;

      if (response.statusCode == 200) {
        // Update the local violation in the list if it exists
        final index = _violations.indexWhere((v) => v['_id'] == violationId);
        if (index != -1) {
          _violations[index]['status'] = status;
          if (paymentDetails != null) {
            _violations[index]['paymentDetails'] = paymentDetails;
          }
        }

        print('Violation status updated successfully');
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['error'] ?? 'Failed to update violation status';
        print('Failed to update violation status: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error updating violation status: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  // Get violations by tourist
  Future<bool> getViolationsByTourist(String passport, {String? id}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      String endpoint = '$_baseUrl/violations/tourist/$passport';
      if (id != null) {
        endpoint = '$_baseUrl/violations/tourist/$passport/$id';
      }

      print(
          'Getting violations for tourist: passport=$passport, id=${id ?? "not provided"}');
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Authorization': 'Bearer $_token'},
      );
      print('Get violations by tourist response: ${response.statusCode}');
      print('Get violations by tourist body: ${response.body}');

      _isLoading = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _violations = List<Map<String, dynamic>>.from(data['violations']);
        print('Retrieved ${_violations.length} violations for tourist');
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['error'] ?? 'Failed to fetch tourist violations';
        print('Failed to fetch tourist violations: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching tourist violations: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  // Clear violations list
  void clearViolations() {
    _violations = [];
    _error = '';
    notifyListeners();
  }
}
