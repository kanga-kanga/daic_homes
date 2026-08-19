import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddPropertyPage extends StatefulWidget {
  final Map<String, dynamic>? property;
  final VoidCallback? onPropertySaved;

  const AddPropertyPage({super.key, this.property, this.onPropertySaved});

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  final _supabaseService = SupabaseService();
  final _imagePicker = ImagePicker();

  final _priceController = TextEditingController();
  final _nbrPiecesController = TextEditingController();
  final _adressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _surfaceController = TextEditingController();

  String? _selectedCourant;
  String? _selectedEau;
  String? _selectedState;
  String? _selectedCategorie;
  String? _selectedVille;
  String? _selectedIsCloture;
  String? _selectedVisibility;

  final _dimensionController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _commercialZoneController = TextEditingController();

  XFile? _mainImage;
  List<XFile> _otherImages = [];
  bool _isLoading = false;
  List<Map<String, dynamic>> _owners = [];
  String? _selectedOwnerId;
  Map<String, dynamic>? _selectedOwner;

  final List<String> _courantOptions = ['Oui', 'Non'];
  final List<String> _eauOptions = ['Oui', 'Non'];
  final List<String> _stateOptions = ['A Louer', 'A Vendre'];
  final List<String> _categorieOptions = ['Maison', 'Appartement', 'Parcelle', 'Concession', 'Studio', 'Local Commercial'];
  final List<String> _clotureOptions = ['OUI', 'NON'];
  final List<String> _visibilityOptions = ['OUI', 'NON'];
  final List<String> _villeOptions = [
    'Kinshasa', 'Lubumbashi', 'Mbuji-Mayi', 'Kananga',
    'Kisangani', 'Goma', 'Bukavu', 'Kolwezi',
    'Likasi', 'Matadi', 'Autre',
  ];

  bool get _showRooms => _selectedCategorie != null && !['Parcelle', 'Local Commercial'].contains(_selectedCategorie);
  bool get _showSurface => ['Parcelle', 'Concession', 'Local Commercial'].contains(_selectedCategorie);
  bool get _showUtilities => _selectedCategorie != null && _selectedCategorie != 'Parcelle';
  bool get _showCloture => ['Parcelle', 'Concession'].contains(_selectedCategorie);
  bool get _showDimension => _selectedCategorie == 'Parcelle';
  bool get _showCommercialFields => _selectedCategorie == 'Local Commercial';

  @override
  void initState() {
    super.initState();
    _loadOwners();
    if (widget.property != null) {
      _loadPropertyData();
    }
  }

  Future<void> _loadOwners() async {
    try {
      final owners = await _supabaseService.getOwners();
      setState(() {
        _owners = owners;
        if (widget.property != null && _selectedOwnerId == null) {
          _selectedOwnerId = widget.property!['owner_id'];
          _selectedOwner = _owners.firstWhere(
            (owner) => owner['id'] == _selectedOwnerId,
            orElse: () => {},
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur propriétaires: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _loadPropertyData() {
    _priceController.text = widget.property!['price']?.toString() ?? '';
    _nbrPiecesController.text = widget.property!['nbr_pieces']?.toString() ?? '';
    _adressController.text = widget.property!['adress'] ?? '';
    _descriptionController.text = widget.property!['description'] ?? '';
    _surfaceController.text = widget.property!['surface']?.toString() ?? '';
    _selectedCategorie = widget.property!['categorie'];
    _selectedVille = widget.property!['ville'];
    _selectedOwnerId = widget.property!['owner_id'];
    _selectedCourant = widget.property!['courant']?.toString();
    _selectedEau = widget.property!['eau']?.toString();
    _selectedState = widget.property!['state']?.toString();
    _selectedIsCloture = widget.property!['is_cloture']?.toString();
    _selectedVisibility = widget.property!['visibility']?.toString();
    _dimensionController.text = widget.property!['dimension']?.toString() ?? '';
    _businessTypeController.text = widget.property!['business_type']?.toString() ?? '';
    _commercialZoneController.text = widget.property!['commercial_zone']?.toString() ?? '';
  }

  Future<void> _pickMainImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _mainImage = image);
  }

  Future<void> _pickOtherImages() async {
    final List<XFile> images = await _imagePicker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _otherImages.addAll(images));
    }
  }

  void _removeOtherImage(int index) => setState(() => _otherImages.removeAt(index));

  void _showOwnerSelectionDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choisir un propriétaire', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _owners.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final owner = _owners[index];
                  final isSelected = _selectedOwnerId == owner['id'];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? const Color(0xFF00A859) : Colors.grey[200],
                      child: Icon(Icons.person, color: isSelected ? Colors.white : Colors.grey),
                    ),
                    title: Text(owner['name'] ?? 'Inconnu', style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    subtitle: Text(owner['phone'] ?? owner['email'] ?? ''),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF00A859)) : null,
                    onTap: () {
                      setState(() {
                        _selectedOwnerId = owner['id'];
                        _selectedOwner = owner;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProperty() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedOwnerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez choisir un propriétaire')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final property = <String, dynamic>{
        'price': _priceController.text,
        'adress': _adressController.text,
        'description': _descriptionController.text,
        'categorie': _selectedCategorie,
        'state': _selectedState,
        'ville': _selectedVille,
        'owner_id': _selectedOwnerId,
      };

      // Conditional fields based on category
      property['nbr_pieces'] = _showRooms ? (int.tryParse(_nbrPiecesController.text) ?? 0) : null;
      property['surface'] = _showSurface ? _surfaceController.text : null;
      property['courant'] = _showUtilities ? _selectedCourant : null;
      property['eau'] = _showUtilities ? _selectedEau : null;
      property['is_cloture'] = _showCloture ? _selectedIsCloture : null;
      property['dimension'] = _showDimension ? _dimensionController.text : null;
      property['business_type'] = _showCommercialFields ? _businessTypeController.text : null;
      property['commercial_zone'] = _showCommercialFields ? _commercialZoneController.text : null;
      property['visibility'] = _showCommercialFields ? _selectedVisibility : null;

      if (widget.property == null) {
        await _supabaseService.addPropertyWithImages(
          property: property,
          mainImage: _mainImage,
          otherImages: _otherImages,
          ownerId: _selectedOwnerId!,
        );
      } else {
        await _supabaseService.updateProperty(widget.property!['id'], property);
      }

      if (mounted) {
        widget.onPropertySaved?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.property == null ? 'Nouvel Immobilier' : 'Modifier'),
        actions: [
          IconButton(onPressed: _isLoading ? null : _saveProperty, icon: const Icon(Icons.check)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildSectionTitle('Médias'),
                    const SizedBox(height: 16),
                    _buildImagePicker(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Propriétaire'),
                    const SizedBox(height: 16),
                    _buildOwnerSelector(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Détails'),
                    const SizedBox(height: 16),
                    _buildFormFields(),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProperty,
                      child: const Text('Enregistrer l\'immobilier'),
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: const Color(0xFF00A859), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickMainImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _mainImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: kIsWeb
                        ? Image.network(_mainImage!.path, fit: BoxFit.cover)
                        : Image.file(io.File(_mainImage!.path), fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('Image principale', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ..._otherImages.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.network(entry.value.path, width: 80, height: 80, fit: BoxFit.cover)
                              : Image.file(io.File(entry.value.path), width: 80, height: 80, fit: BoxFit.cover),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => _removeOtherImage(entry.key),
                            child: Container(color: Colors.red, child: const Icon(Icons.close, size: 14, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  )),
              GestureDetector(
                onTap: _pickOtherImages,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                  child: const Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildOwnerSelector() {
    return InkWell(
      onTap: _showOwnerSelectionDialog,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[300]!)),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _selectedOwner != null ? const Color(0xFF00A859).withOpacity(0.1) : Colors.grey[100],
              child: Icon(_selectedOwner != null ? Icons.person : Icons.person_outline, color: _selectedOwner != null ? const Color(0xFF00A859) : Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedOwner?['name'] ?? 'Sélectionner un propriétaire', style: TextStyle(fontWeight: _selectedOwner != null ? FontWeight.bold : FontWeight.normal)),
                  if (_selectedOwner != null) Text(_selectedOwner!['phone'] ?? 'Pas de numéro', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(_selectedCategorie, 'Catégorie', _categorieOptions, (v) {
          setState(() => _selectedCategorie = v);
        }),
        const SizedBox(height: 16),
        _buildTextField(_descriptionController, 'Description', maxLines: 3),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField(_priceController, 'Prix (\$)', keyboardType: TextInputType.number)),
            if (_showRooms || _showSurface) const SizedBox(width: 16),
            if (_showRooms && !_showSurface)
              Expanded(child: _buildTextField(_nbrPiecesController, 'Nombre de pièces', keyboardType: TextInputType.number)),
            if (_showSurface && !_showRooms)
              Expanded(child: _buildTextField(_surfaceController, 'Surface (m²)', keyboardType: TextInputType.number)),
          ],
        ),
        if (_showRooms && _showSurface) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(_nbrPiecesController, 'Nombre de pièces', keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_surfaceController, 'Surface (m²)', keyboardType: TextInputType.number)),
            ],
          ),
        ],
        const SizedBox(height: 16),
        _buildTextField(_adressController, 'Adresse exacte'),
        const SizedBox(height: 16),
        _buildDropdown(_selectedVille, 'Ville', _villeOptions, (v) => setState(() => _selectedVille = v)),
        
        // Dynamic Utility Fields
        if (_showUtilities || _showCloture) ...[
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text('Caractéristiques spécifiques', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 12),
          if (_showUtilities)
            Row(
              children: [
                Expanded(child: _buildDropdown(_selectedCourant, 'Électricité', _courantOptions, (v) => setState(() => _selectedCourant = v))),
                const SizedBox(width: 16),
                Expanded(child: _buildDropdown(_selectedEau, 'Eau potable', _eauOptions, (v) => setState(() => _selectedEau = v))),
              ],
            ),
          if (_showCloture) ...[
            if (_showUtilities) const SizedBox(height: 16),
            _buildDropdown(_selectedIsCloture, 'Terrain clôturé ?', _clotureOptions, (v) => setState(() => _selectedIsCloture = v)),
          ],
          
          if (_showDimension) ...[
            const SizedBox(height: 16),
            _buildTextField(_dimensionController, 'Dimensions (ex: 50/40)'),
          ],

          if (_showCommercialFields) ...[
            const SizedBox(height: 16),
            _buildTextField(_businessTypeController, 'Type d\'activité (ex: Boutique, Bureau)'),
            const SizedBox(height: 16),
            _buildTextField(_commercialZoneController, 'Zone commerciale (ex: Marché)'),
            const SizedBox(height: 16),
            _buildDropdown(_selectedVisibility, 'Bonne visibilité (Route principale) ?', _visibilityOptions, (v) => setState(() => _selectedVisibility = v)),
          ],
        ],
        
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        _buildDropdown(_selectedState, 'Statut de l\'annonce', _stateOptions, (v) => setState(() => _selectedState = v)),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, alignLabelWithHint: true),
      validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
    );
  }

  Widget _buildDropdown(String? value, String label, List<String> options, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: options.contains(value) ? value : null,
      decoration: InputDecoration(labelText: label),
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Requis' : null,
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _nbrPiecesController.dispose();
    _adressController.dispose();
    _descriptionController.dispose();
    _surfaceController.dispose();
    _dimensionController.dispose();
    _businessTypeController.dispose();
    _commercialZoneController.dispose();
    super.dispose();
  }
}
