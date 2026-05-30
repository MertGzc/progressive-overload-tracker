import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final StorageService _storageService = StorageService();

  bool isLogin = true;
  String? selectedRole = 'user'; // 'user' veya 'trainer'

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Lütfen tüm alanları doldurunuz';
        _isLoading = false;
      });
      return;
    }

    final user = await _storageService.loginUser(username, password);

    if (!mounted) return;

    if (user != null) {
      // Başarılı giriş
      if (user.role == 'trainer') {
        Navigator.of(context).pushReplacementNamed('/trainer');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      setState(() {
        _errorMessage = 'Kullanıcı adı veya parola hatalı';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Lütfen tüm alanları doldurunuz';
        _isLoading = false;
      });
      return;
    }

    if (username.length < 3) {
      setState(() {
        _errorMessage = 'Kullanıcı adı en az 3 karakter olmalıdır';
        _isLoading = false;
      });
      return;
    }

    if (password.length < 4) {
      setState(() {
        _errorMessage = 'Parola en az 4 karakter olmalıdır';
        _isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Parolalar eşleşmiyor';
        _isLoading = false;
      });
      return;
    }

    final success = await _storageService.registerUser(
      username,
      password,
      selectedRole ?? 'user',
    );

    if (!mounted) return;

    if (success) {
      // Başarılı kayıt ve giriş
      if (selectedRole == 'trainer') {
        Navigator.of(context).pushReplacementNamed('/trainer');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      setState(() {
        _errorMessage = 'Bu kullanıcı adı zaten var. Başka bir ad seçiniz.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),

            // Logo/Title
            const Icon(
              Icons.fitness_center,
              size: 60,
              color: Color(0xFF10b981),
            ),
            const SizedBox(height: 24),

            Text(
              'Antrenman Takip',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF10b981),
              ),
            ),
            const SizedBox(height: 8),

            Text(
              isLogin ? 'Giriş Yapın' : 'Kaydolun',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[400]),
            ),
            const SizedBox(height: 32),

            // Error Message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Username Field
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabled: !_isLoading,
              ),
            ),
            const SizedBox(height: 16),

            // Password Field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Parola',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabled: !_isLoading,
              ),
            ),
            const SizedBox(height: 16),

            // Confirm Password (only for register)
            if (!isLogin) ...[
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Parola Tekrar',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabled: !_isLoading,
                ),
              ),
              const SizedBox(height: 16),

              // Role Selection (only for register)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[600]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<String>(
                  value: selectedRole,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('Kullanıcı')),
                    DropdownMenuItem(value: 'trainer', child: Text('Antrenör')),
                  ],
                  onChanged:
                      _isLoading
                          ? null
                          : (value) {
                            setState(() {
                              selectedRole = value;
                            });
                          },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Login/Register Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : (isLogin ? _handleLogin : _handleRegister),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10b981),
                  disabledBackgroundColor: Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          isLogin ? 'Giriş Yap' : 'Kaydol',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 16),

            // Toggle Login/Register
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLogin ? 'Hesabınız yok mu? ' : 'Hesabınız var mı? ',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                TextButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            setState(() {
                              isLogin = !isLogin;
                              _errorMessage = null;
                              _usernameController.clear();
                              _passwordController.clear();
                              _confirmPasswordController.clear();
                            });
                          },
                  child: Text(
                    isLogin ? 'Kaydolun' : 'Giriş Yapın',
                    style: const TextStyle(
                      color: Color(0xFF10b981),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
