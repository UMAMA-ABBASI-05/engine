import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _showPass = false;

  Future<void> _signup() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      _showSnack('Email aur password zaruri hain', Colors.red);
      return;
    }
    setState(() => _loading = true);
    try {
      final api = ApiService();
      await api.signup(_emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      _showSnack('Account created! Please login.', Colors.green);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
    } catch (e) {
      _showSnack(e.toString().replaceAll('Exception: ', ''), Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A365D),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign up to get started',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Email
                _buildLabel('Email'),
                _inputField(
                  ctrl: _emailCtrl,
                  hint: 'Enter your email',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),

                // Password
                _buildLabel('Password'),
                _passwordField(),
                const SizedBox(height: 32),

                // Signup Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A365D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _loading ? null : _signup,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Color(0xFF1A365D),
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A365D),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextField(
        controller: _passCtrl,
        obscureText: !_showPass,
        decoration: InputDecoration(
          hintText: 'Enter your password',
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(
              _showPass ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () => setState(() => _showPass = !_showPass),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
