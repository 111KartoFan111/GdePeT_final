import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../main_nav_shell.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startEmailVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_isChecking) return;
      
      _isChecking = true;
      final authProvider = context.read<AuthProvider>();
      final isVerified = await authProvider.checkEmailVerification();
      _isChecking = false;

      if (isVerified && mounted) {
        _timer?.cancel();
        // --- ИЗМЕНЕНИЕ: Возвращаем навигацию ---
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavShell()),
          (route) => false,
        );
        // --- КОНЕЦ ИЗМЕНЕНИЯ ---
      }
    });
  }

  Future<void> _resendEmail() async {
// ... (resend email как и раньше)
    final authProvider = context.read<AuthProvider>();
    await authProvider.sendEmailVerification();

    if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
          content: Text('Письмо отправлено повторно'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
// ... (build как и раньше)
    final authProvider = context.watch<AuthProvider>();
    final email = authProvider.user?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.email_outlined,
                size: 100,
                color: Color(0xFFEE8A9A),
              ),
              const SizedBox(height: 40),
              Text(
                'Подтвердите ваш email',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Мы отправили письмо на\n$email',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Пожалуйста, проверьте вашу почту и перейдите по ссылке для подтверждения',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                color: Color(0xFFEE8A9A),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ожидание подтверждения...',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: _resendEmail,
                child: const Text(
                  'Отправить письмо повторно',
                  style: TextStyle(
                    color: Color(0xFFEE8A9A),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await authProvider.signOut();
                  if (mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                child: const Text(
                  'Вернуться к входу',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

