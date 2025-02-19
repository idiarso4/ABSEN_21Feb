import 'package:flutter/material.dart';
import 'package:absen_smkn1_punggelan/core/helper/shared_preferences_helper.dart';
import 'package:absen_smkn1_punggelan/core/provider/app_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileNotifier extends AppProvider {
  final String baseUrl = 'https://app.sjasmkn1punggelan.org/api';
  final Dio _dio = Dio();
  
  String _name = '';
  String _role = '';
  String _email = '';
  String _phone = '';
  String _nip = '';
  String _address = '';
  String? _profilePicture;
  bool _canUpdateProfile = false;
  bool _isLoading = false;
  bool _isPhotoUpdateEnabled = false;  // Status untuk update foto
  DateTime? _photoUpdateDeadline;      // Batas waktu update foto

  bool get canUpdateProfile => _canUpdateProfile;
  bool get isLoading => _isLoading;
  String get address => _address;
  String get nip => _nip;
  String get name => _name;
  String get role => _role;
  String get email => _email;
  String get phone => _phone;
  String? get profilePicture => _profilePicture;
  bool get canUpdatePhoto => _isPhotoUpdateEnabled;

  ProfileNotifier() {
    init();
  }

  @override
  Future<void> init() async {
    try {
      _role = await SharedPreferencesHelper.getRole() ?? 'Siswa';
      _email = await SharedPreferencesHelper.getEmail() ?? 'user@example.com';
      _phone = await SharedPreferencesHelper.getPhone() ?? '-';
      _nip = await SharedPreferencesHelper.getNip() ?? '-';
      _address = await SharedPreferencesHelper.getAddress() ?? '-';
      _name = await SharedPreferencesHelper.getString('name') ?? 'User';
      _profilePicture = await SharedPreferencesHelper.getString('profile_picture');
      
      // Set default ke true dan cek permission
      _canUpdateProfile = true;
      _isPhotoUpdateEnabled = true;
      await checkProfileUpdatePermission();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal menginisialisasi profil: $e');
    }
  }

  Future<void> checkProfileUpdatePermission() async {
    try {
      final token = await _getToken();
      if (token == null) {
        _canUpdateProfile = false;
        _isPhotoUpdateEnabled = false;
        notifyListeners();
        return;
      }

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      
      debugPrint('Checking profile permissions...');
      final response = await dio.get('$baseUrl/api/settings/profile-permissions');
      debugPrint('Permission Response: ${response.data}');
      
      if (response.data['success']) {
        final settings = response.data['data'];
        
        // Update permissions dari response
        _canUpdateProfile = settings['can_update_profile'] ?? true;
        _isPhotoUpdateEnabled = settings['can_update_photo'] ?? true;
        
        debugPrint('Can Update Profile: $_canUpdateProfile');
        debugPrint('Can Update Photo: $_isPhotoUpdateEnabled');
      } else {
        // Jika gagal mendapatkan settings, tetap bisa update
        _canUpdateProfile = true;
        _isPhotoUpdateEnabled = true;
        debugPrint('Failed to get settings, defaulting to enabled');
      }
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      // Default ke true jika error
      _canUpdateProfile = true;
      _isPhotoUpdateEnabled = true;
    }
    notifyListeners();
  }

  Future<String?> _getToken() async {
    return await SharedPreferencesHelper.getString('token');
  }

  Future<void> deleteProfilePicture(BuildContext context) async {
    try {
      if (!_canUpdateProfile) {
        throw Exception('Anda tidak memiliki izin untuk mengubah profil');
      }

      if (!_isPhotoUpdateEnabled) {
        throw Exception('Fitur update foto sedang dinonaktifkan');
      }

      showLoading();
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }
      
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.post(
        '$baseUrl/api/profile/delete-photo',
      );

      if (response.data['success']) {
        await init();
        hideLoading();
        notifyListeners();
      } else {
        hideLoading();
        throw Exception(response.data['message'] ?? 'Gagal menghapus foto');
      }
    } catch (e) {
      hideLoading();
      rethrow;
    }
  }

  Future<void> uploadProfilePicture(BuildContext context, File imageFile) async {
    try {
      if (!_canUpdateProfile) {
        throw Exception('Anda tidak memiliki izin untuk mengubah profil');
      }

      if (!_isPhotoUpdateEnabled) {
        throw Exception('Fitur update foto sedang dinonaktifkan');
      }

      showLoading();
      final token = await _getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(imageFile.path),
      });

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.post(
        '$baseUrl/api/profile/update',
        data: formData,
      );

      if (response.data['success']) {
        await init();
        hideLoading();
        notifyListeners();
      } else {
        hideLoading();
        throw Exception(response.data['message'] ?? 'Gagal mengupload foto');
      }
    } catch (e) {
      hideLoading();
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? password,
    String? passwordConfirmation,
    File? photo,
  }) async {
    try {
      // Khusus untuk update foto, cek apakah fitur diaktifkan
      if (photo != null && !_isPhotoUpdateEnabled) {
        throw Exception('Maaf, fitur update foto sedang dinonaktifkan oleh admin');
      }

      showLoading();
      final token = await _getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      debugPrint('Preparing to update profile...');
      final formData = FormData.fromMap({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (password != null) 'password': password,
        if (passwordConfirmation != null) 'password_confirmation': passwordConfirmation,
        if (photo != null) 'photo': await MultipartFile.fromFile(photo.path),
      });

      debugPrint('Form data prepared: ${formData.fields}');
      _dio.options.headers['Authorization'] = 'Bearer $token';
      
      try {
        debugPrint('Sending update request...');
        final response = await _dio.post(
          '$baseUrl/api/profile/update',
          data: formData,
        );
        debugPrint('Update Response: ${response.data}');

        if (response.data['success']) {
          debugPrint('Profile update successful');
          // Memperbarui penyimpanan lokal
          if (name != null) await SharedPreferencesHelper.setString('name', name);
          if (email != null) await SharedPreferencesHelper.setEmail(email);
          if (phone != null) await SharedPreferencesHelper.setPhone(phone);
          
          // Memperbarui data profil
          await init();
          hideLoading();
          notifyListeners();
        } else {
          hideLoading();
          throw Exception(response.data['message'] ?? 'Gagal memperbarui profil');
        }
      } on DioException catch (e) {
        debugPrint('DioError: ${e.response?.data}');
        hideLoading();
        if (e.response?.statusCode == 429) {
          throw Exception('Terlalu banyak permintaan. Silakan tunggu beberapa saat.');
        } else if (e.response?.statusCode == 403) {
          throw Exception('Anda tidak memiliki izin untuk mengubah profil');
        } else {
          throw Exception(e.response?.data?['message'] ?? 'Gagal memperbarui profil');
        }
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      hideLoading();
      rethrow;
    }
  }

  Future<void> changePassword(
    BuildContext context,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      if (!_canUpdateProfile) {
        throw Exception('Anda tidak memiliki izin untuk mengubah password');
      }

      showLoading();
      final token = await SharedPreferencesHelper.getString('token');
      
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }
      
      final response = await _dio.post(
        '$baseUrl/api/profile/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil diubah'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Gagal mengubah password: ${response.statusMessage}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah password: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      hideLoading();
    }
  }
}
