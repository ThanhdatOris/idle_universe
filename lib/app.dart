import 'package:flutter/material.dart';
import 'package:idle_universe/core/config/theme/app_theme.dart';
import 'package:idle_universe/core/screens/main_screen.dart';
import 'package:idle_universe/core/widgets/widgets.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Idle Universe Builder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      home: const MainScreen(),
      builder: (context, child) {
        return AchievementNotificationOverlay(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
