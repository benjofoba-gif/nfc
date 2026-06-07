import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:ndef_record/ndef_record.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/log_access.dart';
import '../services/log_storage.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final LogStorage _storage = LogStorage();
  String message = "Approchez votre badge";
  Color backgroundColor = Colors.white;
  bool _isScanning = false;
  bool _nfcAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
  }

  Future<void> _checkNfcAvailability() async {
    final availability = await NfcManager.instance.checkAvailability();
    setState(() {
      _nfcAvailable = availability == NfcAvailability.enabled;
    });
  }

  String _parseTextPayload(NdefRecord record) {
    final payload = record.payload;
    if (payload.isEmpty) {
      return '';
    }

    final statusByte = payload[0];
    final languageCodeLength = statusByte & 0x3F;
    final textBytes = payload.sublist(1 + languageCodeLength);
    return utf8.decode(textBytes);
  }

  Future<void> _saveLog(String statut, String badgeId, String nom) async {
    final log = LogAccess(
      badgeId: badgeId,
      nom: nom,
      statut: statut,
      dateScan: DateTime.now(),
    );
    await _storage.addLog(log);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Journal ajouté : $statut'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _startScan() async {
    if (!_nfcAvailable) {
      setState(() {
        message = 'NFC non disponible sur cet appareil.';
        backgroundColor = Colors.orange.shade100;
      });
      return;
    }

    setState(() {
      _isScanning = true;
      message = 'En attente du badge...';
      backgroundColor = Colors.blue.shade50;
    });

    await NfcManager.instance.startSession(
      pollingOptions: {NfcPollingOption.iso14443},
      onDiscovered: (NfcTag tag) async {
        try {
          final ndef = NdefAndroid.from(tag);
          if (ndef == null) {
            throw Exception('Tag NDEF non supporté');
          }

          var ndefMessage = ndef.cachedNdefMessage ?? await ndef.getNdefMessage();

          if (ndefMessage == null || ndefMessage.records.isEmpty) {
            throw Exception('Aucun enregistrement NDEF');
          }

          final payloadRecord = ndefMessage.records.first;
          final payloadText = _parseTextPayload(payloadRecord);
          String badgeId = 'INCONNU';
          String nom = 'Inconnu';
          String statut = 'Badge lu';

          if (payloadText.isNotEmpty) {
            try {
              final data = json.decode(payloadText) as Map<String, dynamic>;
              badgeId = data['badgeId']?.toString() ?? data['id']?.toString() ?? badgeId;
              nom = data['nom']?.toString() ?? data['name']?.toString() ?? nom;
              final access = data['access'];
              if (access == true || access == 'autorise' || access == 'authorized') {
                statut = 'Accès autorisé';
              } else if (access == false || access == 'refuse' || access == 'denied') {
                statut = 'Accès refusé';
              } else {
                statut = 'Badge lu';
              }
            } catch (_) {
              badgeId = payloadText;
              nom = 'Badge inconnu';
              statut = 'Badge lu';
            }
          }

          await _saveLog(statut, badgeId, nom);
          setState(() {
            message = statut;
            backgroundColor = statut == 'Accès autorisé'
                ? Colors.green.shade100
                : statut == 'Accès refusé'
                    ? Colors.red.shade100
                    : Colors.blue.shade100;
          });
        } catch (error) {
          await _saveLog('Lecture invalide', 'INCONNU', 'Badge invalide');
          setState(() {
            message = 'Erreur de lecture : ${error.toString()}';
            backgroundColor = Colors.red.shade100;
          });
        } finally {
          await NfcManager.instance.stopSession();
          if (mounted) {
            setState(() {
              _isScanning = false;
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Scanner NFC"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.nfc,
              size: 120,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (kIsWeb) ...[
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    message = "✓ Accès autorisé";
                    backgroundColor = Colors.green.shade100;
                  });
                  await _saveLog("Accès autorisé", "WEB-BADGE-001", "Jean Dupont");
                },
                child: const Text("Simuler accès autorisé"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    message = "✗ Accès refusé";
                    backgroundColor = Colors.red.shade100;
                  });
                  await _saveLog("Accès refusé", "WEB-BADGE-999", "Badge invalide");
                },
                child: const Text("Simuler accès refusé"),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _isScanning ? null : _startScan,
                child: Text(_isScanning ? 'Scan en cours...' : 'Scanner le badge'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
