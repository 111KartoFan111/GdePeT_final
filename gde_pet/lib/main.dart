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

  // ИЗМЕНЕНИЕ: Добавляем метод для загрузки данных
  Future<void> _loadInitialUserData(BuildContext context, String uid) async {
    // Используем context.read, так как нам не нужно слушать изменения здесь
    final profileProvider = context.read<ProfileProvider>();
    if (profileProvider.profile == null || profileProvider.profile!.uid != uid) {
      // Загружаем профиль
      await profileProvider.loadProfile(uid);
      // Подписываемся на будущие обновления
      profileProvider.subscribeToProfile(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAuthenticated) {
      // Пользователь вошел, теперь нам нужно убедиться, что профиль загружен
      return FutureBuilder(
        future: _loadInitialUserData(context, authProvider.user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Показываем индикатор загрузки, пока грузится профиль
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFEE8A9A)),
              ),
            );
          }
          
          if (snapshot.hasError) {
             // Показываем ошибку, если профиль не загрузился
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Ошибка загрузки профиля: ${snapshot.error}'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Попробовать перезагрузить
                          (context as Element).reassemble();
                        },
                        child: const Text('Попробовать снова'),
                      )
                    ],
                  ),
                ),
              ),
            );
          }

          // Профиль загружен, показываем главный экран
          return const MainNavShell();
        },
      );
    }

    if (authProvider.isGuest) {
      return const MainNavShell();
    }

    return const WelcomeScreen();
  }
}
