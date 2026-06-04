import 'package:flutter/material.dart';
import '../models/log_access.dart';

class HistoriqueScreen extends StatelessWidget {
  final List<LogAccess> logs;

  const HistoriqueScreen({
    super.key,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique"),
      ),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];

          return ListTile(
            title: Text(log.nom),
            subtitle: Text(
              "${log.statut} - ${log.dateScan}",
            ),
          );
        },
      ),
    );
  }
}