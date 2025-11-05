import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:idle_universe/app.dart';


void main() async {
  // Tạm thời không cần Firebase
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(...)

  // Bọc ứng dụng bằng ProviderScope
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}