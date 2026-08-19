import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:daic_home/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  XFile? _profileImage;
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
      if (kIsWeb) {
        return NetworkImage(_profileImage!.path);
      }
      return FileImage(io.File(_profileImage!.path));
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
    if (kIsWeb) return true; // Sur Web, les permissions sont gérées par le navigateur
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
    if (!kIsWeb && io.Platform.isIOS) {
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
        if (kIsWeb) {
          setState(() {
            _profileImage = image;
          });
        } else {
          await _cropImage(image);
        }
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
        if (kIsWeb) {
          setState(() {
            _profileImage = image;
          });
        } else {
          await _cropImage(image);
        }
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
  Future<void> _cropImage(XFile imageFile) async {
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
          _profileImage = XFile(croppedFile.path);
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

      // Mettre à jour le profil avec l'image si elle existe
      await AuthService().updateUserProfile(
        email: _emailController.text.trim(),
        nom: _nameController.text.trim(),
        prenom: _firstnameController.text.trim(),
        telephone: int.parse(_phoneController.text.trim()),
        profileImage: _profileImage,
      );

      MotionToast.success(
        title: const Text('Succès'),
        description: Text("Profil mis à jour avec succès !"),
        animationType: AnimationType.slideInFromBottom,
      ).show(context);

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Mon Profil",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar Section
              Center(
                child: GestureDetector(
                  onTap: _isUploading ? null : _showImagePickerMenu,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          image: DecorationImage(
                            image: _getProfileImage(),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                      if (_isUploading)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ).animate().scale(duration: 400.ms),
              
              const SizedBox(height: 12),
              Text(
                'Cliquez pour changer la photo',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              
              const SizedBox(height: 40),
              
              _buildModernTextField(
                controller: _nameController,
                label: "Nom",
                icon: Icons.person_outline_rounded,
                validator: (v) => v!.isEmpty ? "Veuillez entrer votre nom" : null,
              ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),
              
              const SizedBox(height: 20),
              
              _buildModernTextField(
                controller: _firstnameController,
                label: "Prénom",
                icon: Icons.person_outline_rounded,
                validator: (v) => v!.isEmpty ? "Veuillez entrer votre prénom" : null,
              ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
              
              const SizedBox(height: 20),
              
              _buildModernTextField(
                controller: _emailController,
                label: "Email",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v!.isEmpty) return "Veuillez entrer votre email";
                  if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(v)) {
                    return "Email invalide";
                  }
                  return null;
                },
              ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
              
              const SizedBox(height: 20),
              
              _buildModernTextField(
                controller: _phoneController,
                label: "Téléphone",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v!.isEmpty) return "Veuillez entrer votre numéro";
                  if (!RegExp(r"^\d{10,15}$").hasMatch(v)) return "Numéro invalide";
                  return null;
                },
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
              
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          "Enregistrer les modifications",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[800]),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
