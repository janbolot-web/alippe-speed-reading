import 'package:client/screens/calendar/screens/main_navigation_page.dart';
import 'package:client/screens/reading_game_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru', null);
  await initializeDateFormatting('ky', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Шар окуу оюнун түзүү',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReadingGameScreen()),
                );
              },
              child: const Text('SHAR OKUU'),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainNavigationPage()),
                );
              },
              child: const Text('KALENDAR'),
            )
          ],
        ),
      ),
    );
  }
}
