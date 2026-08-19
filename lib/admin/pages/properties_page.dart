import 'add_property_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/supabase_service.dart';

class PropertiesPage extends StatefulWidget {
  const PropertiesPage({super.key});

  @override
  State<PropertiesPage> createState() => _PropertiesPageState();
}

class _PropertiesPageState extends State<PropertiesPage> {
  final _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _properties = [];
  List<Map<String, dynamic>> _filteredProperties = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterStatus = 'Tous';
  String _filterCategory = 'Toutes';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    try {
      final properties = await _supabaseService.getProperties();
      setState(() {
        _properties = properties;
        _filteredProperties = properties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterProperties() {
    List<Map<String, dynamic>> filtered = _properties;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((property) {
        final description =
            property['description']?.toString().toLowerCase() ?? '';
        final ville = property['ville']?.toString().toLowerCase() ?? '';
        final price = property['price']?.toString() ?? '';
        final ownerName =
            property['owners']?['name']?.toString().toLowerCase() ?? '';
        final propertyId = property['id']?.toString().toLowerCase() ?? '';

        return description.contains(_searchQuery.toLowerCase()) ||
            ville.contains(_searchQuery.toLowerCase()) ||
            price.contains(_searchQuery) ||
            ownerName.contains(_searchQuery.toLowerCase()) ||
            propertyId.contains(_searchQuery.toLowerCase()); // Recherche par ID
      }).toList();
    }

    if (_filterStatus != 'Tous') {
      filtered = filtered.where((property) {
        return property['state']?.toString() == _filterStatus;
      }).toList();
    }

    if (_filterCategory != 'Toutes') {
      filtered = filtered.where((property) {
        return property['categorie']?.toString() == _filterCategory;
      }).toList();
    }

    setState(() {
      _filteredProperties = filtered;
    });
  }

  List<String> _getAllImageUrls(Map<String, dynamic> property) {
    final List<String> urls = [];

    // Image principale
    if (property['link_home_images'] != null &&
        property['link_home_images'].toString().isNotEmpty) {
      urls.add(property['link_home_images'].toString());
    }

    // Autres images
    if (property['other_images'] is List) {
      final otherImages = List<String>.from(property['other_images'] ?? []);
      urls.addAll(otherImages.where((url) => url.isNotEmpty));
    }

    return urls;
  }

  void _showImageGallery(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune image disponible'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black87,
              ),
              child: PageView.builder(
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          'Image ${index + 1}/${imageUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrls[index],
                              fit: BoxFit.contain,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Image non disponible',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOwnerDetailsDialog(String ownerId) async {
    try {
      final ownerDetails = await _supabaseService.getOwnerDetails(ownerId);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Informations du Propriétaire'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOwnerInfoRow('Nom', ownerDetails['name']),
              _buildOwnerInfoRow('Email', ownerDetails['email']),
              _buildOwnerInfoRow('Téléphone', ownerDetails['phone']),
              _buildOwnerInfoRow('ID', ownerDetails['id']),
              if (ownerDetails['created_at'] != null)
                _buildOwnerInfoRow(
                  'Date d\'inscription',
                  _formatDate(ownerDetails['created_at']),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des informations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildOwnerInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value ?? 'Non renseigné')),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _showDeleteDialog(String id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer "$title" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Fermer le dialogue d'abord
              Navigator.of(context).pop();

              // Attendre un peu pour que l'animation se termine
              await Future.delayed(const Duration(milliseconds: 300));

              try {
                await _supabaseService.deletePropertyWithImages(id);
                await _loadProperties();

                // Utiliser un GlobalKey pour le ScaffoldMessenger
                if (_scaffoldKey.currentState?.mounted ?? false) {
                  ScaffoldMessenger.of(
                    _scaffoldKey.currentContext!,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text('Immobilier supprimé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Utiliser un GlobalKey pour le ScaffoldMessenger
                if (_scaffoldKey.currentState?.mounted ?? false) {
                  ScaffoldMessenger.of(
                    _scaffoldKey.currentContext!,
                  ).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la suppression: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyTable() {
    final allCategories = _properties
        .map((p) => p['categorie']?.toString())
        .where((c) => c != null)
        .toSet()
        .toList();

    return Column(
      children: [
        // Category filter dropdown
        if (allCategories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: 18,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 8),
                Text(
                  'Catégorie:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filterCategory,
                        isExpanded: true,
                        style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                        items: ['Toutes', ...allCategories]
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category ?? 'Non catégorisé'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _filterCategory = value!);
                          _filterProperties();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        // Property cards list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredProperties.length,
            itemBuilder: (context, index) {
              final property = _filteredProperties[index];
              return _buildPropertyCard(property, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property, int index) {
    final imageUrls = _getAllImageUrls(property);
    final hasImages = imageUrls.isNotEmpty;
    final ownerInfo = property['owners'] ?? {};
    final ownerName = ownerInfo['name'] ?? 'N/A';
    final price = property['price']?.toString() ?? 'N/A';
    final ville = property['ville'] ?? '';
    final state = property['state'] ?? 'N/A';
    final isActif = property['is_actif'] == true;
    final hasCourant = property['courant']?.toString().toLowerCase() == 'oui';
    final hasEau = property['eau']?.toString().toLowerCase() == 'oui';
    final nbPieces = property['nbr_pieces']?.toString() ?? '-';
    final categorie = property['categorie'] ?? '';
    final isParcelle = categorie == 'Parcelle';
    final surface = property['surface']?.toString() ?? '';
    final isCloture = property['is_cloture']?.toString().toUpperCase() ?? 'NON';

    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showPropertyDetails(property),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image thumbnail
                    GestureDetector(
                      onTap: hasImages
                          ? () => _showImageGallery(imageUrls)
                          : null,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: hasImages
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrls.first,
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.grey[300],
                                            ),
                                          ),
                                        );
                                      },
                                  errorBuilder: (ctx, err, st) => Icon(
                                    Icons.broken_image_rounded,
                                    color: Colors.grey[300],
                                    size: 28,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.home_rounded,
                                color: Colors.grey[300],
                                size: 28,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Property details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title + Status
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  property['description'] ?? 'Sans description',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(state),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  state,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Price + Location
                          Row(
                            children: [
                              Text(
                                "\$$price${(state.toString().toLowerCase().contains('louer') || state.toString().toLowerCase().contains('location')) ? '/mois' : ''}",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (ville.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 13,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    ville,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Amenities row (wraps on small screens)
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (isParcelle) ...[
                                _buildMiniChip(
                                  Icons.square_foot_rounded,
                                  surface.isNotEmpty ? '$surface m²' : '-',
                                  Colors.indigo,
                                ),
                                if (isCloture == 'OUI')
                                  Icon(
                                    Icons.fence_rounded,
                                    size: 14,
                                    color: Colors.brown[400],
                                  ),
                              ] else ...[
                                _buildMiniChip(
                                  Icons.door_back_door_rounded,
                                  '$nbPieces pcs',
                                  Colors.indigo,
                                ),
                                if (hasCourant)
                                  Icon(
                                    Icons.electrical_services_rounded,
                                    size: 14,
                                    color: Colors.amber[700],
                                  ),
                                if (hasEau)
                                  Icon(
                                    Icons.water_drop_rounded,
                                    size: 14,
                                    color: Colors.blue[400],
                                  ),
                              ],
                              if (categorie.isNotEmpty && !isParcelle)
                                _buildMiniChip(
                                  Icons.category_rounded,
                                  categorie,
                                  Colors.teal,
                                ),
                              if (!isActif)
                                Icon(
                                  Icons.visibility_off_rounded,
                                  size: 14,
                                  color: Colors.red[300],
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Owner + Actions row
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _showOwnerDetailsDialog(
                                    property['owner_id'],
                                  ),
                                  child: Text(
                                    ownerName,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddPropertyPage(
                                        property: property,
                                        onPropertySaved: _loadProperties,
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.edit_rounded,
                                    size: 16,
                                    color: Colors.blue[400],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _showDeleteDialog(
                                  property['id'],
                                  (property['description']?.length ?? 0) > 20
                                      ? '${property['description']?.substring(0, 20)}...'
                                      : property['description'] ??
                                            'cet immobilier',
                                ),
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16,
                                    color: Colors.red[400],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (50 * index).ms, duration: 300.ms)
        .slideX(begin: 0.05);
  }

  Widget _buildMiniChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showPropertyDetails(Map<String, dynamic> property) {
    final imageUrls = _getAllImageUrls(property);
    final ownerInfo = property['owners'] ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Image gallery
                  if (imageUrls.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        itemCount: imageUrls.length,
                        itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              imageUrls[i],
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, st) => Container(
                                color: Colors.grey[100],
                                child: const Icon(
                                  Icons.broken_image_rounded,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    property['description'] ?? 'Sans description',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Price + Status
                  Row(
                    children: [
                      Text(
                        "\$${property['price'] ?? 'N/A'}${(property['state']?.toString().toLowerCase().contains('louer') ?? false) || (property['state']?.toString().toLowerCase().contains('location') ?? false) ? '/mois' : ''}",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(property['state']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          property['state'] ?? 'N/A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  // Details grid
                  _buildDetailRow('Ville', property['ville']),
                  _buildDetailRow('Adresse', property['adress']),
                  _buildDetailRow('Catégorie', property['categorie']),
                  if (property['categorie'] == 'Parcelle') ...[
                    _buildDetailRow('Surface', property['surface'] != null ? '${property['surface']} m²' : null),
                    _buildDetailRow('Clôturé', property['is_cloture']?.toString()),
                  ] else ...[
                    _buildDetailRow('Pièces', property['nbr_pieces']?.toString()),
                    _buildDetailRow('Courant', property['courant']?.toString()),
                    _buildDetailRow('Eau', property['eau']?.toString()),
                  ],
                  _buildDetailRow(
                    'Actif',
                    property['is_actif'] == true ? 'Oui' : 'Non',
                  ),
                  _buildDetailRow(
                    'Date',
                    _formatDate(property['date_publishing'] ?? ''),
                  ),
                  _buildDetailRow('Propriétaire', ownerInfo['name']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'disponible':
      case 'a louer':
      case 'à louer':
        return const Color(0xFF00A859);
      case 'a vendre':
      case 'à vendre':
        return Colors.orange;
      case 'loué':
        return Colors.blue;
      case 'vendu':
        return Colors.purple;
      case 'en attente':
        return Colors.amber[700]!;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _loadProperties,
        child: Column(
          children: [
            // Statistiques compactes
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildStatChip('Total', _properties.length, Colors.blue),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    'A Louer',
                    _properties.where((p) => p['state'] == 'A Louer').length,
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    'A Vendre',
                    _properties.where((p) => p['state'] == 'A Vendre').length,
                    Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    'Actifs',
                    _properties.where((p) => p['is_actif'] == true).length,
                    Colors.purple,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            // Barre de recherche
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher par description, ville, prix...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey[400],
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  _filterProperties();
                },
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            // Filtres
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Tous', _filterStatus == 'Tous', (
                      selected,
                    ) {
                      if (selected) {
                        setState(() => _filterStatus = 'Tous');
                        _filterProperties();
                      }
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip('A Louer', _filterStatus == 'A Louer', (
                      selected,
                    ) {
                      if (selected) {
                        setState(() => _filterStatus = 'A Louer');
                        _filterProperties();
                      }
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip('A Vendre', _filterStatus == 'A Vendre', (
                      selected,
                    ) {
                      if (selected) {
                        setState(() => _filterStatus = 'A Vendre');
                        _filterProperties();
                      }
                    }),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

            // Contenu principal
            Expanded(
              child: _isLoading && _properties.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredProperties.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 56,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Aucun immobilier trouvé',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildPropertyTable(),
            ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddPropertyPage(onPropertySaved: _loadProperties),
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Ajouter',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ).animate().scale(delay: 800.ms),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    Function(bool) onSelected,
  ) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.15),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.3)
              : Colors.grey.shade200,
        ),
      ),
    );
  }
}
