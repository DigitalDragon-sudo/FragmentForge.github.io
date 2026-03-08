import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/fragment.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(FragmentAdapter());
  await Hive.openBox<Fragment>('fragments');
  runApp(const FragmentForgeApp());
}

class FragmentForgeApp extends StatelessWidget {
  const FragmentForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fragment Forge',
      debugShowCheckedModeBanner: false,
theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.deepPurpleAccent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        cardColor: Colors.deepPurple.shade900.withValues(alpha: 0.6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
