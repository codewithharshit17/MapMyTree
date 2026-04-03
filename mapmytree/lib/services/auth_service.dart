class AuthService {

  Future<void> signUpWithEmail(String name, String email, String password) async {
    // Temporary fake success
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> signInWithEmail(String email, String password) async {
    // Temporary fake success
    await Future.delayed(const Duration(seconds: 1));
  }
}