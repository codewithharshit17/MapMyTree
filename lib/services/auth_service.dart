import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/profile_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- USER SIGN UP ---
  Future<User?> signUpUserWithEmail({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phone, 'role': 'user'},
      );
      if (res.user != null) {
        await handlePostLogin(res.user!);
      }
      return res.user;
    } catch (e) {
      debugPrint('User sign up error: $e');
      rethrow;
    }
  }

  // --- NGO SIGN UP ---
  Future<User?> signUpNgoWithEmail({
    required String ngoName,
    required String registrationNumber,
    required String contactEmail,
    required String contactPhone,
    required String address,
    required String password,
  }) async {
    try {
      final res = await _supabase.auth.signUp(
        email: contactEmail,
        password: password,
        data: {
          'name': ngoName,
          'role': 'ngo',
          'registration_number': registrationNumber,
          'contact_phone': contactPhone,
          'address': address,
          'is_verified': false,
        },
      );
      if (res.user != null) {
        await handlePostLogin(res.user!);
      }
      return res.user;
    } catch (e) {
      debugPrint('NGO sign up error: $e');
      rethrow;
    }
  }

  // --- EMAIL SIGN IN ---
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user != null) {
        await handlePostLogin(res.user!);
      }
      return res.user;
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  // --- GOOGLE SIGN IN (NATIVE) ---
  Future<void> signInWithGoogle() async {
    try {
      final webClientId = dotenv.env['WEB_CLIENT_ID'];

      await GoogleSignIn.instance.initialize(
        clientId: kIsWeb ? webClientId : null, // Needed for Web
        serverClientId: webClientId, // Needed for Android to get idToken
      );

      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      final res = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      if (res.user != null) {
        await handlePostLogin(res.user!);
      }
    } catch (e) {
      debugPrint('Native Google sign in error: $e');
      rethrow;
    }
  }

  // --- GET USER ROLE ---
  Future<String> getUserRole(String uid) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', uid)
          .maybeSingle();
      return data?['role'] ?? 'user';
    } catch (e) {
      return 'user';
    }
  }

  // --- POST LOGIN ROLE ASSIGNMENT (UPSERT PROFILE) ---
  Future<void> handlePostLogin(User user) async {
    final email = user.email;
    if (email == null) return;

    // 1. Check if user already has a role in metadata
    String? role = user.userMetadata?['role'];

    // 2. Fetch existing profile role if not present in metadata
    if (role == null) {
      try {
        final data = await _supabase
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();
        role = data?['role'];
      } catch (_) {}
    }

    // 3. Fallback logic for Google Sign In or legacy test users
    if (role == null) {
      final ngoEmails = [
        'ngo1@gmail.com',
        'ngo2@gmail.com',
        'ngo3@gmail.com',
        'ngo4@gmail.com',
      ];
      role = ngoEmails.contains(email) ? 'ngo' : 'user';
    }

    try {
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'email': email,
        'role': role,
        'full_name': user.userMetadata?['name'] ?? user.userMetadata?['full_name'],
        'phone_number': user.userMetadata?['phone'] ?? user.userMetadata?['contact_phone'],
        'is_verified': user.userMetadata?['is_verified'] ?? true, // Regular users get true, NGOs get false unless verified manually
      });
    } catch (e) {
      debugPrint('handlePostLogin upsert error: $e');
    }
  }

  // --- GET PROFILE MODEL ---
  Future<ProfileModel?> getProfileModel(String uid) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();
      if (data != null) return ProfileModel.fromJson(data);
      return null;
    } catch (e) {
      return null;
    }
  }

  // --- RESET PASSWORD ---
  Future<void> sendPasswordResetEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // --- UPDATE PROFILE ---
  Future<void> updateProfile({required String fullName, String? phoneNumber, String? avatarUrl}) async {
    final user = currentUser;
    if (user == null) return;
    try {
      final updates = <String, dynamic>{
        'full_name': fullName,
      };
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      
      await _supabase.from('profiles').update(updates).eq('id', user.id);
    } catch (e) {
      debugPrint('Error updating profile: $e');
      throw AuthException(e.toString());
    }
  }

  // --- SIGN OUT ---
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      debugPrint('Google Sign Out error: $e');
    }
  }

  // --- CURRENT USER ---
  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;
}