import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../services/nfc_write_service.dart';
import '../widgets/nfc_scan_overlay.dart';
import '../widgets/result_banner.dart';

/// Écran d'enrôlement NFC (tâche Étudiant 3)
/// Permet de saisir les informations d'un utilisateur, de les sérialiser
/// en JSON et de les écrire sur un badge NFC au format NDEF.
class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  // ─── Contrôleurs & clé de formulaire ────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  String _selectedRole = 'etudiant';
  bool _acces = true;

  // ─── État ────────────────────────────────────────────────────────────────────
  bool _isWriting = false;
  String _nfcStatus = '';
  NfcWriteResult? _lastResult;

  final NfcWriteService _nfcService = NfcWriteService();
  final Uuid _uuid = const Uuid();

  // ─── Options de rôle ─────────────────────────────────────────────────────────
  static const List<Map<String, String>> _roles = [
    {'value': 'etudiant', 'label': 'Étudiant'},
    {'value': 'employe', 'label': 'Employé'},
    {'value': 'admin', 'label': 'Administrateur'},
    {'value': 'visiteur', 'label': 'Visiteur'},
  ];

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    super.dispose();
  }

  // ─── Logique d'écriture ───────────────────────────────────────────────────────
  Future<void> _startNfcWrite() async {
    if (!_formKey.currentState!.validate()) return;

    // Construction du modèle utilisateur
    final user = UserModel(
      id: _uuid.v4(),
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      role: _selectedRole,
      acces: _acces,
      dateEnrolement: DateTime.now().toIso8601String(),
    );

    setState(() {
      _isWriting = true;
      _lastResult = null;
      _nfcStatus = 'Approchez le badge NFC...';
    });

    // Appel au service d'écriture
    final result = await _nfcService.writeUserToBadge(
      user: user,
      onStatusChanged: (status) {
        if (mounted) setState(() => _nfcStatus = status);
      },
    );

    if (mounted) {
      setState(() {
        _isWriting = false;
        _lastResult = result;
      });

      // Réinitialise le formulaire en cas de succès
      if (result.success) {
        _formKey.currentState!.reset();
        _nomController.clear();
        _prenomController.clear();
        setState(() {
          _selectedRole = 'etudiant';
          _acces = true;
        });
      }
    }
  }

  Future<void> _cancelWrite() async {
    await _nfcService.cancelSession();
    if (mounted) setState(() => _isWriting = false);
  }

  // ─── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        title: const Text(
          'Enrôlement NFC',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFF30363D)),
        ),
      ),
      body: Stack(
        children: [
          // Formulaire principal
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bannière résultat
                  if (_lastResult != null) ...[
                    ResultBanner(result: _lastResult!),
                    const SizedBox(height: 20),
                  ],

                  // En-tête section
                  _sectionHeader('Informations de l\'utilisateur', Icons.person_outline),
                  const SizedBox(height: 16),

                  // Champ Nom
                  _buildTextField(
                    controller: _nomController,
                    label: 'Nom',
                    hint: 'Ex: DUPONT',
                    icon: Icons.badge_outlined,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Le nom est requis' : null,
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 14),

                  // Champ Prénom
                  _buildTextField(
                    controller: _prenomController,
                    label: 'Prénom',
                    hint: 'Ex: Jean',
                    icon: Icons.person_outline,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Le prénom est requis' : null,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 14),

                  // Sélecteur de rôle
                  _sectionLabel('Rôle'),
                  const SizedBox(height: 8),
                  _buildRoleSelector(),
                  const SizedBox(height: 20),

                  // Switch accès
                  _buildAccessSwitch(),
                  const SizedBox(height: 32),

                  // Séparateur
                  _sectionHeader('Écriture sur badge', Icons.nfc),
                  const SizedBox(height: 16),

                  // Aperçu JSON
                  _buildJsonPreview(),
                  const SizedBox(height, height: 24),

                  // Bouton d'écriture
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _isWriting ? null : _startNfcWrite,
                      icon: const Icon(Icons.nfc, size: 22),
                      label: const Text(
                        'Écrire sur le badge NFC',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF238636),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF238636).withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Overlay de scan NFC
          if (_isWriting)
            NfcScanOverlay(
              statusMessage: _nfcStatus,
              onCancel: _cancelWrite,
            ),
        ],
      ),
    );
  }

  // ─── Widgets helpers ──────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF58A6FF), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF58A6FF),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF8B949E),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      textCapitalization: textCapitalization,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF8B949E), size: 20),
        labelStyle: const TextStyle(color: Color(0xFF8B949E)),
        hintStyle: const TextStyle(color: Color(0xFF484F58)),
        filled: true,
        fillColor: const Color(0xFF161B22),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF58A6FF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFF85149)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFF85149), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFF85149)),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _roles.map((role) {
        final bool selected = _selectedRole == role['value'];
        return GestureDetector(
          onTap: () => setState(() => _selectedRole = role['value']!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF1F6FEB) : const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? const Color(0xFF58A6FF) : const Color(0xFF30363D),
              ),
            ),
            child: Text(
              role['label']!,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF8B949E),
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAccessSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Row(
        children: [
          Icon(
            _acces ? Icons.lock_open_outlined : Icons.lock_outlined,
            color: _acces ? const Color(0xFF3FB950) : const Color(0xFFF85149),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Accès autorisé',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
                Text(
                  _acces
                      ? 'Cet utilisateur aura accès au système'
                      : 'Accès refusé pour cet utilisateur',
                  style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: _acces,
            onChanged: (v) => setState(() => _acces = v),
            activeColor: const Color(0xFF3FB950),
            inactiveThumbColor: const Color(0xFFF85149),
            inactiveTrackColor: const Color(0xFFF85149).withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonPreview() {
    if (_nomController.text.isEmpty && _prenomController.text.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF30363D)),
        ),
        child: const Text(
          '// Remplissez le formulaire pour voir l\'aperçu JSON',
          style: TextStyle(color: Color(0xFF484F58), fontSize: 12, fontFamily: 'monospace'),
        ),
      );
    }

    final preview = {
      'id': '<uuid-généré>',
      'nom': _nomController.text.trim().toUpperCase(),
      'prenom': _prenomController.text.trim(),
      'role': _selectedRole,
      'acces': _acces,
      'dateEnrolement': '<ISO-8601>',
    };

    final jsonLines = preview.entries.map((e) {
      final val = e.value is String ? '"${e.value}"' : e.value.toString();
      return '  "${e.key}": $val';
    }).join(',\n');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '// Données qui seront écrites sur le badge',
            style: TextStyle(color: Color(0xFF484F58), fontSize: 11, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 6),
          Text(
            '{\n$jsonLines\n}',
            style: const TextStyle(
              color: Color(0xFF79C0FF),
              fontSize: 12,
              fontFamily: 'monospace',
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// Extension pour SizedBox avec height nommé (fix syntaxe)
// ignore: unused_element
const _height = SizedBox(height: 0);
