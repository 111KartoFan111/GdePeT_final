import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
// import '../models/user_model.dart'; // <-- УДАЛЕНО

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  // UserModel? _userModel; // <-- УДАЛЕНО
  bool _isLoading = false;
  String? _error;
  bool _isGuest = false;

  User? get user => _user;
  // UserModel? get userModel => _userModel; // <-- УДАЛЕНО
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isGuest => _isGuest;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      // Логика _loadUserData() удалена,
      // она будет в AuthWrapper в main.dart
      // if (user != null) { 
      //   _loadUserData();
      // } else {
      //   _userModel = null;
      // }
      notifyListeners();
    });
  }

  // Загрузка данных пользователя из Firestore
  // Future<void> _loadUserData() async { ... } // <-- УДАЛЕНО

  // Регистрация через email
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
        phoneNumber: phoneNumber,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Вход через email
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Вход через Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _error = null;

      final result = await _authService.signInWithGoogle();
      
      _setLoading(false);
      return result != null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Отправить код на телефон
  String? _verificationId;
  
  Future<bool> sendPhoneCode(String phoneNumber) async {
    try {
      _setLoading(true);
      _error = null;

      await _authService.signInWithPhone(
        phoneNumber: phoneNumber,
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _setLoading(false);
        },
        verificationFailed: (String error) {
          _error = error;
          _setLoading(false);
        },
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Автоматическая верификация (Android)
          await FirebaseAuth.instance.signInWithCredential(credential);
          _setLoading(false);
        },
      );

      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Подтвердить код из SMS
  Future<bool> verifyPhoneCode(String smsCode) async {
    if (_verificationId == null) {
      _error = 'Сначала отправьте код';
      return false;
    }

    try {
      _setLoading(true);
      _error = null;

      await _authService.verifyPhoneCode(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Отправить письмо для верификации email
  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Проверить верификацию email
  Future<bool> checkEmailVerification() async {
    final isVerified = await _authService.isEmailVerified();
    // Логика _loadUserData() удалена
    // if (isVerified) {
    //   await _loadUserData();
    // }
    return isVerified;
  }

  // Сброс пароля
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _error = null;

      await _authService.resetPassword(email);

      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Режим гостя
  void continueAsGuest() {
    _isGuest = true;
    notifyListeners();
  }

  // Выход
  Future<void> signOut() async {
    await _authService.signOut();
    _isGuest = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
