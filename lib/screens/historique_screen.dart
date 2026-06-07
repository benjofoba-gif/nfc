import 'package:flutter/material.dart';
import '../models/log_access.dart';

class HistoriqueScreen extends StatelessWidget {
  final List<LogAccess> logs;
  final VoidCallback onClear;

  const HistoriqueScreen({
    super.key,
    required this.logs,
    required this.onClear,
  });

  String _formatDate(DateTime date) {
    return date.toLocal().toString().split('.').first;
  }

  @override
  Widget build(BuildContext context) {
    final orderedLogs = logs.toList()
      ..sort((a, b) => b.dateScan.compareTo(a.dateScan));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique"),
        actions: [
          IconButton(
            onPressed: () {
              onClear();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Effacer l’historique',
          ),
        ],
      ),
      body: orderedLogs.isEmpty
          ? const Center(
              child: Text('Aucun journal de passage disponible.'),
            )
          : ListView.builder(
              itemCount: orderedLogs.length,
              itemBuilder: (context, index) {
                final log = orderedLogs[index];
                return ListTile(
                  title: Text(log.nom),
                  subtitle: Text('${log.statut} • ${_formatDate(log.dateScan)}'),
                  trailing: Text(log.badgeId),
                );
              },
            ),
    );
  }
}
