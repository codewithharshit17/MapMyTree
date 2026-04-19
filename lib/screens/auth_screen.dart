import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_theme.dart';
import '../services/auth_service.dart';
import '../core/dev_session.dart';
import 'ngo/ngo_shell_screen.dart';
import 'user/user_shell_screen.dart';

enum AuthMode { login, userSignup, ngoSignup }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _authService = AuthService();
  AuthMode _mode = AuthMode.login;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Shared controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // User-only
  final _nameController = TextEditingController();

  // NGO-only
  final _ngoNameController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _ngoNameController.dispose();
    _regNumberController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode newMode) {
    _fadeController.reset();
    setState(() => _mode = newMode);
    _fadeController.forward();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateBasedOnRole(String role) {
    if (!mounted) return;
    if (role == 'ngo') {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const NgoShellScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const UserShellScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  Future<void> _submitLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithEmail(email, password);
      if (user != null && mounted) {
        final role = await _authService.getUserRole(user.id);
        if (mounted) _navigateBasedOnRole(role);
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Login failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitUserSignup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }
    if (password != confirm) {
      _showError('Passwords do not match');
      return;
    }
    if (password.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.signUpUserWithEmail(
          name: name, email: email, phone: phone, password: password);
      if (mounted) _navigateBasedOnRole('user');
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Sign up failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitNgoSignup() async {
    final ngoName = _ngoNameController.text.trim();
    final regNumber = _regNumberController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    if (ngoName.isEmpty ||
        regNumber.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        address.isEmpty ||
        password.isEmpty) {
      _showError('Please fill in all required fields');
      return;
    }
    if (password != confirm) {
      _showError('Passwords do not match');
      return;
    }
    if (password.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.signUpNgoWithEmail(
        ngoName: ngoName,
        registrationNumber: regNumber,
        contactEmail: email,
        contactPhone: phone,
        address: address,
        password: password,
      );
      if (mounted) _navigateBasedOnRole('ngo');
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Registration failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
      // Navigation handled by auth state listener in AppAuthProvider
    } catch (_) {
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
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 180),
                painter: _HillsPainter(),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Container(
                      width: 64, height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B4332),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.eco_outlined,
                            color: Colors.white, size: 32),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('MapMyTree',
                        style: TextStyle(
                            color: Color(0xFF1B4332),
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Nunito')),
                    const SizedBox(height: 24),

                    // Role selector — only for signup
                    if (_mode != AuthMode.login) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildRoleSelector(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
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
                        padding: const EdgeInsets.all(24),
                        child: _buildFormContent(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBottomToggle(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Row(
      children: [
        Expanded(child: _roleCard('🌱', 'Regular User', AuthMode.userSignup)),
        const SizedBox(width: 12),
        Expanded(child: _roleCard('🏢', 'NGO / Org', AuthMode.ngoSignup)),
      ],
    );
  }

  Widget _roleCard(String emoji, String label, AuthMode targetMode) {
    final isSelected = _mode == targetMode;
    return GestureDetector(
      onTap: () => _switchMode(targetMode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B4332) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1B4332)),
        ),
        child: Column(
          children: [
            Text(emoji,
                style: TextStyle(
                    fontSize: 22,
                    color: isSelected ? Colors.white : const Color(0xFF1B4332))),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isSelected ? Colors.white : const Color(0xFF1B4332))),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    switch (_mode) {
      case AuthMode.login:
        return _buildLoginForm();
      case AuthMode.userSignup:
        return _buildUserSignupForm();
      case AuthMode.ngoSignup:
        return _buildNgoSignupForm();
    }
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Welcome Back',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xFF1B4332), fontSize: 24,
                fontWeight: FontWeight.w800, fontFamily: 'Nunito')),
        const SizedBox(height: 6),
        const Text('Sign in to continue',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.grey, fontSize: 14)),
        const SizedBox(height: 24),
        _buildLabel('Email'),
        _buildTextField(controller: _emailController, hintText: 'you@example.com',
            icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _buildLabel('Password'),
        _buildTextField(controller: _passwordController, hintText: '••••••••',
            icon: Icons.lock_outline, obscureText: _obscurePassword,
            suffixIcon: _togglePasswordSuffix(_obscurePassword,
                () => setState(() => _obscurePassword = !_obscurePassword))),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
              onPressed: () async {
                final email = _emailController.text.trim();
                if (email.isEmpty) {
                  _showError('Enter your email first');
                  return;
                }
                try {
                  await _authService.sendPasswordResetEmail(email);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Password reset email sent!'),
                      backgroundColor: Colors.green.shade700,
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                } catch (e) {
                  _showError('Failed to send reset email');
                }
              },

            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Forgot Password?',
                style: TextStyle(color: AppTheme.darkGrey,
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ),
        const SizedBox(height: 8),
        _buildPrimaryButton('Sign In', _isLoading, _submitLogin),
        const SizedBox(height: 20),
        _buildDivider(),
        const SizedBox(height: 20),
        _buildGoogleButton(),
      ],
    );
  }

  Widget _buildUserSignupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Create Account',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF1B4332), fontSize: 24,
                fontWeight: FontWeight.w800, fontFamily: 'Nunito')),
        const SizedBox(height: 6),
        const Text('Join the green movement',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.grey, fontSize: 14)),
        const SizedBox(height: 24),
        _buildLabel('Full Name'),
        _buildTextField(controller: _nameController, hintText: 'John Doe',
            icon: Icons.person_outline),
        const SizedBox(height: 14),
        _buildLabel('Email'),
        _buildTextField(controller: _emailController, hintText: 'you@example.com',
            icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 14),
        _buildLabel('Phone Number'),
        _buildTextField(controller: _phoneController, hintText: '+91 98765 43210',
            icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
        const SizedBox(height: 14),
        _buildLabel('Password'),
        _buildTextField(controller: _passwordController, hintText: 'Min 8 characters',
            icon: Icons.lock_outline, obscureText: _obscurePassword,
            suffixIcon: _togglePasswordSuffix(_obscurePassword,
                () => setState(() => _obscurePassword = !_obscurePassword))),
        const SizedBox(height: 14),
        _buildLabel('Confirm Password'),
        _buildTextField(controller: _confirmPasswordController,
            hintText: 'Re-enter password', icon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            suffixIcon: _togglePasswordSuffix(_obscureConfirmPassword,
                () => setState(() =>
                    _obscureConfirmPassword = !_obscureConfirmPassword))),
        const SizedBox(height: 24),
        _buildPrimaryButton('Create Account', _isLoading, _submitUserSignup),
        const SizedBox(height: 20),
        _buildDivider(),
        const SizedBox(height: 20),
        _buildGoogleButton(),
      ],
    );
  }

  Widget _buildNgoSignupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Register Your NGO',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF1B4332), fontSize: 24,
                fontWeight: FontWeight.w800, fontFamily: 'Nunito')),
        const SizedBox(height: 6),
        const Text('Set up your organization dashboard',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.grey, fontSize: 14)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
          ),
          child: const Row(
            children: [
              Text('⚠️', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your account will be reviewed within 24–48 hours before gaining full access.',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildLabel('NGO / Organization Name *'),
        _buildTextField(controller: _ngoNameController,
            hintText: 'Vivekanand Seva Mandal', icon: Icons.business_outlined),
        const SizedBox(height: 14),
        _buildLabel('Registration Number *'),
        _buildTextField(controller: _regNumberController,
            hintText: 'e.g. MH/2021/0045678', icon: Icons.badge_outlined),
        const SizedBox(height: 14),
        _buildLabel('Contact Email *'),
        _buildTextField(controller: _emailController, hintText: 'ngo@example.org',
            icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 14),
        _buildLabel('Contact Phone *'),
        _buildTextField(controller: _phoneController,
            hintText: '+91 98765 43210', icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone),
        const SizedBox(height: 14),
        _buildLabel('Office Address *'),
        _buildTextField(controller: _addressController,
            hintText: 'Street, City, State, PIN',
            icon: Icons.location_on_outlined, maxLines: 2),
        const SizedBox(height: 14),
        _buildLabel('Password *'),
        _buildTextField(controller: _passwordController, hintText: 'Min 8 characters',
            icon: Icons.lock_outline, obscureText: _obscurePassword,
            suffixIcon: _togglePasswordSuffix(_obscurePassword,
                () => setState(() => _obscurePassword = !_obscurePassword))),
        const SizedBox(height: 14),
        _buildLabel('Confirm Password *'),
        _buildTextField(controller: _confirmPasswordController,
            hintText: 'Re-enter password', icon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            suffixIcon: _togglePasswordSuffix(_obscureConfirmPassword,
                () => setState(() =>
                    _obscureConfirmPassword = !_obscureConfirmPassword))),
        const SizedBox(height: 24),
        _buildPrimaryButton('Register NGO', _isLoading, _submitNgoSignup,
            color: const Color(0xFF2D6A4F)),
      ],
    );
  }

  Widget _buildBottomToggle() {
    if (_mode == AuthMode.login) {
      return Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account? ",
                style: TextStyle(color: AppTheme.grey, fontSize: 13)),
            GestureDetector(
              onTap: () => _switchMode(AuthMode.userSignup),
              child: const Text('Sign Up',
                  style: TextStyle(color: Color(0xFF1B4332),
                      fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
        // TODO: REMOVE BEFORE PRODUCTION
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: Column(
            children: [
              const Divider(),
              const Text('🧪 Dev Testing Only', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                      onPressed: () {
                        DevSession().loginAsNGO();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const NgoShellScreen()),
                        );
                      },
                      child: const Text('Login as NGO', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
                      onPressed: () {
                        DevSession().loginAsUser();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const UserShellScreen()),
                        );
                      },
                      child: const Text('Login as User', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ]);
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Already have an account? ',
              style: TextStyle(color: AppTheme.grey, fontSize: 13)),
          GestureDetector(
            onTap: () => _switchMode(AuthMode.login),
            child: const Text('Sign In',
                style: TextStyle(color: Color(0xFF1B4332),
                    fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      );
    }
  }

  // ----------- HELPERS -----------

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(text,
          style: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 13)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
            color: AppTheme.grey.withValues(alpha: 0.6), fontSize: 15),
        prefixIcon: Icon(icon, color: AppTheme.grey, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.offWhite,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.lightGrey)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.lightGrey)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1B4332))),
      ),
    );
  }

  Widget _buildPrimaryButton(String label, bool loading, VoidCallback onTap,
      {Color color = const Color(0xFF1B4332)}) {
    return ElevatedButton(
      onPressed: loading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: loading
          ? const SizedBox(height: 20, width: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDivider() => const Row(
        children: [
          Expanded(child: Divider(color: AppTheme.lightGrey)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Or continue with',
                style: TextStyle(color: AppTheme.grey, fontSize: 13)),
          ),
          Expanded(child: Divider(color: AppTheme.lightGrey)),
        ],
      );

  Widget _buildGoogleButton() => OutlinedButton.icon(
        onPressed: _isLoading ? null : _googleSignIn,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: const BorderSide(color: AppTheme.lightGrey),
          backgroundColor: AppTheme.offWhite,
        ),
        icon: const Text('G',
            style: TextStyle(fontWeight: FontWeight.w900,
                color: Colors.black87, fontSize: 18)),
        label: const Text('Sign in with Google',
            style: TextStyle(color: Colors.black87,
                fontWeight: FontWeight.w600, fontSize: 14)),
      );

  Widget _togglePasswordSuffix(bool obscure, VoidCallback onTap) =>
      IconButton(
        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.grey),
        onPressed: onTap,
      );
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

    var path1 = Path();
    path1.moveTo(0, size.height * 0.4);
    path1.quadraticBezierTo(size.width * 0.25, size.height * 0.2,
        size.width * 0.5, size.height * 0.5);
    path1.quadraticBezierTo(size.width * 0.75, size.height * 0.8,
        size.width, size.height * 0.3);
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    canvas.drawPath(path1, paint1);

    var path2 = Path();
    path2.moveTo(0, size.height * 0.6);
    path2.quadraticBezierTo(size.width * 0.3, size.height * 0.8,
        size.width * 0.6, size.height * 0.5);
    path2.quadraticBezierTo(size.width * 0.8, size.height * 0.3,
        size.width, size.height * 0.6);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    canvas.drawPath(path2, paint2);

    var path3 = Path();
    path3.moveTo(0, size.height * 0.8);
    path3.quadraticBezierTo(size.width * 0.5, size.height * 0.6,
        size.width, size.height * 0.7);
    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
