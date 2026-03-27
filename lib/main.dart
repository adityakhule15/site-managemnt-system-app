import 'package:flutter/material.dart';
import 'core/services/token_service.dart';
import 'features/screens/Auth/login_screen.dart';
import 'features/screens/Dashboard/dashboard.dart';
import 'features/screens/Splash Screen/splash_screen.dart';


// ── Placeholder home screen ───────────────────────────────────────────────────
// Replace this with your real home / dashboard widget.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Welcome!')),
    );
  }
}

// ── App entry point ───────────────────────────────────────────────────────────
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ordinet',
      debugShowCheckedModeBanner: false,

      // ── Required for NavigationService (context-free navigation) ──────────
      navigatorKey: NavigationService.navigatorKey,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B8A9E)),
        useMaterial3: true,
      ),

      // ── First screen the app shows ────────────────────────────────────────
      initialRoute: '/splash',

      // ── Named routes ─────────────────────────────────────────────────────
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
