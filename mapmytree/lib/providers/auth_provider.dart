import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/ngo_model.dart';

enum AuthStatus { unknown, unauthenticated, userAuthenticated, ngoAuthenticated }

class AppAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _userModel;
  NgoModel? _ngoModel;

  AuthStatus get status => _status;
  UserModel? get userModel => _userModel;
  NgoModel? get ngoModel => _ngoModel;
  bool get isNgo => _status == AuthStatus.ngoAuthenticated;
  bool get isLoggedIn =>
      _status == AuthStatus.userAuthenticated ||
      _status == AuthStatus.ngoAuthenticated;

  AppAuthProvider() {
    // Check existing session on startup
    _loadCurrentSession();
    // Listen for auth changes
    _authService.authStateChanges.listen((authState) {
      _onAuthStateChanged(authState.session?.user);
    });
  }

  Future<void> _loadCurrentSession() async {
    final user = _authService.currentUser;
    await _onAuthStateChanged(user);
  }

  Future<void> _onAuthStateChanged(User? supabaseUser) async {
    if (supabaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _userModel = null;
      _ngoModel = null;
      notifyListeners();
      return;
    }

    final role = await _authService.getUserRole(supabaseUser.id);
    _userModel = await _authService.getUserModel(supabaseUser.id);

    if (role == 'ngo') {
      _ngoModel = await _authService.getNgoModel(supabaseUser.id);
      _status = AuthStatus.ngoAuthenticated;
    } else {
      _ngoModel = null;
      _status = AuthStatus.userAuthenticated;
    }

    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> refreshUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      _userModel = await _authService.getUserModel(user.id);
      if (_userModel?.isNgo == true) {
        _ngoModel = await _authService.getNgoModel(user.id);
      }
      notifyListeners();
    }
  }
}
