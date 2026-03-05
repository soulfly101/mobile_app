import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/coin_viewmodel.dart';
import 'views/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CoinViewModel()..loadCoins(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Week 6 API App',
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}