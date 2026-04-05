import 'package:flutter/material.dart';
import '../../data/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthStore extends ChangeNotifier {
  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.unknown;
  String? _username;
  String? _role;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStore({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  AuthStatus get status => _status;
  String? get username => _username;
  String? get role => _role;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> checkAuthStatus() async {
    final loggedIn = await _repository.isLoggedIn();
    if (loggedIn) {
      _username = await _repository.getUsername();
      _role = await _repository.getRole();
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login(String identifier, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.login(identifier, password);
      _username = await _repository.getUsername();
      _role = await _repository.getRole();
      _status = AuthStatus.authenticated;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = AuthStatus.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _username = null;
    _role = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}