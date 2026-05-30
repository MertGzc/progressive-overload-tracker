import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_register_screen.dart';
import 'screens/trainer_dashboard_screen.dart';
import 'services/storage_service.dart';
import 'models/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final StorageService _storageService = StorageService();
  User? _currentUser;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Default verileri başlat (varsa yapma)
    await _storageService.initializeDefaultData();
    // Auth durumunu kontrol et
    await _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final user = await _storageService.getCurrentUser();
    setState(() {
      _currentUser = user;
      _isCheckingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Antrenman Takip',
      debugShowCheckedModeBanner: false,
      theme: _darkTheme(),
      home:
          _isCheckingAuth
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : (_currentUser == null
                  ? const LoginRegisterScreen()
                  : (_currentUser!.role == 'trainer'
                      ? const TrainerDashboardScreen()
                      : const HomeScreen())),
      routes: {
        '/login': (context) => const LoginRegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/trainer': (context) => const TrainerDashboardScreen(),
      },
      onGenerateRoute: (settings) {
        if (_isCheckingAuth) {
          return MaterialPageRoute(
            builder:
                (context) => const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
          );
        }

        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(
              builder: (context) => const LoginRegisterScreen(),
            );
          case '/home':
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          case '/trainer':
            return MaterialPageRoute(
              builder: (context) => const TrainerDashboardScreen(),
            );
          default:
            if (_currentUser == null) {
              return MaterialPageRoute(
                builder: (context) => const LoginRegisterScreen(),
              );
            } else if (_currentUser!.role == 'trainer') {
              return MaterialPageRoute(
                builder: (context) => const TrainerDashboardScreen(),
              );
            } else {
              return MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              );
            }
        }
      },
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF10b981),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF09090b),
      cardColor: const Color(0xFF18181b),
    );
  }
}
