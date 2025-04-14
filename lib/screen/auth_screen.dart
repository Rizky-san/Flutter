import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';


class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: BoxDecoration(
              color: const Color(0xFF5B60F1),
              borderRadius: authProvider.isLogin
                  ? const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                    )
                  : const BorderRadius.only(
                      bottomRight: Radius.circular(40),
                    ),
            ),
            child: Column(
              children: [
                const Text(
                  "Fasel Aquarium",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/koi.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Form(
                key: authProvider.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authProvider.isLogin ? "LOGIN" : "REGISTER",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        hintText: "Email",
                        border: UnderlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Masukkan email yang valid';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        authProvider.enteredEmail = value!;
                      },
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        hintText: "Password",
                        border: UnderlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        authProvider.enteredPassword = value!;
                      },
                    ),
                    const SizedBox(height: 35),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () => authProvider.submit(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B60F1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          authProvider.isLogin ? "Login" : "Register",
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          authProvider.isLogin
                              ? "Don't have any account? "
                              : "Already have an account? ",
                        ),
                        GestureDetector(
                          onTap: () {
                            authProvider.toggleMode();
                          },
                          child: Text(
                            authProvider.isLogin ? "Register" : "Login",
                            style: const TextStyle(
                              color: Color(0xFF5B60F1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
