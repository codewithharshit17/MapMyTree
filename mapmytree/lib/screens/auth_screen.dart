import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_theme.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _authService = AuthService();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // Only used for Sign Up

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _submitAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    if (!_isLogin && _nameController.text.trim().isEmpty) {
      _showError('Please enter your name');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _authService.signInWithEmail(email, password);
      } else {
        await _authService.signUpWithEmail(_nameController.text.trim(), email, password);
      }
      if (mounted) _navigateToHome();
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Authentication failed');
    } catch (e) {
      _showError('An unexpected error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final userCred = await _authService.signInWithGoogle();
      if (userCred != null && mounted) {
        _navigateToHome();
      }
    } catch (e) {
      if (mounted) _showError('Google sign in failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD6EADF), Color(0xFFC0E1D1)],
            stops: [0.0, 0.4],
          ),
        ),
        child: Stack(
          children: [
            // Background Illustration (hills/trees)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 180),
                painter: _HillsPainter(),
              ),
            ),
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        // Logo
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1B4332), // Dark green
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.eco_outlined, color: Colors.white, size: 32),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'MapMyTree',
                          style: TextStyle(
                            color: Color(0xFF1B4332), // Dark green title
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Nunito',
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Card
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    _isLogin ? 'Welcome Back' : 'Create Account',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF1B4332),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Nunito',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isLogin ? 'Sign in to continue' : 'Sign up to start your journey',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppTheme.grey,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  if (!_isLogin) ...[
                                    _buildLabel('Full Name'),
                                    _buildTextField(
                                      controller: _nameController,
                                      hintText: 'John Doe',
                                      icon: Icons.person_outline,
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  _buildLabel('Email'),
                                  _buildTextField(
                                    controller: _emailController,
                                    hintText: 'your.email@example.com',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 16),

                                  _buildLabel('Password'),
                                  _buildTextField(
                                    controller: _passwordController,
                                    hintText: '••••••••',
                                    icon: Icons.lock_outline,
                                    obscureText: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: AppTheme.grey,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  
                                  if (_isLogin) ...[
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            color: AppTheme.darkGrey,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ] else ...[
                                    const SizedBox(height: 24),
                                  ],

                                  ElevatedButton(
                                    onPressed: _isLoading ? null : _submitAuth,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1B4332),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          )
                                        : Text(
                                            _isLogin ? 'Sign In' : 'Sign Up',
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                  ),

                                  const SizedBox(height: 24),
                                  const Row(
                                    children: [
                                      Expanded(child: Divider(color: AppTheme.lightGrey)),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        child: Text('Or continue with', style: TextStyle(color: AppTheme.grey, fontSize: 13)),
                                      ),
                                      Expanded(child: Divider(color: AppTheme.lightGrey)),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  OutlinedButton.icon(
                                    onPressed: _isLoading ? null : _signInWithGoogle,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      side: const BorderSide(color: AppTheme.lightGrey),
                                      backgroundColor: AppTheme.offWhite,
                                    ),
                                    icon: const Text(
                                      'G', // Placeholder for Google logo
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black87,
                                        fontSize: 18,
                                      ),
                                    ),
                                    label: const Text(
                                      'Sign in with Google',
                                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                  ),

                                  const SizedBox(height: 24),
                                  const Spacer(),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _isLogin ? "Don't have an account? " : 'Already have an account? ',
                                        style: const TextStyle(color: AppTheme.grey, fontSize: 13),
                                      ),
                                      GestureDetector(
                                        onTap: () => setState(() => _isLogin = !_isLogin),
                                        child: Text(
                                          _isLogin ? 'Sign Up' : 'Sign In',
                                          style: const TextStyle(
                                            color: Color(0xFF1B4332),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppTheme.grey.withValues(alpha: 0.6), fontSize: 15),
        prefixIcon: Icon(icon, color: AppTheme.grey, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.offWhite,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1B4332)),
        ),
      ),
    );
  }
}

class _HillsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFF81C784).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    final paint2 = Paint()
      ..color = const Color(0xFF4CAF50).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
      
    final paint3 = Paint()
      ..color = const Color(0xFF388E3C).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    // Background hill
    var path1 = Path();
    path1.moveTo(0, size.height * 0.4);
    path1.quadraticBezierTo(size.width * 0.25, size.height * 0.2, size.width * 0.5, size.height * 0.5);
    path1.quadraticBezierTo(size.width * 0.75, size.height * 0.8, size.width, size.height * 0.3);
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    canvas.drawPath(path1, paint1);

    // Middle hill
    var path2 = Path();
    path2.moveTo(0, size.height * 0.6);
    path2.quadraticBezierTo(size.width * 0.3, size.height * 0.8, size.width * 0.6, size.height * 0.5);
    path2.quadraticBezierTo(size.width * 0.8, size.height * 0.3, size.width, size.height * 0.6);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    canvas.drawPath(path2, paint2);

    // Foreground hill
    var path3 = Path();
    path3.moveTo(0, size.height * 0.8);
    path3.quadraticBezierTo(size.width * 0.5, size.height * 0.6, size.width, size.height * 0.7);
    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
