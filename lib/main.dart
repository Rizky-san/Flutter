import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:provider/provider.dart';
import 'provider/auth_provider.dart';
import 'screen/auth_screen.dart';
import 'screen/admin/dashboard_screen.dart';
import 'screen/user/home_screen.dart';
import 'services/user_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // <- Tambahkan ini
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(), // <- ini punya kita
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fasel Aquarium',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF5B60F1),
        ),
        home: const SplashWrapper(),
      ),
    );
  }
}

class SplashWrapper extends StatelessWidget {
  const SplashWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          return FutureBuilder<String?>(
            future: UserService.getUserRole(user.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (roleSnapshot.hasData) {
                final role = roleSnapshot.data;
                if (role == 'admin') {
                  return const DashboardScreen();
                } else {
                  return const HomePage();
                }
              } else {
                return const AuthScreen();
              }
            },
          );
        }

        return const AuthScreen();
      },
    );
  }
}
