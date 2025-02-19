import 'package:absen_smkn1_punggelan/app/module/entity/auth.dart';
import 'package:absen_smkn1_punggelan/app/module/use_case/auth_login.dart';
import 'package:absen_smkn1_punggelan/core/constant/constant.dart';
import 'package:absen_smkn1_punggelan/core/helper/shared_preferences_helper.dart';
import 'package:absen_smkn1_punggelan/core/provider/app_provider.dart';
import 'package:flutter/material.dart';

class LoginNotifier extends AppProvider {
  final AuthLoginUseCase _authLoginUseCase;

  LoginNotifier(this._authLoginUseCase) {
    init();
  }

  bool _isLoged = false;
  bool _isShowPassword = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  bool get isLoged => _isLoged;
  bool get isShowPassword => _isShowPassword;
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

  _checkAuth() async {
    showLoading();
    final String? auth = await SharedPreferencesHelper.getString(PREF_AUTH);
    if (auth?.isNotEmpty ?? false) _isLoged = true;
    hideLoading();
  }

  login() async {
    showLoading();
    final param = AuthEntity(
        email: _emailController.text, password: _passwordController.text);
    final response = await _authLoginUseCase(param: param);
    if (response.success) {
      _isLoged = true;
    } else {
      _errorMessage = response.message ?? 'Unknown error';
    }
    hideLoading();
    notifyListeners();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
