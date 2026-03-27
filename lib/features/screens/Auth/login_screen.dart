import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../../../core/services/token_service.dart';
import '../../../core/utils/token_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ── Controllers ──────────────────────────────
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ── State ─────────────────────────────────────
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // ── Brand colours (matching the Ordinet palette) ──
  static const Color _primaryTeal = Color(0xFF3B8A9E);
  static const Color _accentGreen = Color(0xFF7DC242);
  static const Color _bgLight = Color(0xFFDCECF0);
  static const Color _labelGrey = Color(0xFF6B8EA0);

  // ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Auto-redirect if already logged in ────────
  Future<void> _checkLoginStatus() async {
    if (await TokenManager.isLoggedIn()) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  // ── Connectivity check ────────────────────────
  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void _showOfflineToast() {
    Fluttertoast.showToast(
      msg: 'No internet connection. Please check your network.',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red.shade700,
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  // ── Login API call ────────────────────────────
  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Basic validation
    if (username.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter your username and password.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return;
    }

    // ── Offline guard ──────────────────────────
    if (!await _isOnline()) {
      _showOfflineToast();
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Clear any existing tokens before new login
      await TokenManager.clearAll();

      // ── POST /api/login/ ──────────────────────
      // Adjust the URL & payload keys to match your backend.
      final response = await http.post(
        Uri.parse(BaseUrls.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['data'] != null) {
        final userData = jsonResponse['data'];

        // Save tokens
        final String? accessToken =
            userData['accessToken'] ?? userData['access_token'];
        final String? refreshToken =
            userData['refreshToken'] ?? userData['refresh_token'];

        if (accessToken != null && accessToken.isNotEmpty) {
          await TokenManager.saveAccessToken(accessToken);
        }
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await TokenManager.saveRefreshToken(refreshToken);
        }

        // Save user info
        if (userData['user_id'] != null) {
          await TokenManager.saveUserId(userData['user_id']);
        }

        final firstName = userData['first_name'] ?? '';
        final lastName = userData['last_name'] ?? '';
        if (firstName.isNotEmpty) {
          await TokenManager.saveUserName('$firstName $lastName'.trim());
        }

        await TokenManager.saveBool('SaveLogin', _rememberMe);

        Fluttertoast.showToast(
          msg: 'Login successful!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        _navigateToHome();
      } else {
        final errorMsg =
            jsonResponse['message'] ?? 'Login failed. Please try again.';
        Fluttertoast.showToast(
          msg: errorMsg,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      // Network or parsing error
      if (!await _isOnline()) {
        _showOfflineToast();
      } else {
        Fluttertoast.showToast(
          msg: 'Please check your internet connection and try again.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Test login for development (without API) ──
  Future<void> _testLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter username and password',
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.orange,
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Clear any existing tokens
    await TokenManager.clearAll();

    // Save test data
    await TokenManager.saveAccessToken('test_token_${DateTime.now().millisecondsSinceEpoch}');
    await TokenManager.saveRefreshToken('test_refresh_${DateTime.now().millisecondsSinceEpoch}');
    await TokenManager.saveUserId(1);
    await TokenManager.saveUserName(username);
    await TokenManager.saveBool('SaveLogin', _rememberMe);

    Fluttertoast.showToast(
      msg: 'Test login successful',
      backgroundColor: Colors.green,
    );

    _navigateToHome();
    setState(() => _isLoading = false);
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: Stack(
        children: [
          // ── Blurred blob decorations ────────────
          _buildBackgroundBlobs(),

          // ── Scrollable content ──────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    // ── Card ─────────────────────
                    _buildCard(),
                    // ── Footer ───────────────────
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Card
  // ─────────────────────────────────────────────
  Widget _buildCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo image ──────────────────────────
          Center(child: _buildLogo()),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'SITE MANAGEMENT SYSTEM',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 2,
                color: _labelGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── Heading ─────────────────────────────
          Center(
            child: const Text(
              'Welcome back',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Sign in to your account to continue',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ),
          const SizedBox(height: 28),

          // ── Username field ──────────────────────
          _fieldLabel('USERNAME'),
          const SizedBox(height: 8),
          _buildUsernameField(),
          const SizedBox(height: 20),

          // ── Password field ──────────────────────
          _fieldLabel('PASSWORD'),
          const SizedBox(height: 8),
          _buildPasswordField(),
          const SizedBox(height: 16),

          const SizedBox(height: 10),

          // ── Sign In button ──────────────────────
          _buildSignInButton(),
          const SizedBox(height: 20),

          // Test mode button (remove in production)
          _buildTestButton(),
        ],
      ),
    );
  }

  // ── Test button for development ────────────────
  Widget _buildTestButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _testLogin,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.orange,
          side: const BorderSide(color: Colors.orange),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('TEST MODE (Skip API)'),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Logo — image container
  // ─────────────────────────────────────────────
  Widget _buildLogo() {
    return SizedBox(
      width: 180,
      height: 80,
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 180,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F8FA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFFB8D4DC), width: 1),
            ),
            child: const Center(
              child: Text(
                'Company Logo',
                style: TextStyle(
                  color: Color(0xFF6B8EA0),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Field label
  // ─────────────────────────────────────────────
  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: _primaryTeal,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Username field
  // ─────────────────────────────────────────────
  Widget _buildUsernameField() {
    return TextField(
      controller: _usernameController,
      keyboardType: TextInputType.text,
      cursorColor: _primaryTeal,
      style: const TextStyle(fontSize: 14),
      decoration: _inputDecoration(
        hint: 'Enter your username',
        prefixIcon: const Icon(Icons.person_outline_rounded,
            color: _labelGrey, size: 20),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Password field
  // ─────────────────────────────────────────────
  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      cursorColor: _primaryTeal,
      style: const TextStyle(fontSize: 14),
      onSubmitted: (_) => _login(),
      decoration: _inputDecoration(
        hint: 'Enter your password',
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            color: _labelGrey, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: _labelGrey,
            size: 20,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Shared input decoration
  // ─────────────────────────────────────────────
  InputDecoration _inputDecoration({
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF2F8FA),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: Color(0xFFB8D4DC), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: Color(0xFFB8D4DC), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryTeal, width: 1.5),
      ),
    );
  }


  // ─────────────────────────────────────────────
  //  Sign In button
  // ─────────────────────────────────────────────
  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryTeal,
          disabledBackgroundColor: _primaryTeal.withOpacity(0.6),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
              color: Colors.white, strokeWidth: 2.5),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign In',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Background blobs
  // ─────────────────────────────────────────────
  Widget _buildBackgroundBlobs() {
    return Stack(
      children: [
        // Top-right teal blob
        Positioned(
          top: -60,
          right: -60,
          child: _blob(220, const Color(0xFFB0D8E0)),
        ),
        // Bottom-left green blob
        Positioned(
          bottom: -80,
          left: -80,
          child: _blob(260, const Color(0xFFCFDFC0)),
        ),
        // Middle-right smaller blob
        Positioned(
          top: MediaQuery.of(context).size.height * 0.35,
          right: -30,
          child: _blob(140, const Color(0xFFB6D9E2)),
        ),
      ],
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.55),
        shape: BoxShape.circle,
      ),
    );
  }
}