import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' as io;
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  // Vérifier si l'utilisateur est connecté et est admin
  bool get isUserAuthenticated => _client.auth.currentUser != null;
  User? get currentUser => _client.auth.currentUser;

  // Authentification
  Future<AuthResponse> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return response;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Vérifier si l'utilisateur est admin
  Future<bool> isUserAdmin(String userId) async {
    try {
      final response = await _client
          .from('utilisateurs')
          .select('role')
          .eq('id', userId)
          .maybeSingle();
      return response != null && response['role'] == 'admin';
    } catch (e) {
      print('Erreur vérification admin: $e');
      return false;
    }
  }

  // Gestion des propriétaires avec gestion d'erreur RLS
  Future<List<Map<String, dynamic>>> getOwners() async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      final response = await _client
          .from('owners')
          .select('*')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur getOwners: $e');
      throw Exception(
        'Erreur d\'accès aux données. Vérifiez les permissions RLS.',
      );
    }
  }

  Future<Map<String, dynamic>> getOwner(String id) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      final response = await _client
          .from('owners')
          .select('*')
          .eq('id', id)
          .single();
      return response;
    } catch (e) {
      print('Erreur getOwner: $e');
      throw Exception(
        'Erreur d\'accès aux données. Vérifiez les permissions RLS.',
      );
    }
  }

  Future<void> addOwner(Map<String, dynamic> owner) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      await _client.from('owners').insert(owner);
    } catch (e) {
      print('Erreur addOwner: $e');
      throw Exception('Erreur lors de l\'ajout. Vérifiez les permissions RLS.');
    }
  }

  Future<void> updateOwner(String id, Map<String, dynamic> owner) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      await _client.from('owners').update(owner).eq('id', id);
    } catch (e) {
      print('Erreur updateOwner: $e');
      throw Exception(
        'Erreur lors de la modification. Vérifiez les permissions RLS.',
      );
    }
  }

  // Dans SupabaseService - Ajoutez ces méthodes

  // Compter les propriétés par propriétaire
  Future<Map<String, int>> getPropertiesCountByOwner() async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      final response = await _client
          .from('immobilier')
          .select('owner_id')
          .eq('is_actif', true);

      final Map<String, int> countMap = {};

      for (final property in response) {
        final ownerId = property['owner_id'];
        if (ownerId != null) {
          countMap[ownerId] = (countMap[ownerId] ?? 0) + 1;
        }
      }

      return countMap;
    } catch (e) {
      print('Erreur getPropertiesCountByOwner: $e');
      throw Exception('Erreur lors du comptage des propriétés: $e');
    }
  }

  // Récupérer les propriétés d'un propriétaire spécifique
  Future<List<Map<String, dynamic>>> getPropertiesByOwner(
    String ownerId,
  ) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      final response = await _client
          .from('immobilier')
          .select('*')
          .eq('owner_id', ownerId)
          .eq('is_actif', true)
          .order('date_publishing', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur getPropertiesByOwner: $e');
      throw Exception('Erreur lors de la récupération des propriétés: $e');
    }
  }

  // Méthode de suppression chirurgicale basée sur les URLs
  // Cette méthode est plus sûre car elle ne supprime que les fichiers listés,
  // contrairement à la suppression de dossier complet qui peut impacter d'autres biens.
  Future<void> _deleteImagesFromUrls(List<String> urls) async {
    try {
      if (urls.isEmpty) return;

      final List<String> pathsToDelete = [];
      
      for (final url in urls) {
        if (url.isEmpty) continue;
        
        // Extraire le chemin relatif de l'URL Supabase
        // Exemple d'un URL Supabase: https://[...].supabase.co/storage/v1/object/public/[bucket]/[path/to/file.jpg]
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;
        
        // On cherche le bucket 'houseimages' dans les segments
        final bucketIndex = pathSegments.indexOf('houseimages');
        if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
          // On récupère tout ce qui vient après le bucket
          final relativePath = pathSegments.sublist(bucketIndex + 1).join('/');
          pathsToDelete.add(relativePath);
        }
      }

      if (pathsToDelete.isNotEmpty) {
        print('Suppressing specific files: $pathsToDelete');
        await _client.storage.from('houseimages').remove(pathsToDelete);
      }
    } catch (e) {
      print('Error in _deleteImagesFromUrls: $e');
      // On log l'erreur mais on ne bloque pas le processus de suppression du bien
    }
  }

  // Ancienne méthode gardée pour compatibilité ou suppression totale d'un dossier (à utiliser avec prudence)
  Future<void> _deletePropertyImageFolder(String folderId) async {
    try {
      final files = await _client.storage.from('houseimages').list(path: folderId);
      if (files.isNotEmpty) {
        final fileNames = files.map((file) => '$folderId/${file.name}').toList();
        await _client.storage.from('houseimages').remove(fileNames);
      }
    } catch (e) {
      print('Error deleting folder $folderId: $e');
    }
  }

  Future<void> deleteOwner(String id) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      await _client.from('owners').delete().eq('id', id);
    } catch (e) {
      print('Erreur deleteOwner: $e');
      throw Exception(
        'Erreur lors de la suppression. Vérifiez les permissions RLS.',
      );
    }
  }

  // Gestion des immobiliers avec gestion d'erreur RLS
  Future<List<Map<String, dynamic>>> getProperties() async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      final response = await _client
          .from('immobilier')
          .select('*, owners(name, email, phone)')
          .order('date_publishing', ascending: false);

      print('Properties loaded: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur getProperties: $e');
      throw Exception('Erreur d\'accès aux données: $e');
    }
  }

  // Récupérer les informations détaillées d'un propriétaire
  Future<Map<String, dynamic>> getOwnerDetails(String ownerId) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      final response = await _client
          .from('owners')
          .select('*')
          .eq('id', ownerId)
          .single();

      return response;
    } catch (e) {
      print('Erreur getOwnerDetails: $e');
      throw Exception('Erreur lors de la récupération du propriétaire: $e');
    }
  }

  Future<Map<String, dynamic>> getProperty(String id) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      final response = await _client
          .from('immobilier')
          .select('*, utilisateurs(nom, prenom)')
          .eq('id', id)
          .single();
      return response;
    } catch (e) {
      print('Erreur getProperty: $e');
      throw Exception(
        'Erreur d\'accès aux données. Vérifiez les permissions RLS.',
      );
    }
  }

  // Générer un ID unique pour l'immobilier
  String generateUniqueId(String bailleurId) {
    final Random random = Random();
    final int randomNumber = random.nextInt(9000) + 1000;
    return '$bailleurId-$randomNumber';
  }

  // Upload d'images vers Supabase Storage avec authentification
  Future<String> uploadImage(XFile image, String bucketPath) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        await _client.storage.from(bucketPath).uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
        );
      } else {
        await _client.storage.from(bucketPath).upload(
          fileName,
          io.File(image.path),
          fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
        );
      }

      if (true) { // Success check, simplified because uploadBinary returns string path or throws
        final publicUrl = _client.storage
            .from(bucketPath)
            .getPublicUrl(fileName);
        return publicUrl;
      } else {
        throw Exception('Failed to upload image: Response is empty.');
      }
    } catch (e) {
      print('Erreur uploadImage: $e');
      throw Exception(
        'Erreur lors de l\'upload de l\'image. Vérifiez les permissions du storage.',
      );
    }
  }

  // Ajouter un immobilier avec upload d'images
  Future<void> addPropertyWithImages({
    required Map<String, dynamic> property,
    required XFile? mainImage,
    required List<XFile> otherImages,
    required String ownerId,
  }) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      // 1. Générer l'ID de la propriété dès le début (Dossier Unique)
      final String propertyId = generateUniqueId(ownerId);
      final String storagePath = 'houseimages/$propertyId/';

      String mainImageUrl = '';
      List<String> otherImageUrls = [];

      // 2. Upload image principale vers son dossier spécifique
      if (mainImage != null) {
        mainImageUrl = await uploadImage(mainImage, storagePath);
      }

      // 3. Upload autres images vers le même dossier spécifique
      for (final image in otherImages) {
        final url = await uploadImage(image, storagePath);
        otherImageUrls.add(url);
      }

      // 4. Préparer les données finales
      final propertyData = {
        ...property,
        'link_home_images': mainImageUrl,
        'other_images': otherImageUrls,
        'id': propertyId,
        'date_publishing': DateTime.now().toIso8601String(),
        'owner_id': ownerId,
        'is_actif': true,
      };

      await _client.from('immobilier').insert(propertyData);
    } catch (e) {
      print('Erreur addPropertyWithImages: $e');
      throw Exception(
        'Erreur lors de l\'ajout de l\'immobilier. Vérifiez les permissions RLS.',
      );
    }
  }

  Future<void> updateProperty(String id, Map<String, dynamic> property) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      await _client.from('immobilier').update(property).eq('id', id);
    } catch (e) {
      print('Erreur updateProperty: $e');
      throw Exception('Erreur lors de la modification: $e');
    }
  }

  // Dans SupabaseService
  Future<void> updatePropertyImages({
    required String propertyId,
    required XFile? mainImage,
    required List<XFile> otherImages,
    required String ownerId,
  }) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      String? mainImageUrl;
      List<String> otherImageUrls = [];

      // Upload nouvelle image principale vers le dossier de la propriété
      final storagePath = 'houseimages/$propertyId/';
      
      if (mainImage != null) {
        mainImageUrl = await uploadImage(mainImage, storagePath);
      }

      // Upload nouvelles autres images
      for (final image in otherImages) {
        final url = await uploadImage(image, storagePath);
        otherImageUrls.add(url);
      }

      // Préparer les données de mise à jour
      final updateData = <String, dynamic>{};
      if (mainImageUrl != null) {
        updateData['link_home_images'] = mainImageUrl;
      }
      if (otherImageUrls.isNotEmpty) {
        // Si vous voulez remplacer toutes les images, utilisez ceci :
        // updateData['other_images'] = otherImageUrls;

        // Si vous voulez ajouter aux images existantes, vous devrez d'abord récupérer les images existantes
        final currentProperty = await _client
            .from('immobilier')
            .select('other_images')
            .eq('id', propertyId)
            .single();

        final currentImages = List<String>.from(
          currentProperty['other_images'] ?? [],
        );
        currentImages.addAll(otherImageUrls);
        updateData['other_images'] = currentImages;
      }

      if (updateData.isNotEmpty) {
        await _client
            .from('immobilier')
            .update(updateData)
            .eq('id', propertyId);
      }
    } catch (e) {
      print('Erreur updatePropertyImages: $e');
      throw Exception('Erreur lors de la mise à jour des images: $e');
    }
  }

  Future<void> deletePropertyWithImages(String propertyId) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      print('Starting deletion of property: $propertyId');

      // 1. Récupérer la propriété
      final property = await _client
          .from('immobilier')
          .select('link_home_images, other_images, owner_id')
          .eq('id', propertyId)
          .single();

      // 2. Suppression chirurgicale par URL (Sécurisé pour les anciens et nouveaux biens)
      final List<String> imageUrls = [
          if (property['link_home_images'] != null && property['link_home_images'].isNotEmpty) 
            property['link_home_images'],
          ...List<String>.from(property['other_images'] ?? []),
      ];

      print('Deleting ${imageUrls.length} image files related to property $propertyId');
      await _deleteImagesFromUrls(imageUrls);

      // Si c'est un nouveau bien, on tente aussi de nettoyer son dossier spécifique
      try {
        await _deletePropertyImageFolder(propertyId);
      } catch (e) {
        // Ignorer si le dossier n'existe pas (cas des anciens biens)
      }

      // 3. Supprimer les favoris associés à cet immobilier
      // Cela évite l'erreur de contrainte de clé étrangère si des utilisateurs l'ont mis en favori
      await _client.from('favoris').delete().eq('immobilier_id', propertyId);

      // 4. Supprimer la propriété de la base de données
      await _client.from('immobilier').delete().eq('id', propertyId);

      print('Property and all images deleted successfully: $propertyId');
    } on PostgrestException catch (e) {
      print('Postgrest error during deletion: ${e.message}');
      throw Exception('Erreur de base de données: ${e.message}');
    } catch (e) {
      print('Error in deletePropertyWithImages: $e');
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  // Dans SupabaseService - Correction de la méthode _deleteImageFromStorage

  // Gestion des utilisateurs avec gestion d'erreur RLS
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      final response = await _client
          .from('utilisateurs')
          .select('*')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur getUsers: $e');
      throw Exception(
        'Erreur d\'accès aux données utilisateurs. Vérifiez les permissions RLS.',
      );
    }
  }

  Future<Map<String, dynamic>> getUser(String id) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      final response = await _client
          .from('utilisateurs')
          .select('*')
          .eq('id', id)
          .single();
      return response;
    } catch (e) {
      print('Erreur getUser: $e');
      throw Exception(
        'Erreur d\'accès aux données. Vérifiez les permissions RLS.',
      );
    }
  }

  // Mettre à jour un utilisateur
  Future<void> updateUser(String id, Map<String, dynamic> user) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      await _client.from('utilisateurs').update(user).eq('id', id);
    } catch (e) {
      print('Erreur updateUser: $e');
      throw Exception('Erreur lors de la modification: $e');
    }
  }

  // Supprimer un utilisateur avec authentification
  Future<void> deleteUserWithAuth(String userId) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      // 1. Supprimer l'utilisateur de la table utilisateurs
      await _client.from('utilisateurs').delete().eq('id', userId);

      // 2. Supprimer l'utilisateur de Supabase Auth (nécessite l'admin API)
      // Note: Cette opération nécessite généralement des privilèges admin
      // Vous devrez peut-être utiliser l'API admin ou une fonction edge
      print('Utilisateur supprimé de la base de données: $userId');

      // Pour supprimer de l'auth, vous aurez besoin d'implémenter une fonction edge
      // ou d'utiliser l'API admin avec une clé de service
    } catch (e) {
      print('Erreur deleteUserWithAuth: $e');
      throw Exception('Erreur lors de la suppression de l\'utilisateur: $e');
    }
  }

  // Créer un utilisateur avec authentification
  Future<void> createUserWithAuth({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
  }) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      // 1. Créer l'utilisateur dans Supabase Auth
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception(
          'Erreur lors de la création de l\'utilisateur dans l\'authentification',
        );
      }

      final userId = authResponse.user!.id;

      // 2. Créer l'utilisateur dans la table utilisateurs
      final userData = {
        'id': userId,
        'email': email,
        'nom': nom,
        'prenom': prenom,
        'mot_de_passe_hash': password,
        'telephone': telephone,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client.from('utilisateurs').insert(userData);

      print('Utilisateur créé avec succès: $email');
    } on AuthException catch (e) {
      print('Erreur d\'authentification: ${e.message}');
      throw Exception('Erreur d\'authentification: ${e.message}');
    } catch (e) {
      print('Erreur createUserWithAuth: $e');
      throw Exception('Erreur lors de la création de l\'utilisateur: $e');
    }
  }
  // --- Statistiques pour le Dashboard ---

  Future<int> getPropertiesCount() async {
    try {
      final response = await _client
          .from('immobilier')
          .select('id');
      return response.length;
    } catch (e) {
      print('Erreur getPropertiesCount: $e');
      return 0;
    }
  }

  Future<int> getUsersCount() async {
    try {
      final response = await _client
          .from('utilisateurs')
          .select('id');
      return response.length;
    } catch (e) {
      print('Erreur getUsersCount: $e');
      return 0;
    }
  }

  Future<int> getOwnersCount() async {
    try {
      final response = await _client
          .from('owners')
          .select('id');
      return response.length;
    } catch (e) {
      print('Erreur getOwnersCount: $e');
      return 0;
    }
  }

  Future<double> getTotalRevenue() async {
    try {
      final response = await _client
          .from('immobilier')
          .select('price')
          .eq('state', 'A Vendre');
      
      double total = 0;
      for (var item in response) {
        final priceStr = item['price']?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '0';
        total += double.tryParse(priceStr) ?? 0;
      }
      return total;
    } catch (e) {
      print('Erreur getTotalRevenue: $e');
      return 0;
    }
  }
}
