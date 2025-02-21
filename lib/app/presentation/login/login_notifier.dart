import 'package:presensi_smkn1_punggelan/app/module/entity/auth.dart';
import 'package:presensi_smkn1_punggelan/app/module/use_case/auth_login.dart';
import 'package:presensi_smkn1_punggelan/core/constant/constant.dart';
import 'package:presensi_smkn1_punggelan/core/helper/shared_preferences_helper.dart';
import 'package:presensi_smkn1_punggelan/core/provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class LoginNotifier extends AppProvider {
  final AuthLoginUseCase _authLoginUseCase;
  final BuildContext context;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  LoginNotifier(this._authLoginUseCase, this.context) {
    init();
  }

  bool _isLoged = false;
  bool _isShowPassword = false;
  bool _isInitializing = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  bool get isLoged => _isLoged;
  bool get isShowPassword => _isShowPassword;
  bool get isInitializing => _isInitializing;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;

  @override
  String? get errorMessage => _errorMessage;

  set isShowPassword(bool param) {
    _isShowPassword = param;
    notifyListeners();
  }

  @override
  void init() {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      _isInitializing = true;
      notifyListeners();

      final String? auth = await SharedPreferencesHelper.getString(PREF_AUTH);
      if (auth?.isNotEmpty ?? false) {
        _isLoged = true;
        _errorMessage = null;
        _navigateToHome();
      }
    } catch (e) {
      dev.log('Error checking auth: $e');
      _errorMessage = e.toString();
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  void _navigateToHome() {
    if (context.mounted) {
      dev.log('Navigating to home screen');
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  Future<void> login() async {
    try {
      if (!formKey.currentState!.validate()) {
        return;
      }

      showLoading();
      _errorMessage = null;
      notifyListeners();
      
      dev.log('Attempting login with email: ${_emailController.text}');
      
      final param = AuthEntity(
        email: _emailController.text.trim(), 
        password: _passwordController.text.trim()
      );
      
      final response = await _authLoginUseCase(param: param);
      dev.log('Login response received: $response');
      
      if (response.success && response.data != null) {
        dev.log('Login successful, processing response');
        
        final data = response.data!;
        final token = data['token'] as String?;
        
        if (token != null) {
          dev.log('Saving token');
          await SharedPreferencesHelper.setString(PREF_AUTH, 'Bearer $token');
          
          // Save user data if available
          final userData = data['user'] as Map<String, dynamic>?;
          if (userData != null) {
            await SharedPreferencesHelper.setInt(PREF_ID, userData['id'] as int);
            await SharedPreferencesHelper.setString(PREF_NAME, userData['name'] as String);
            await SharedPreferencesHelper.setString(PREF_EMAIL, userData['email'] as String);
          }
          
          _isLoged = true;
          _errorMessage = null;
          
          dev.log('Token saved, navigating to home');
          _navigateToHome();
        } else {
          dev.log('Error: Token is null in response');
          _isLoged = false;
          _errorMessage = 'Invalid server response';
        }
      } else {
        dev.log('Login failed: ${response.message}');
        _isLoged = false;
        _errorMessage = response.message ?? 'Gagal login: Email atau password salah';
      }
    } catch (e) {
      dev.log('Exception during login: $e');
      _isLoged = false;
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      hideLoading();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
