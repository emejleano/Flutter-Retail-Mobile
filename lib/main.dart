import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retail Analytics',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        // Use Material 3 typography defaults for a modern look
        textTheme: Typography.material2021().black,
      ),
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
    );
  }
}
