import 'package:flutter/material.dart';
import '../services/nfc_write_service.dart';

/// Bannière affichant le résultat d'une opération NFC (succès ou échec).
class ResultBanner extends StatelessWidget {
  final NfcWriteResult result;

  const ResultBanner({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final Color bgColor = result.success
        ? const Color(0xFF0F2419)
        : const Color(0xFF2D0F0F);
    final Color borderColor = result.success
        ? const Color(0xFF3FB950)
        : const Color(0xFFF85149);
    final Color iconColor = result.success
        ? const Color(0xFF3FB950)
        : const Color(0xFFF85149);
    final IconData icon = result.success
        ? Icons.check_circle_outline
        : Icons.error_outline;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              result.message,
              style: TextStyle(
                color: iconColor,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
