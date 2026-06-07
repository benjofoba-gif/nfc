// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:html' as html;

class EnrollementResultScreen extends StatelessWidget {
  final String raw;
  final String id;
  const EnrollementResultScreen({super.key, required this.raw, required this.id});

  Future<void> _downloadJson(BuildContext context) async {
    try {
      final bytes = utf8.encode(raw);
      final blob = html.Blob([bytes], 'application/json');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement;
      anchor.href = url;
      anchor.download = '${id.isNotEmpty ? id : 'badge'}.json';
      html.document.body!.append(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Téléchargement lancé')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur téléchargement: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enrôlement — résultat')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('JSON généré :', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(child: SingleChildScrollView(child: SelectableText(raw))),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Copier'),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: raw));
                        if (!Navigator.of(context).mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('JSON copié')));
                      },
                ),
              ),
              const SizedBox(width: 12),
              if (kIsWeb)
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Télécharger'),
                    onPressed: () => _downloadJson(context),
                  ),
                ),
            ]),
            const SizedBox(height: 8),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Retour')),
          ],
        ),
      ),
    );
  }
}
