import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/attendance.dart';

class ApiService {
  static const String baseUrl = 'https://app.sijasmkn1punggelan.org/api';
  static const String tokenKey = 'auth_token';
  static const String offlineAttendanceKey = 'offline_attendance';
  static const String offlineDataKey = 'offline_data';
  final _connectivity = Connectivity();

  // Get headers without CORS
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Check internet connection with timeout and retry
  Future<bool> _checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        return false;
      }
      
      // Try to actually connect to the server with timeout and retry
      for (int i = 0; i < 3; i++) {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl/ping'),
            headers: await _getHeaders(),
          ).timeout(const Duration(seconds: 5));
          
          if (response.statusCode == 200) {
            return true;
          }
          
          // If not 200, wait and retry
          await Future.delayed(const Duration(seconds: 1));
        } catch (e) {
          print('Connection check attempt ${i + 1} failed: $e');
          if (i < 2) {
            await Future.delayed(const Duration(seconds: 1));
          }
        }
      }
      return false;
    } catch (e) {
      print('Connectivity check error: $e');
      return false;
    }
  }

  // Make HTTP request with error handling and offline support
  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    bool allowOffline = false,
  }) async {
    try {
      // First try to get offline data if allowed
      if (allowOffline) {
        final offlineData = await _getOfflineData('${endpoint}_offline');
        if (offlineData != null) {
          return offlineData;
        }
      }

      // Check connection
      final isOnline = await _checkConnection();
      if (!isOnline) {
        throw Exception('Tidak ada koneksi internet');
      }

      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders();

      http.Response response;
      try {
        switch (method.toUpperCase()) {
          case 'GET':
            response = await http.get(uri, headers: headers)
                .timeout(const Duration(seconds: 15));
            break;
          case 'POST':
            response = await http.post(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            ).timeout(const Duration(seconds: 15));
            break;
          case 'PUT':
            response = await http.put(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            ).timeout(const Duration(seconds: 15));
            break;
          case 'DELETE':
            response = await http.delete(uri, headers: headers)
                .timeout(const Duration(seconds: 15));
            break;
          default:
            throw Exception('Metode HTTP tidak didukung');
        }

        // Handle response
        if (response.statusCode == 401) {
          await clearToken();
          throw Exception('Sesi telah berakhir, silakan login kembali');
        }

        if (response.statusCode == 404) {
          throw Exception('Server tidak dapat ditemukan');
        }

        if (response.statusCode >= 500) {
          throw Exception('Terjadi kesalahan pada server');
        }

        Map<String, dynamic> responseData;
        try {
          responseData = jsonDecode(response.body);
        } catch (e) {
          throw Exception('Format response tidak valid');
        }
        
        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (allowOffline) {
            await _saveOfflineData('${endpoint}_offline', responseData);
          }
          return responseData;
        } else {
          throw Exception(responseData['message'] ?? 'Terjadi kesalahan pada server');
        }
      } on SocketException {
        throw Exception('Tidak dapat terhubung ke server');
      } on FormatException {
        throw Exception('Format response tidak valid');
      } on http.ClientException {
        throw Exception('Gagal terhubung ke server');
      } on TimeoutException {
        throw Exception('Koneksi timeout, coba lagi nanti');
      } catch (e) {
        throw Exception('Terjadi kesalahan: ${e.toString()}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _makeRequest(
      'POST',
      '/login',
      body: {'email': email, 'password': password},
      requiresAuth: false,
    );
    
    if (response['success'] == true && response['data'] != null) {
      final token = response['data']['token'];
      if (token != null) {
        await setToken(token);
        return response['data'];
      }
    }
    throw Exception('Email atau password salah');
  }

  // Get user info
  Future<Map<String, dynamic>> getUserInfo() async {
    return await _makeRequest('GET', '/user', allowOffline: true);
  }

  // Get today's attendance
  Future<Map<String, dynamic>> getTodayAttendance() async {
    return await _makeRequest(
      'GET', 
      '/get-attendance-today',
      allowOffline: true,
    );
  }

  // Store attendance with offline support
  Future<Map<String, dynamic>> storeAttendance({
    required String type,
    required String photoBase64,
    required String latitude,
    required String longitude,
  }) async {
    final attendanceData = {
      'type': type,
      'photo': photoBase64,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      final response = await _makeRequest(
        'POST',
        '/store-attendance',
        body: attendanceData,
      );
      return response;
    } catch (e) {
      if (e.toString().contains('Tidak ada koneksi internet')) {
        await _savePendingAttendance(attendanceData);
        return {
          'success': true,
          'message': 'Absensi disimpan offline dan akan disinkronkan saat online',
          'offline': true,
        };
      }
      rethrow;
    }
  }

  // Get stored token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(tokenKey);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Store token
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // Clear token (logout)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  // Save data for offline access
  Future<void> _saveOfflineData(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(data));
    } catch (e) {
      print('Error saving offline data: $e');
    }
  }

  // Get offline data
  Future<dynamic> _getOfflineData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(key);
      if (data != null) {
        return jsonDecode(data);
      }
    } catch (e) {
      print('Error getting offline data: $e');
    }
    return null;
  }

  // Save pending attendance
  Future<void> _savePendingAttendance(Map<String, dynamic> attendance) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> pendingAttendances = prefs.getStringList(offlineAttendanceKey) ?? [];
      pendingAttendances.add(jsonEncode(attendance));
      await prefs.setStringList(offlineAttendanceKey, pendingAttendances);
    } catch (e) {
      print('Error saving pending attendance: $e');
    }
  }

  // Sync pending attendances
  Future<void> syncPendingAttendances() async {
    if (!await _checkConnection()) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> pendingAttendances = prefs.getStringList(offlineAttendanceKey) ?? [];
      
      for (var i = pendingAttendances.length - 1; i >= 0; i--) {
        try {
          final attendance = jsonDecode(pendingAttendances[i]);
          await _makeRequest('POST', '/store-attendance', body: attendance);
          pendingAttendances.removeAt(i);
        } catch (e) {
          print('Error syncing attendance: $e');
        }
      }
      
      await prefs.setStringList(offlineAttendanceKey, pendingAttendances);
    } catch (e) {
      print('Error in sync process: $e');
    }
  }

  // Check profile update permission
  Future<bool> checkProfileUpdatePermission() async {
    final response = await _makeRequest('GET', '/profile/check-update-permission');
    return response['success'] == true && 
           response['data']?['can_update_profile'] == true;
  }

  // Get monthly attendance
  Future<Map<String, dynamic>> getMonthlyAttendance(int month, int year) async {
    return await _makeRequest(
      'GET',
      '/get-attendance-by-month-year/$month/$year',
      allowOffline: true,
    );
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? password,
    String? photoBase64,
  }) async {
    final body = {
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      if (password != null) 'password': password,
      if (photoBase64 != null) 'photo': photoBase64,
    };
    
    return await _makeRequest(
      'POST',
      '/profile/update',
      body: body,
    );
  }

  // Get schedule
  Future<Map<String, dynamic>> getSchedule() async {
    return await _makeRequest(
      'GET',
      '/get-schedule',
      allowOffline: true,
    );
  }

  // Get allowed locations
  Future<Map<String, dynamic>> getAllowedLocations() async {
    return await _makeRequest(
      'GET',
      '/attendance/locations',
      allowOffline: true,
    );
  }

  // Academic APIs
  Future<Map<String, dynamic>> getClasses() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/academic/classes'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to get classes');
  }

  Future<Map<String, dynamic>> getStudentClass() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/academic/student-class'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to get student class');
  }

  // Prayer Schedule APIs
  Future<Map<String, dynamic>> getPrayerSchedule() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/pray/schedule'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to get prayer schedule');
  }

  Future<Map<String, dynamic>> markPrayerAttendance() async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/pray/mark-attendance'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to mark prayer attendance');
  }

  // PKL (Internship) APIs
  Future<Map<String, dynamic>> getPKLLocations() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/pkl/locations'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to get PKL locations');
  }

  Future<Map<String, dynamic>> submitDailyReport(String report) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/pkl/daily-report'),
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
      Uri.parse('$baseUrl/leaves'),
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
      Uri.parse('$baseUrl/leaves'),
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
      Uri.parse('$baseUrl/attendance/qr-code'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to generate QR code');
  }
} 