import 'package:flutter/material.dart';

void main() {
  runApp(const MyPortfolioApp());
}

class MyPortfolioApp extends StatelessWidget {
  const MyPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kwadwo Agyeman Portfolio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PortfolioHomePage(),
    );
  }
}

class PortfolioHomePage extends StatelessWidget {
  const PortfolioHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kwadwo Agyeman'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=3'), // Replace with your image URL
            ),
            const SizedBox(height: 20),
            const Text(
              'Hello! I am Kwadwo Agyeman',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Aspiring Software Engineer | Python & Flutter Enthusiast',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'About Me:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'I am a university student in Ghana with a passion for building apps and learning new technologies. I love solving problems and creating useful software.',
            ),
            const SizedBox(height: 20),
            const Text(
              'Contact:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text('Email: kwadwo@example.com'),
            const Text('Phone: +233 123 456 789'),
            const Text('GitHub: github.com/kwadwoagyeman'),
          ],
        ),
      ),
    );
  }
}
