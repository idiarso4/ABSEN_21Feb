import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://app.sijasmkn1punggelan.org';
  static const String tokenKey = 'auth_token';

  // Get stored token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(tokenKey);
      return token?.isNotEmpty == true ? token : null;
    } catch (e) {
      return null;
    }
  }

  // Store token
  Future<void> setToken(String? token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (token?.isNotEmpty == true) {
        await prefs.setString(tokenKey, token!);
      } else {
        await prefs.remove(tokenKey);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Clear token (logout)
  Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
    } catch (e) {
      // Handle error silently
    }
  }

  // Add authorization header
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token?.isNotEmpty == true) 'Authorization': 'Bearer $token',
    };
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        if (data['success'] == true && data['data'] != null && data['data']['token'] != null) {
          final token = data['data']['token'].toString();
          await setToken(token);
          return data;
        }
      }
      
      // If we get here, something went wrong
      final message = data['message']?.toString() ?? 'Email atau password salah';
      throw Exception(message);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Terjadi kesalahan jaringan');
    }
  }

  // Get user info
  Future<Map<String, dynamic>> getUserInfo() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/user'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to get user info');
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? password,
    String? photoBase64,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/profile/update'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        if (phone != null) 'phone': phone,
        if (password != null) 'password': password,
        if (photoBase64 != null) 'photo': photoBase64,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to update profile');
  }

  // Get today's attendance
  Future<Map<String, dynamic>> getTodayAttendance() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/get-attendance-today'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to get attendance');
  }

  // Store attendance
  Future<Map<String, dynamic>> storeAttendance({
    required String type,
    required String photoBase64,
    required String latitude,
    required String longitude,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/store-attendance'),
      headers: headers,
      body: jsonEncode({
        'type': type,
        'photo': photoBase64,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to store attendance');
  }

  // Get monthly attendance
  Future<Map<String, dynamic>> getMonthlyAttendance(int month, int year) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/get-attendance-by-month-year/$month/$year'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to get monthly attendance');
  }

  // Academic APIs
  Future<Map<String, dynamic>> getClasses() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/academic/classes'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to get classes');
  }

  Future<Map<String, dynamic>> getStudentClass() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/academic/student-class'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to get student class');
  }

  // Prayer Schedule APIs
  Future<Map<String, dynamic>> getPrayerSchedule() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/pray/schedule'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to get prayer schedule');
  }

  Future<Map<String, dynamic>> markPrayerAttendance() async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/pray/mark-attendance'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to mark prayer attendance');
  }

  // PKL (Internship) APIs
  Future<Map<String, dynamic>> getPKLLocations() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/pkl/locations'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to get PKL locations');
  }

  Future<Map<String, dynamic>> submitDailyReport(String report) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/pkl/daily-report'),
      headers: headers,
      body: jsonEncode({'report': report}),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to submit daily report');
  }

  // Leave Management APIs
  Future<Map<String, dynamic>> getLeaves() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/leaves'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to get leaves');
  }

  Future<Map<String, dynamic>> submitLeave({
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/leaves'),
      headers: headers,
      body: jsonEncode({
        'start_date': startDate,
        'end_date': endDate,
        'reason': reason,
      }),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to submit leave request');
  }

  // QR Code Attendance
  Future<Map<String, dynamic>> generateQRCode() async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/attendance/qr-code'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to generate QR code');
  }

  // Get Allowed Locations
  Future<Map<String, dynamic>> getAllowedLocations() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/attendance/locations'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to get allowed locations');
  }
} 