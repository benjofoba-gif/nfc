import 'package:flutter/material.dart';

import '../models/log_access.dart';
import '../services/log_storage.dart';
import 'enrollement_screen.dart';
import 'scanner_screen.dart';
import 'historique_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LogStorage _storage = LogStorage();
  List<LogAccess> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await _storage.loadLogs();
    setState(() {
      _logs = logs;
      _loading = false;
    });
  }

  Future<void> _clearLogs() async {
    await _storage.clearLogs();
    await _loadLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NFC ACCESS"),
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
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
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoriqueScreen(
                            logs: _logs,
                            onClear: _clearLogs,
                          ),
                        ),
                      );
                      await _loadLogs();
                    },
                    child: Text("Historique (${_logs.length})"),
                  ),
                ],
              ),
      ),
    );
  }
}
