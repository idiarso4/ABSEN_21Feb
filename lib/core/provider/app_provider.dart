import 'package:flutter/foundation.dart';

abstract class AppProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isDispose = false;
  String? _errorMessage;
  String _snackbarMessage = '';

  bool get isLoading => _isLoading;
  bool get isDispose => _isDispose;
  String? get errorMessage => _errorMessage;
  String get snackbarMessage => _snackbarMessage;

  void showLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void hideLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void init() {
    // Override this method to initialize provider
  }

  @override
  void dispose() {
    _isDispose = true;
    _isLoading = false;
    _errorMessage = null;
    super.dispose();
  }
}
