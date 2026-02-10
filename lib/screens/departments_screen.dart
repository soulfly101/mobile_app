import 'package:flutter/material.dart';
import 'package:week3_project/data/departments.dart';

class DepartmentsScreen extends StatelessWidget {
  const DepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Departments")),
      body: ListView.builder(
        itemCount: departments.length,
        itemBuilder: (context, index) {
          final dept = departments[index];
          return ListTile(
            title: Text(dept.name),
            subtitle: Text(dept.location),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/detail',
                arguments: dept,
              );
            },
          );
        },
      ),
    );
  }
}
