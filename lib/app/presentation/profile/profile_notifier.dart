import 'package:flutter/material.dart';
import 'package:absen_smkn1_punggelan/core/helper/shared_preferences_helper.dart';
import 'package:absen_smkn1_punggelan/core/provider/app_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';

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

  bool get canUpdateProfile => _canUpdateProfile;
  bool get isLoading => _isLoading;
  String get address => _address;
  String get nip => _nip;
  String get name => _name;
  String get role => _role;
  String get email => _email;
  String get phone => _phone;
  String? get profilePicture => _profilePicture;

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
      await checkProfileUpdatePermission();
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing profile: $e');
    }
  }

  Future<void> checkProfileUpdatePermission() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.get(
        '$baseUrl/profile/check-update-permission',
      );

      if (response.data['success']) {
        _canUpdateProfile = response.data['data']['can_update_profile'];
      } else {
        _canUpdateProfile = false;
      }
    } catch (e) {
      _canUpdateProfile = false;
    }
    notifyListeners();
  }

  Future<String?> _getToken() async {
    return await SharedPreferencesHelper.getString('token');
  }

  void _showSuccessMessage(String message) {
    // Success messages will be handled by the UI
  }

  Future<void> deleteProfilePicture(BuildContext context) async {
    try {
      if (!_canUpdateProfile) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maaf, saat ini Anda tidak diizinkan untuk mengubah profil'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      showLoading();
      final token = await SharedPreferencesHelper.getString('token');
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      final response = await _dio.delete(
        '$baseUrl/profile/delete-picture',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        await SharedPreferencesHelper.setString('profile_picture', '');
        _profilePicture = null;
        notifyListeners();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to delete profile picture: ${response.statusMessage}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus foto profil: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      hideLoading();
    }
  }

  Future<void> uploadProfilePicture(BuildContext context, File imageFile) async {
    try {
      if (!_canUpdateProfile) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maaf, saat ini Anda tidak diizinkan untuk mengubah profil'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      showLoading();
      final token = await SharedPreferencesHelper.getString('token');
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      final formData = FormData.fromMap({
        'profile_picture': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'profile_picture.jpg',
        ),
      });

      final response = await _dio.post(
        '$baseUrl/profile/update-picture',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        final newProfilePicture = response.data['data']['profile_picture_url'];
        await SharedPreferencesHelper.setString('profile_picture', newProfilePicture);
        _profilePicture = newProfilePicture;
        notifyListeners();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to upload profile picture: ${response.statusMessage}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengupload foto profil: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      hideLoading();
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
      _isLoading = true;
      notifyListeners();

      final dio = Dio();
      final token = await _getToken();
      if (token == null) throw Exception('Authentication token not found');
      
      dio.options.headers['Authorization'] = 'Bearer $token';

      final formData = FormData.fromMap({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (password != null) 'password': password,
        if (passwordConfirmation != null) 'password_confirmation': passwordConfirmation,
        if (photo != null) 'photo': await MultipartFile.fromFile(photo.path),
      });

      final response = await dio.post(
        '$baseUrl/profile/update',
        data: formData,
      );

      if (response.data['success']) {
        final userData = response.data['data']['user'];
        _name = userData['name'];
        _email = userData['email'];
        _phone = userData['phone'];
        if (userData['photo_url'] != null) {
          _profilePicture = userData['photo_url'];
        }
        
        notifyListeners();
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw Exception('Terlalu banyak permintaan. Silakan coba lagi nanti.');
      } else if (e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Gagal memperbarui profil');
      } else {
        throw Exception('Terjadi kesalahan. Silakan coba lagi.');
      }
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(
    BuildContext context,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      if (!_canUpdateProfile) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maaf, saat ini Anda tidak diizinkan untuk mengubah password'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      showLoading();
      final token = await SharedPreferencesHelper.getString('token');
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      final response = await _dio.post(
        '$baseUrl/profile/change-password',
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
        throw Exception('Failed to change password: ${response.statusMessage}');
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
