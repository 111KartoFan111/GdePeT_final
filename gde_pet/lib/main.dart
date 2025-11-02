import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:gde_pet/features/auth/welcome_screen.dart';
import 'package:gde_pet/features/main_nav_shell.dart';
import 'package:gde_pet/providers/auth_provider.dart';
import 'package:gde_pet/providers/profile_provider.dart';
import 'package:gde_pet/providers/pet_provider.dart';
import 'package:gde_pet/providers/favorites_provider.dart';
import 'package:gde_pet/firebase_options.dart';
import 'package:gde_pet/features/auth/email_verification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFF9E1E1),
          fontFamily: 'Roboto',
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18.0,
              horizontal: 25.0,
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  // --- ИСПРАВЛЕНИЕ: Убираем Future/await и loadProfile ---
  void _loadInitialUserData(BuildContext context, String uid) {
    final profileProvider = context.read<ProfileProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();
    
    // Загружаем/подписываемся, только если профиль не загружен
    if (profileProvider.profile == null || profileProvider.profile!.uid != uid) {
      // Вызываем subscribeToProfile, который теперь управляет isLoading
      profileProvider.subscribeToProfile(uid);
    }
    // Загружаем избранное
    favoritesProvider.loadFavorites(uid);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAuthenticated) {
      final user = authProvider.user!;
      final isEmailPasswordUser = user.providerData.any((p) => p.providerId == 'password');

      if (isEmailPasswordUser && !user.emailVerified) {
        return const EmailVerificationScreen();
      }

      // --- ИСПРАВЛЕНИЕ: Убираем FutureBuilder и используем watch ---
      
      // 1. Вызываем загрузку данных
      _loadInitialUserData(context, user.uid);
      
      // 2. Слушаем ProfileProvider
      final profileProvider = context.watch<ProfileProvider>();

      // 3. Показываем загрузку, пока isLoading или profile == null
      if (profileProvider.isLoading || profileProvider.profile == null) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFEE8A9A),
            ),
          ),
        );
      }
      
      // 4. Профиль загружен, показываем главный экран
      return const MainNavShell();
      // --- КОНЕЦ ИСПРАВЛЕНИЯ ---
    }

    // Пользователь не авторизован
    return const WelcomeScreen();
  }
}

