import 'package:flutter/material.dart';
import 'capture_screen.dart';
import 'forge_screen.dart';
import 'timeline_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Fragment Forge'),
        backgroundColor: Colors.black.withValues(alpha: 0.4),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black,
              Colors.indigo.shade900,
              Colors.deepPurple.shade900
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Forge Your Fragments',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 60),
              _buildButton(context, 'Capture Fragment', const CaptureScreen()),
              const SizedBox(height: 24),
              _buildButton(context, 'Enter the Forge', const ForgeScreen()),
              const SizedBox(height: 24),
              _buildButton(context, 'View Timeline', const TimelineScreen()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Widget screen) {
    return ElevatedButton(
      onPressed: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        backgroundColor: Colors.deepPurpleAccent.withValues(alpha: 0.8),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 20)),
    );
  }
}