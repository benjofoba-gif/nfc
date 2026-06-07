// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'enrollement_result_screen.dart';

class EnrollementScreen extends StatefulWidget {
  const EnrollementScreen({super.key});

  @override
  State<EnrollementScreen> createState() => _EnrollementScreenState();
}

class _EnrollementScreenState extends State<EnrollementScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _encodeBadge() async {
    final id = _idController.text.trim();
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final role = _roleController.text.trim();

    if (id.isEmpty || nom.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez renseigner au minimum l\'ID et le nom.')),
      );
      return;
    }

    final payload = {
      'badgeId': id,
      'nom': nom,
      'prenom': prenom,
      'role': role,
      'date': DateTime.now().toIso8601String(),
    };

    final raw = json.encode(payload);

    // Navigate to a result screen so the user always sees the generated JSON
    // and can copy or download it (web).
    if (kIsWeb) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EnrollementResultScreen(raw: raw, id: id),
        ),
      );
    } else {
      // On mobile, show a QR code dialog so another phone can scan the enrolled JSON.
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Partager (JSON)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                SelectableText(raw),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: raw));
                if (!mounted) return;
                Navigator.of(context).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('JSON copié dans le presse-papier.')),
                );
              },
              child: const Text('Copier'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enrôlement"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: "ID",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _nomController,
              decoration: const InputDecoration(
                labelText: "Nom",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _prenomController,
              decoration: const InputDecoration(
                labelText: "Prénom",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _roleController,
              decoration: const InputDecoration(
                labelText: "Rôle",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _encodeBadge,
              child: const Text("Encoder le Badge"),
            ),
          ],
        ),
      ),
    );
  }
}