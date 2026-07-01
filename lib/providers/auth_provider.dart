import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../models/profile_model.dart';

enum AuthStatus { unknown, unauthenticated, userAuthenticated, ngoAdminAuthenticated, ngoVolunteerAuthenticated }

class AppAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  ProfileModel? _profile;

  AuthStatus get status => _status;
  ProfileModel? get profile => _profile;
  bool get isNgo =>
      _status == AuthStatus.ngoAdminAuthenticated ||
      _status == AuthStatus.ngoVolunteerAuthenticated;
  bool get isNgoAdmin => _status == AuthStatus.ngoAdminAuthenticated;
  bool get isNgoVolunteer => _status == AuthStatus.ngoVolunteerAuthenticated;
  bool get isLoggedIn =>
      _status == AuthStatus.userAuthenticated ||
      _status == AuthStatus.ngoAdminAuthenticated ||
      _status == AuthStatus.ngoVolunteerAuthenticated;

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
      _profile = null;
      notifyListeners();
      return;
    }

    try {
      await _authService.handlePostLogin(supabaseUser);
    } catch (e) {
      debugPrint('Error in _onAuthStateChanged handlePostLogin: $e');
    }

    final role = await _authService.getUserRole(supabaseUser.id);
    _profile = await _authService.getProfileModel(supabaseUser.id);

    // If profile is disabled (is_active == false), treat as unauthenticated
    if (_profile != null && !_profile!.isActive) {
      _status = AuthStatus.unauthenticated;
      _profile = null;
      notifyListeners();
      return;
    }

    if (role == 'ngo_admin') {
      _status = AuthStatus.ngoAdminAuthenticated;
    } else if (role == 'ngo_volunteer' || role == 'ngo') {
      _status = AuthStatus.ngoVolunteerAuthenticated;
    } else {
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
      _profile = await _authService.getProfileModel(user.id);
      notifyListeners();
    }
  }
}
