import 'package:flutter/material.dart';
import 'package:police_app/AuthWrapper.dart';
import 'package:police_app/Providers/AuthProvider.dart';
import 'package:police_app/Providers/ViolationProvider.dart';
import 'package:police_app/theme/AppColors.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ViolationProvider()),
      ],
      child: MaterialApp(
        title: 'Sri Lankan Road Rules',
        theme: buildAppTheme(),
        navigatorKey: navigatorKey,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
