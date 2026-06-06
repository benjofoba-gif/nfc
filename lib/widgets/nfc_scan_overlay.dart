import 'package:flutter/material.dart';

/// Overlay affiché pendant la session d'écriture NFC.
/// Bloque l'UI et indique à l'utilisateur d'approcher son badge.
class NfcScanOverlay extends StatefulWidget {
  final String statusMessage;
  final VoidCallback onCancel;

  const NfcScanOverlay({
    super.key,
    required this.statusMessage,
    required this.onCancel,
  });

  @override
  State<NfcScanOverlay> createState() => _NfcScanOverlayState();
}

class _NfcScanOverlayState extends State<NfcScanOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF30363D)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF58A6FF).withOpacity(0.15),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône NFC animée
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1F6FEB).withOpacity(0.15),
                    border: Border.all(
                      color: const Color(0xFF58A6FF),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.nfc,
                    size: 48,
                    color: Color(0xFF58A6FF),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Titre
              const Text(
                'Écriture NFC en cours',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              // Message de statut
              Text(
                widget.statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF8B949E),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Barre de progression indéterminée
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  backgroundColor: Color(0xFF30363D),
                  color: Color(0xFF58A6FF),
                ),
              ),
              const SizedBox(height: 24),

              // Bouton annuler
              TextButton.icon(
                onPressed: widget.onCancel,
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Annuler'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFF85149),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
