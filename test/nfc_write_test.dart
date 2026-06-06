import 'package:flutter_test/flutter_test.dart';
import 'package:ict218_nfc_app/models/user_model.dart';

/// Tests unitaires pour le module NFC d'écriture (Étudiant 3)
void main() {
  group('UserModel - Sérialisation JSON', () {
    late UserModel testUser;

    setUp(() {
      testUser = UserModel(
        id: '123e4567-e89b-12d3-a456-426614174000',
        nom: 'DUPONT',
        prenom: 'Jean',
        role: 'etudiant',
        acces: true,
        dateEnrolement: '2025-01-15T10:30:00.000Z',
      );
    });

    test('toJson() produit un JSON valide', () {
      final json = testUser.toJson();
      expect(json, isA<String>());
      expect(json, contains('"nom":"DUPONT"'));
      expect(json, contains('"prenom":"Jean"'));
      expect(json, contains('"role":"etudiant"'));
      expect(json, contains('"acces":true'));
    });

    test('fromJson() reconstruit correctement le modèle', () {
      final json = testUser.toJson();
      final reconstructed = UserModel.fromJson(json);

      expect(reconstructed.id, equals(testUser.id));
      expect(reconstructed.nom, equals(testUser.nom));
      expect(reconstructed.prenom, equals(testUser.prenom));
      expect(reconstructed.role, equals(testUser.role));
      expect(reconstructed.acces, equals(testUser.acces));
      expect(reconstructed.dateEnrolement, equals(testUser.dateEnrolement));
    });

    test('toJson() → fromJson() est idempotent (aller-retour)', () {
      final json1 = testUser.toJson();
      final user2 = UserModel.fromJson(json1);
      final json2 = user2.toJson();
      expect(json1, equals(json2));
    });

    test('fromJson() gère les champs manquants avec des valeurs par défaut', () {
      const incompleteJson = '{"nom": "TEST"}';
      final user = UserModel.fromJson(incompleteJson);
      expect(user.nom, equals('TEST'));
      expect(user.prenom, equals(''));
      expect(user.acces, equals(false));
    });

    test('toMap() contient tous les champs attendus', () {
      final map = testUser.toMap();
      expect(map.keys, containsAll(['id', 'nom', 'prenom', 'role', 'acces', 'dateEnrolement']));
    });
  });
}
