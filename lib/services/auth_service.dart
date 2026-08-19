// import 'dart:io';

import 'package:daic_home/main.dart';
import 'package:daic_home/models/house.dart';
import 'package:daic_home/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' as io;

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Vérifier si un utilisateur est connecté
  // bool get isAuthenticated => _supabase.auth.currentUser != null;
  Future<bool> isAuthenticated() async {
    final user = _supabase.auth.currentUser;
    return user != null;
  }

  // String? get userId => _supabase.auth.currentUser?.id;
  // String? get userEmail => _supabase.auth.currentUser?.email;

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient client = Supabase.instance.client;

  Future<void> init() async {
    await Supabase.initialize(
      url: "https://relufzgkhkwsciqjnhdk.supabase.co",
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJlbHVmemdraGt3c2NpcWpuaGRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM4NDAyNDEsImV4cCI6MjA1OTQxNjI0MX0.G9Ey7tPUMEYrC4Jo0wnJsXaqgqX1gJ8uvaHQGCMkrBM',
    );
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required int telephone,
    required BuildContext context,
  }) async {
    try {
      // 1. Créer le compte d'authentification
      final AuthResponse res = await AuthService().client.auth.signUp(
        email: email,
        password: password,
        // emailRedirectTo: alse
      );
      // 2. Si l'inscription est réussie, ajouter les infos dans la table utilisateurs

      await AuthService().client
          .from('utilisateurs')
          .insert({
            'id':
                res
                    .user!
                    .id, // AuthService().client.auth.currentUser!.id, //res.user!.id,
            'email': email,
            'nom': nom,
            'prenom': prenom,
            'telephone': telephone,
            'mot_de_passe_hash': password,
            'created_at': DateTime.now().toIso8601String(),
          })
          .timeout(Duration(seconds: 10));

      //
      final _prefs = await SharedPreferences.getInstance();

      await _prefs.setBool('isAuthenticated', true);
      await _prefs.setString('userId', res.user!.id);
      await _prefs.setString('userEmail', email);

      // Navigator.pushReplacementNamed(context, '/main');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
        (Route<dynamic> route) =>
            false, // Supprime toutes les routes précédentes
      );

      return "OK"; //null; // Aucune erreur
      // }
      // print(res.user);
      // return 'Erreur lors de la création du compte';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Une erreur inattendue est survenue $e';
    }
  }

  Future<String?> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // 1. Authentifier l'utilisateur avec email et mot de passe
      final AuthResponse res = await AuthService().client.auth
          .signInWithPassword(email: email, password: password);

      // 2. Vérifier si l'utilisateur est authentifié
      if (res.user != null) {
        // Stocker les informations de session dans SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('userId', res.user!.id);
        await prefs.setString('userEmail', email);

        // Rediriger vers la page d'accueil
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
          (Route<dynamic> route) =>
              false, // Supprime toutes les routes précédentes
        );

        return "OK"; // Connexion réussie
      } else {
        return "Aucun"; // "Erreur : utilisateur non trouvé.";
      }
    } on AuthException catch (e) {
      return e.message; // Retourner le message d'erreur
    } catch (e) {
      print("Erreur au niveau du login : $e");
      return 'Une erreur inattendue est survenue.';
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = AuthService().client.auth.currentUser;
    if (user == null) return null;

    final response =
        await AuthService().client
            .from('utilisateurs')
            .select()
            .eq('id', user.id)
            .single();

    return response;
  }

  // Recuperer toutes les maisons
  Future<List<House>> fetchHouses() async {
    try {
      // Récupérer les données depuis la table "houses"
      final response = await _supabase
          .from('immobilier')
          .select("*")
          .eq('is_actif', true)
          .order('date_publishing', ascending: false);
      ;

      return response
          .map((json) {
            try {
              return House.fromJson(json);
            } catch (e) {
              return null; // Ignorer les données invalides
            }
          })
          .where((house) => house != null)
          .cast<House>()
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erreur Supabase: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  // Effectuer une recherche de maisons
  Future<List<House>> searchProperties({
    String? category,
    double? minPrice,
    double? maxPrice,
    int? nbrRooms,
    String? location,
    String? state, // e.g., 'location' or 'vente'
    double? minSurface, // Nouveau paramètre
  }) async {
    try {
      // Validation des prix
      if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
        throw Exception(
          'Le prix minimum ne peut pas être supérieur au prix maximum',
        );
      }
      // Création de la requête de base
      var query = _supabase.from('immobilier').select('*').eq('is_actif', true);
      // Application des filtres
      if (category != null && category.isNotEmpty && category != "Toutes") {
        if (category == "Parcelle") {
          // Gère à la fois le singulier et le pluriel pour les parcelles
          query = query.or('categorie.eq.Parcelle,categorie.eq.Parcelles');
        } else {
          query = query.eq('categorie', category);
        }
      }

      if (state != null && state.isNotEmpty) {
        query = query.eq('state', state);
      }

      if (minPrice != null) {
        query = query.gte('price', minPrice.toInt());
      }

      if (maxPrice != null) {
        query = query.lte('price', maxPrice.toInt());
      }
      if (nbrRooms != null) {
        query = query.gte('nbr_pieces', nbrRooms);
      }

      if (minSurface != null) {
        query = query.gte('surface', minSurface.toInt());
      }

      if (location != null && location.isNotEmpty) {
        // Search in both ville and adress columns
        query = query.or('ville.ilike.%$location%,adress.ilike.%$location%');
      }
      // Exécution de la requête
      final response = await query.order('price', ascending: true);

      return response.map((json) => House.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Erreur Supabase: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  // ----------------------- Section favoris -----------------------
  Future<void> addFavorite(String immobilierId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    await _supabase.from('favoris').insert({
      'user_id': user.id,
      'immobilier_id': immobilierId,
    });
  }

  Future<void> removeFavorite(String immobilierId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    await _supabase
        .from('favoris')
        .delete()
        .eq('user_id', user.id)
        .eq('immobilier_id', immobilierId);
  }

  Future<List<House>> getFavorites() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    final response = await _supabase
        .from('favoris')
        .select('immobilier(*)')
        .eq('user_id', user.id);

    return response.map((json) => House.fromJson(json['immobilier'])).toList();
  }

  // Vérifier si une maison est dans les favoris
  Future<bool> isFavorite(String immobilierId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    final response = await _supabase
        .from('favoris')
        .select()
        .eq('user_id', user.id)
        .eq('immobilier_id', immobilierId);
    // .execute();

    if (response.isEmpty) {
      throw Exception(
        // "Erreur lors de la vérification des favoris : aucune donnée trouvée.",
        "No data",
      );
    }

    return response.isNotEmpty;
  }

  Future<String> uploadProfileImage(XFile imageFile) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    try {
      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '${user.id}/$fileName';

      // Vérifier si le dossier utilisateur existe et supprimer les anciennes images
      await _deleteOldProfileImages(user.id);

      // Uploader la nouvelle image
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        await _supabase.storage.from('photo_de_profil').uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );
      } else {
        await _supabase.storage.from('photo_de_profil').upload(
          filePath,
          io.File(imageFile.path),
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );
      }

      // Récupérer l'URL publique
      final String publicUrl = _supabase.storage
          .from('photo_de_profil')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception("Erreur lors de l'upload de l'image: $e");
    }
  }

  // Méthode pour supprimer les anciennes images de profil
  Future<void> _deleteOldProfileImages(String userId) async {
    try {
      // Lister tous les fichiers dans le dossier de l'utilisateur
      final List<FileObject> files = await _supabase.storage
          .from('photo_de_profil')
          .list(path: userId);

      // Supprimer tous les fichiers existants
      for (final file in files) {
        if (file.name != '.emptyFolderPlaceholder') {
          await _supabase.storage.from('photo_de_profil').remove([
            '$userId/${file.name}',
          ]);
        }
      }
    } catch (e) {
      // Si le dossier n'existe pas, on continue sans erreur
      if (e is StorageException && e.message != 'The resource was not found') {
        throw Exception(
          "Erreur lors de la suppression des anciennes images: $e",
        );
      }
    }
  }

  // Méthode pour mettre à jour le profil avec l'image
  Future<void> updateUserProfile({
    required String email,
    required String nom,
    required String prenom,
    required int telephone,
    XFile? profileImage, // Nouveau paramètre pour l'image
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    try {
      String? avatarUrl;

      // Uploader l'image si elle est fournie
      if (profileImage != null) {
        avatarUrl = await uploadProfileImage(profileImage);
      }

      // Étape 1 : Mettre à jour l'authentification (email)
      if (email != user.email) {
        await _supabase.auth.updateUser(UserAttributes(email: email));
      }

      // Étape 2 : Mettre à jour les informations dans la table `utilisateurs`
      final updateData = {
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'email': email,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Ajouter l'URL de l'avatar si elle existe
      if (avatarUrl != null) {
        updateData['avatar_url'] = avatarUrl;
      }

      await _supabase.from('utilisateurs').update(updateData).eq('id', user.id);

      print("Mise à jour réussie !");
    } on AuthException catch (e) {
      throw Exception("Erreur d'authentification : ${e.message}");
    } catch (e) {
      throw Exception("Erreur inattendue : $e");
    }
  }

  // Dans AuthService.dart
  Future<String?> getUserAvatarUrl() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final userDetails =
          await _supabase
              .from('utilisateurs')
              .select('avatar_url')
              .eq('id', user.id)
              .single();

      return userDetails['avatar_url'];
    } catch (e) {
      print('Erreur lors de la récupération de l\'avatar: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserDetails() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    try {
      // Récupérer les informations de l'utilisateur depuis la table `utilisateurs`
      print("User id : ${user.id}");
      final response =
          await _supabase
              .from('utilisateurs')
              .select('nom, prenom, email, telephone, avatar_url, role') // Added role
              .eq('id', user.id)
              .single();
      print("Response : $response");
      return {
        'nom': response['nom'] ?? 'Nom inconnu',
        'prenom': response['prenom'] ?? 'Prénom inconnu',
        'email': response['email'] ?? 'Email inconnu',
        'telephone': response['telephone'] ?? 'Téléphone inconnu',
        'avatar_url': response['avatar_url'],
        'role': response['role'] ?? 'user', // Default to 'user'
      };
    } catch (e) {
      print("Erreur lors de la récupération des détails de l'utilisateur : $e");
      throw Exception(
        "Impossible de récupérer les informations de l'utilisateur.",
      );
    }
  }

  Future<String?> getUserFirstName() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    try {
      // Récupérer les informations de l'utilisateur depuis la table `utilisateurs`
      final response =
          await _supabase
              .from('utilisateurs')
              .select('prenom')
              .eq('id', user.id)
              .single();

      // Retourner le prénom
      return response['prenom'] ?? 'Prénom inconnu';
    } catch (e) {
      throw Exception("Connexion internet instable ou indisponible.");
    }
  }

  Future<void> signOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _supabase.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }
}
