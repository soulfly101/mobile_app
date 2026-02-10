import 'package:flutter/material.dart';
import 'package:week3_project/data/departments.dart';

class DepartmentDetailScreen extends StatefulWidget {
  const DepartmentDetailScreen({super.key});

  @override
  State<DepartmentDetailScreen> createState() =>
      _DepartmentDetailScreenState();
}

class _DepartmentDetailScreenState extends State<DepartmentDetailScreen> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final dept =
        ModalRoute.of(context)!.settings.arguments as Department;

    return Scaffold(
      appBar: AppBar(
        title: Text(dept.name),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Location: ${dept.location}"),
            Text("Phone: ${dept.phone}"),
            const SizedBox(height: 20),
            Text(dept.description),
          ],
        ),
      ),
    );
  }
}
