import 'package:flutter/material.dart';
import 'package:flutter_firebase/services/auth_service.dart';
import 'package:flutter_firebase/services/user_service.dart';

class AuthProvider with ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  bool isLogin = true;

  String enteredEmail = '';
  String enteredPassword = '';

  void toggleMode() {
    isLogin = !isLogin;
    notifyListeners();
  }

  void submit(BuildContext context) async {
  if (!formKey.currentState!.validate()) return;

  formKey.currentState!.save();

  try {
    if (isLogin) {
      // LOGIN
      final user = await AuthService().loginUser(enteredEmail, enteredPassword);
      if (user != null) {
        final role = await UserService.getUserRole(user.uid);

        if (role == 'admin') {
          Navigator.of(context).pushReplacementNamed('/admin-dashboard');
        } else {
          Navigator.of(context).pushReplacementNamed('/user-home');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login berhasil! Selamat datang ${user.email}")),
        );
      }
    } else {
      // REGISTER
      final user = await AuthService().registerUser(enteredEmail, enteredPassword);
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi berhasil! Silakan login.")),
        );
        toggleMode(); // pindah ke form login
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}
}
