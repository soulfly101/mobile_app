import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/departments_screen.dart';
import 'screens/department_detail_screen.dart';

void main() {
  runApp(const CampusDirectoryApp());
}

class CampusDirectoryApp extends StatelessWidget {
  const CampusDirectoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Directory',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/departments': (context) => const DepartmentsScreen(),
        '/detail': (context) => const DepartmentDetailScreen(),
      },
    );
  }
}
