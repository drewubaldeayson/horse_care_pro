import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class HorseAuthProvider with ChangeNotifier {
  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;

  final AuthService _authService = AuthService();

  HorseAuthProvider() {
    // Listen to auth state changes
    _authService.user.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    String? region,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      _userModel = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        region: region,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      _userModel = await _authService.signIn(email, password);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _userModel = null;
    notifyListeners();
  }

  void updateUserModel(UserModel updatedUser) {
    _userModel = updatedUser;
    notifyListeners();
  }
}
