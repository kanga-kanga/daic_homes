import 'dart:io';
import 'package:daic_home/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:motion_toast/motion_toast.dart';

class EditprofilPage extends StatefulWidget {
  const EditprofilPage({super.key});

  @override
  State<EditprofilPage> createState() => _EditprofilPageState();
}

class _EditprofilPageState extends State<EditprofilPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  String? _oldProfileImagePath;
  bool _isUploading = false; // ← AJOUTEZ CETTE VARIABLE

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      final userDetails = await AuthService().getCurrentUserDetails();
      setState(() {
        _nameController.text = userDetails?['nom'] ?? '';
        _firstnameController.text = userDetails?['prenom'] ?? '';
        _emailController.text = userDetails?['email'] ?? '';
        _phoneController.text = userDetails?['telephone']?.toString() ?? '';
        _oldProfileImagePath = userDetails?['avatar_url'];

        // Debug pour vérifier l'URL de l'avatar
        print('Avatar URL: $_oldProfileImagePath');
      });
    } catch (e) {
      MotionToast.error(
        title: const Text('Erreur de connexion'),
        description: Text("Impossible de charger les informations"),
        animationType: AnimationType.slideInFromBottom,
      ).show(context);
    }
  }

  // Méthode pour déterminer quelle image afficher
  ImageProvider _getProfileImage() {
    // 1. Si une nouvelle image a été sélectionnée
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    }

    // 2. Si l'utilisateur a déjà une image de profil en ligne
    if (_oldProfileImagePath != null && _oldProfileImagePath!.isNotEmpty) {
      // Vérifier si c'est une URL valide (commence par http)
      if (_oldProfileImagePath!.startsWith('http')) {
        return NetworkImage(_oldProfileImagePath!);
      }
      // Si c'est un chemin local (peu probable mais au cas où)
      return AssetImage(_oldProfileImagePath!);
    }

    // 3. Image par défaut depuis les assets
    return const AssetImage("assets/images/profil.png");
  }

  // Méthode pour demander les permissions
  // Méthode pour demander les permissions avec gestion des refus
  Future<bool> _requestPermissions() async {
    // Demander la permission caméra
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      cameraStatus = await Permission.camera.request();
    }

    // Demander la permission galerie (storage sur Android, photos sur iOS)
    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      storageStatus = await Permission.storage.request();
    }

    // Sur iOS, on peut aussi demander photos
    if (Platform.isIOS) {
      var photosStatus = await Permission.photos.status;
      if (!photosStatus.isGranted) {
        photosStatus = await Permission.photos.request();
      }
      return cameraStatus.isGranted &&
          (storageStatus.isGranted || photosStatus.isGranted);
    }

    return cameraStatus.isGranted && storageStatus.isGranted;
  }

  // Méthode pour gérer les permissions refusées
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permissions requises'),
          content: Text(
            'Pour sélectionner ou prendre une photo, vous devez accorder '
            'les permissions d\'accès à la caméra et au stockage. '
            'Souhaitez-vous ouvrir les paramètres pour accorder ces permissions ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); // Ouvre les paramètres de l'application
              },
              child: Text('Paramètres'),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour sélectionner une image depuis la galerie
  Future<void> _pickImageFromGallery() async {
    final hasPermission = await _requestPermissions();
    if (!hasPermission) {
      _showPermissionDeniedDialog();
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        await _cropImage(File(image.path));
      }
    } catch (e) {
      MotionToast.error(
        title: const Text('Erreur lors de la sélection'),
        description: Text("$e"),
        animationType: AnimationType.slideInFromBottom,
      ).show(context);
    }
  }

  // Méthode pour prendre une photo avec la caméra
  Future<void> _takePhotoWithCamera() async {
    final hasPermission = await _requestPermissions();
    if (!hasPermission) {
      _showPermissionDeniedDialog();
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        await _cropImage(File(image.path));
      }
    } catch (e) {
      MotionToast.error(
        title: const Text('Erreur lors de la prise de photo'),
        description: Text("$e"),
        animationType: AnimationType.slideInFromBottom,
      ).show(context);
    }
  }

  // Méthode pour recadrer l'image
  // Méthode pour recadrer l'image avec gestion d'erreurs
  Future<void> _cropImage(File imageFile) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 85,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recadrer l\'image',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Recadrer l\'image',
            aspectRatioLockEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _profileImage = File(croppedFile.path);
        });
      }
    } catch (e, stackTrace) {
      print('Erreur lors du recadrage: $e');
      print('Stack trace: $stackTrace');

      // En cas d'erreur, utiliser l'image originale sans recadrage
      setState(() {
        _profileImage = imageFile;
      });

      MotionToast.info(
        title: const Text('Erreur de recadrage'),
        description: Text("Utilisation de l'image originale"),
        animationType: AnimationType.slideInFromBottom,
      ).show(context);
    }
  }

  // Méthode pour afficher le menu de sélection d'image
  void _showImagePickerMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choisir depuis la galerie'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Prendre une photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhotoWithCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      MotionToast.info(
        title: const Text('Connexion en cours'),
        description: Text("Mise à jour des informations..."),
        animationType: AnimationType.slideInFromBottom,
      ).show(context);

      // Utiliser la nouvelle méthode avec l'image
      await AuthService().updateUserProfile(
        email: _emailController.text.trim(),
        nom: _nameController.text.trim(),
        prenom: _firstnameController.text.trim(),
        telephone: int.parse(_phoneController.text.trim()),
        profileImage: _profileImage, // Passer l'image sélectionnée
      );

      MotionToast.success(
        title: const Text('Succes '),
        description: Text("Profil mis à jour avec succès !"),
        animationType: AnimationType.slideInFromBottom,
      ).show(context);

      await AuthService().updateUserProfile(
        email: _emailController.text.trim(),
        nom: _nameController.text.trim(),
        prenom: _firstnameController.text.trim(),
        telephone: int.parse(_phoneController.text.trim()),
      );

      MotionToast.success(
        title: const Text('Succes '),
        description: Text("Profil mis à jour avec succès !"),
        animationType: AnimationType.slideInFromBottom,
      ).show(context);

      // Navigator.of(context).pop();
      Navigator.of(context).pop(); // Fermer le dialog de progression
      Navigator.of(context).pop(); // Retourner à la page précédente
    } catch (e) {
      Navigator.of(context).pop();
      MotionToast.error(
        title: const Text('Erreur de mis a jour'),
        description: Text("Connexion internet instable ou indisponible"),
        animationType: AnimationType.slideInFromBottom,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar interactif avec GestureDetector
                // Avatar interactif
                // Avatar interactif
                // GestureDetector(
                //   onTap: _isUploading ? null : _showImagePickerMenu,
                //   child: Stack(
                //     children: [
                //       CircleAvatar(
                //         radius: 50,
                //         backgroundImage: _getProfileImage(), // ← Utilisez cette méthode
                //         child: _isUploading
                //             ? const CircularProgressIndicator(
                //                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                //               )
                //             : null,
                //       ),
                //       if (!_isUploading)
                //         Container(
                //           decoration: BoxDecoration(
                //             color: Colors.black.withOpacity(0.4),
                //             shape: BoxShape.circle,
                //           ),
                //           child: const Icon(
                //             Icons.camera_alt,
                //             size: 30,
                //             color: Colors.white70,
                //           ),
                //         ),
                //     ],
                //   ),
                // ),

                // Alternative avec FadeInImage pour un meilleur affichage
                GestureDetector(
                  onTap: _isUploading ? null : _showImagePickerMenu,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: _getProfileImage(),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (!_isUploading)
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 30,
                            color: Colors.white70,
                          ),
                        ),
                      if (_isUploading)
                        const Positioned.fill(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                Text(
                  'Cliquez pour changer la photo',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Modifier vos informations",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Reste du formulaire inchangé...
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Nom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer votre nom";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _firstnameController,
                  decoration: InputDecoration(
                    labelText: "Prenom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer votre nom";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer votre email";
                    }
                    if (!RegExp(
                      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                    ).hasMatch(value)) {
                      return "Veuillez entrer un email valide";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: "Numéro de téléphone",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer votre numéro de téléphone";
                    }
                    if (!RegExp(r"^\d{10,15}$").hasMatch(value)) {
                      return "Veuillez entrer un numéro valide";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _isUploading
                            ? null
                            : saveProfile, // ← Désactiver pendant l'upload
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.inversePrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child:
                        _isUploading
                            ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                            : const Text(
                              "Enregistrer",
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
