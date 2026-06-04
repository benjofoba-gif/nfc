import 'package:flutter/material.dart';

import 'enrollement_screen.dart';
import 'scanner_screen.dart';
import 'historique_screen.dart';
import '../models/log_access.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NFC ACCESS"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EnrollementScreen(),
                  ),
                );
              },
              child: const Text("Enrôlement"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScannerScreen(),
                  ),
                );
              },
              child: const Text("Scanner"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoriqueScreen(
                      logs: <LogAccess>[],
                    ),
                  ),
                );
              },
              child: const Text("Historique"),
            ),
          ],
        ),
      ),
    );
  }
}