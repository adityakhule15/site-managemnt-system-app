import 'package:flutter/material.dart';
import '../../../core/utils/token_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  static const Color _primaryTeal = Color(0xFF3B8A9E);
  static const Color _accentGreen = Color(0xFF7DC242);
  static const Color _bgLight = Color(0xFFDCECF0);

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animController.forward();

    // After splash delay, decide where to navigate
    Future.delayed(const Duration(milliseconds: 2600), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    final isLoggedIn = await TokenManager.isLoggedIn();

    Navigator.pushReplacementNamed(
      context,
      isLoggedIn ? '/home' : '/login',
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: Stack(
        children: [
          // ── Background blobs ──────────────────
          _buildBlobs(context),

          // ── Centred content ───────────────────
          Center(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (_, __) => FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo card
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryTeal.withOpacity(0.18),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: CustomPaint(
                            size: const Size(80, 80),
                            painter: _SplashLogoPainter(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // App name
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'ordi',
                              style: TextStyle(
                                color: _primaryTeal,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                            TextSpan(
                              text: 'n',
                              style: TextStyle(
                                color: _accentGreen,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                            TextSpan(
                              text: 'et',
                              style: TextStyle(
                                color: _primaryTeal,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Tagline
                      Text(
                        'SITE MANAGEMENT SYSTEM',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 2.5,
                          color: Colors.blueGrey.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Loading dots
                      _LoadingDots(color: _primaryTeal),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Footer ────────────────────────────
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _fadeAnim,
              builder: (_, __) => Opacity(
                opacity: _fadeAnim.value,
                child: Text(
                  '© 2026 Ordinet · All rights reserved',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlobs(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        Positioned(
          top: -70,
          right: -70,
          child: _blob(240, const Color(0xFFB0D8E0)),
        ),
        Positioned(
          bottom: -90,
          left: -90,
          child: _blob(280, const Color(0xFFCFDFC0)),
        ),
        Positioned(
          top: h * 0.38,
          right: -30,
          child: _blob(140, const Color(0xFFB6D9E2)),
        ),
      ],
    );
  }

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.55),
          shape: BoxShape.circle,
        ),
      );
}

// ─────────────────────────────────────────────
//  Animated loading dots
// ─────────────────────────────────────────────
class _LoadingDots extends StatefulWidget {
  final Color color;
  const _LoadingDots({required this.color});

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(reverse: true),
    );

    _anims = List.generate(
      3,
      (i) => Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _controllers[i], curve: Curves.easeInOut),
      ),
    );

    // Stagger each dot
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _anims[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(_anims[i].value),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
//  Splash logo painter (spiral icon only)
// ─────────────────────────────────────────────
class _SplashLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final teal = Paint()
      ..color = const Color(0xFF3B8A9E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final green = Paint()
      ..color = const Color(0xFF7DC242)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Outer circle
    canvas.drawCircle(Offset(cx, cy), size.width * 0.42, teal);
    // Middle circle
    canvas.drawCircle(Offset(cx, cy), size.width * 0.26, teal);
    // Inner dot
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.09,
      teal..style = PaintingStyle.fill,
    );
    teal.style = PaintingStyle.stroke;

    // Green swish underline
    final path = Path()
      ..moveTo(cx - size.width * 0.38, cy + size.height * 0.44)
      ..quadraticBezierTo(
        cx,
        cy + size.height * 0.6,
        cx + size.width * 0.38,
        cy + size.height * 0.44,
      );
    canvas.drawPath(path, green);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
