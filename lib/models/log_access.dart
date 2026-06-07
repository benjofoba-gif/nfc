import 'dart:convert';

class LogAccess {
  final String badgeId;
  final String nom;
  final String statut;
  final DateTime dateScan;

  LogAccess({
    required this.badgeId,
    required this.nom,
    required this.statut,
    required this.dateScan,
  });

  Map<String, dynamic> toJson() {
    return {
      'badgeId': badgeId,
      'nom': nom,
      'statut': statut,
      'dateScan': dateScan.toIso8601String(),
    };
  }

  factory LogAccess.fromJson(Map<String, dynamic> json) {
    return LogAccess(
      badgeId: json['badgeId'] as String,
      nom: json['nom'] as String,
      statut: json['statut'] as String,
      dateScan: DateTime.parse(json['dateScan'] as String),
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}
