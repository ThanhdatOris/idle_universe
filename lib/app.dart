import 'package:flutter/material.dart';
import 'package:idle_universe/features/home/presentation/screens/home_screen.dart';
import 'package:idle_universe/core/config/theme/app_theme.dart';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Idle Universe Builder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      home: const HomeScreen(),
    );
  }
}