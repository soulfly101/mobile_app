import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/student.dart';
import 'task_list_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final Student student = Student(
    name: 'Kwadwo Tech',
    studentId: 'STU123456',
    programme: 'BSc Information Technology',
    level: 300,
  );

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(
                student.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Name'),
                      subtitle: Text(student.name),
                    ),
                    ListTile(
                      title: const Text('Student ID'),
                      subtitle: Text(student.studentId),
                    ),
                    ListTile(
                      title: const Text('Programme'),
                      subtitle: Text(student.programme),
                    ),
                    ListTile(
                      title: const Text('Level'),
                      subtitle: Text(student.level.toString()),
                    ),
                    ListTile(
                      title: const Text('Logged in email'),
                      subtitle: Text(user?.email ?? 'No email'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Edit Profile'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TaskListScreen(),
                  ),
                );
              },
              child: const Text('View Tasks'),
            ),
          ],
        ),
      ),
    );
  }
}