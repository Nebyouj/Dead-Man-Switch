import 'package:flutter/material.dart';

import 'login_page.dart';
import 'register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _showRegister = false;

  void _showLogin() {
    setState(() {
      _showRegister = false;
    });
  }

  void _showRegisterPage() {
    setState(() {
      _showRegister = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showRegister
        ? RegisterPage(
            onLogin: _showLogin,
          )
        : LoginPage(
            onRegister: _showRegisterPage,
          );
  }
}