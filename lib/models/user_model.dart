import 'dart:convert';

/// Modèle représentant un utilisateur enregistré sur un badge NFC
class UserModel {
  final String id;
  final String nom;
  final String prenom;
  final String role; // ex: "admin", "etudiant", "employe"
  final bool acces; // true = accès autorisé
  final String dateEnrolement;

  UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.role,
    required this.acces,
    required this.dateEnrolement,
  });

  /// Convertit le modèle en Map pour sérialisation JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'role': role,
      'acces': acces,
      'dateEnrolement': dateEnrolement,
    };
  }

  /// Crée un UserModel à partir d'un Map JSON
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      role: map['role'] ?? '',
      acces: map['acces'] ?? false,
      dateEnrolement: map['dateEnrolement'] ?? '',
    );
  }

  /// Sérialise en JSON string
  String toJson() => jsonEncode(toMap());

  /// Désérialise depuis JSON string
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(jsonDecode(source));

  @override
  String toString() {
    return 'UserModel(id: $id, nom: $nom, prenom: $prenom, role: $role, acces: $acces)';
  }
}
