import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade600,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(4), 
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'images/icon.png',
                width: 120,
                height: 120,
              ),
            ),
          ),
          const SizedBox(height: 20),

            // Nombre
            const Text(
              'AlzheCare',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 8),

            // Slogan
            const Text(
              'Cuidado inteligente, esperanza real',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
