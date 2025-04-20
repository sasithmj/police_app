import 'package:flutter/material.dart';
import 'package:police_app/Providers/AuthProvider.dart';
import 'package:police_app/Screens/Authentication/Login.dart';
import 'package:police_app/Screens/Home/Home.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isCheckingLogin = true;

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  void _tryAutoLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = await authProvider.tryAutoLogin();
    if (!success) {
      print("Auto-login failed, redirecting to login screen.");
    }
    setState(() {
      _isCheckingLogin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return authProvider.isLoggedIn ? const HomePage() : const LoginPage();
  }
}
