import 'package:daic_home/pages/result_search_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:daic_home/models/house.dart';
import 'package:daic_home/services/auth_service.dart';

class SeeMorePage extends StatefulWidget {
  const SeeMorePage({super.key});

  @override
  State<SeeMorePage> createState() => _SeeMorePageState();
}

class _SeeMorePageState extends State<SeeMorePage> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, int> _categoryCounts = {
    "Maison": 0,
    "Appartement": 0,
    "Parcelle": 0,
    "Concession": 0,
    "Studio": 0,
    "Local Commercial": 0,
  };
  int _totalHouses = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategoryCounts();
  }

  Future<void> _fetchCategoryCounts() async {
    try {
      final houses = await AuthService().fetchHouses();
      final Map<String, int> counts = {
        "Maison": 0,
        "Appartement": 0,
        "Parcelle": 0,
        "Concession": 0,
        "Studio": 0,
        "Local Commercial": 0,
      };

      for (House house in houses) {
        String cat = house.categorie;
        if (counts.containsKey(cat)) {
          counts[cat] = counts[cat]! + 1;
        } else if (cat.toLowerCase() == 'maisons') {
          counts["Maison"] = counts["Maison"]! + 1;
        } else if (cat.toLowerCase() == 'appartements') {
          counts["Appartement"] = counts["Appartement"]! + 1;
        } else if (cat.toLowerCase() == 'parcelles') {
          counts["Parcelle"] = counts["Parcelle"]! + 1;
        } else if (cat.toLowerCase() == 'concessions') {
          counts["Concession"] = counts["Concession"]! + 1;
        } else if (cat.toLowerCase() == 'studios') {
          counts["Studio"] = counts["Studio"]! + 1;
        } else if ([
          'local commercial',
          'local',
          'locaux',
          'commercial',
        ].contains(cat.toLowerCase())) {
          counts["Local Commercial"] = (counts["Local Commercial"] ?? 0) + 1;
        }
      }

      if (mounted) {
        setState(() {
          _categoryCounts = counts;
          _totalHouses = houses.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToSearch(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultSearchPage(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(
                top: 50,
                left: 20,
                right: 20,
                bottom: 30,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "Catégories de biens",
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Choisissez une catégorie pour explorer les annonces",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),

                  const SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Rechercher par ville, quartier...",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Colors.grey,
                        ),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                  const SizedBox(height: 20),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildStatPill(
                          Icons.apartment_rounded,
                          _isLoading ? "..." : _totalHouses.toString(),
                          "Biens disponibles",
                        ),
                        _buildStatPill(
                          Icons.verified_rounded,
                          "Biens vérifiés",
                          "Propriétaires & Agents",
                        ),
                        _buildStatPill(
                          Icons.location_on_rounded,
                          "Lubumbashi",
                          "Haut-Katanga",
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
          ),

          // Categories List
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildCategoryCard(
                  title: "Maisons",
                  subtitle: "À louer & à vendre",
                  announces:
                      _isLoading ? "..." : _categoryCounts["Maison"].toString(),
                  badgeText: "⭐ Le plus demandé",
                  badgeColor: Colors.green,
                  imagePlaceholderUrl: "assets/images/maisons.png",
                  attributes: [
                    _buildAttrChip(Icons.meeting_room_rounded, "3 pièces +"),
                    _buildAttrChip(Icons.bolt_rounded, "Électricité"),
                    _buildAttrChip(Icons.water_drop_rounded, "Eau"),
                  ],
                  location: "Tous les quartiers de Lubumbashi",
                  onTap: () => _navigateToSearch("Maison"),
                ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2),

                const SizedBox(height: 16),

                _buildCategoryCard(
                  title: "Appartements",
                  subtitle: "Moderne & Sécurisé",
                  announces:
                      _isLoading
                          ? "..."
                          : _categoryCounts["Appartement"].toString(),
                  badgeText: "🏢 Tendance",
                  badgeColor: Colors.blue,
                  imagePlaceholderUrl: "assets/images/appartement.png",
                  attributes: [
                    _buildAttrChip(Icons.stairs_rounded, "Étages"),
                    _buildAttrChip(Icons.security_rounded, "Sécurisé"),
                    _buildAttrChip(Icons.directions_car_rounded, "Parking"),
                  ],
                  location: "Centre-ville • Golf • Gambela",
                  onTap: () => _navigateToSearch("Appartement"),
                ).animate().fadeIn(delay: 450.ms).slideX(begin: 0.2),

                const SizedBox(height: 16),

                _buildCategoryCard(
                  title: "Parcelles",
                  subtitle: "À vendre uniquement",
                  announces:
                      _isLoading
                          ? "..."
                          : _categoryCounts["Parcelle"].toString(),
                  badgeText: "🔥 Très recherché",
                  badgeColor: Colors.orange,
                  imagePlaceholderUrl: "assets/images/parcelles.png",
                  attributes: [
                    _buildAttrChip(Icons.straighten_rounded, "Dimensions"),
                    _buildAttrChip(Icons.description_rounded, "Titre foncier"),
                    _buildAttrChip(Icons.fence_rounded, "Viabilisées"),
                  ],
                  location: "Annexe • Kampemba • CDM",
                  onTap: () => _navigateToSearch("Parcelle"),
                ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.2),

                const SizedBox(height: 16),

                _buildCategoryCard(
                  title: "Locaux C...",
                  subtitle: "Bureaux, ...",
                  announces:
                      _isLoading
                          ? "..."
                          : (_categoryCounts["Local Commercial"]?.toString() ??
                              "0"),
                  badgeText: "💼 Business ready",
                  badgeColor: Colors.cyan,
                  imagePlaceholderUrl: "assets/images/locaux_commerciaux.png",
                  attributes: [
                    _buildAttrChip(Icons.storefront_rounded, "Visibilité"),
                    _buildAttrChip(Icons.location_city_rounded, "Zone"),
                    _buildAttrChip(Icons.bolt_rounded, "Eau/Élec"),
                  ],
                  location: "Marché M'zee • Centre-ville",
                  onTap: () => _navigateToSearch("Local Commercial"),
                ).animate().fadeIn(delay: 550.ms).slideX(begin: 0.2),

                const SizedBox(height: 16),

                _buildCategoryCard(
                  title: "Concessions",
                  subtitle: "À louer & à vendre",
                  announces:
                      _isLoading
                          ? "..."
                          : _categoryCounts["Concession"].toString(),
                  badgeText: "🏛️ Grands espaces",
                  badgeColor: Colors.purple,
                  imagePlaceholderUrl: "assets/images/concessions.png",
                  attributes: [
                    _buildAttrChip(Icons.home_work_rounded, "Multibien"),
                    _buildAttrChip(Icons.domain_rounded, "Invest."),
                  ],
                  location: "Plateau • Golf • Kenya",
                  onTap: () => _navigateToSearch("Concession"),
                ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.2),

                const SizedBox(height: 16),

                _buildCategoryCard(
                  title: "Studios",
                  subtitle: "Compact & Pratique",
                  announces:
                      _isLoading ? "..." : _categoryCounts["Studio"].toString(),
                  badgeText: "👤 Solo / Étudiant",
                  badgeColor: Colors.amber,
                  imagePlaceholderUrl: "assets/images/studio.png",
                  attributes: [
                    _buildAttrChip(Icons.king_bed_rounded, "1 Pièce"),
                    _buildAttrChip(Icons.kitchen_rounded, "Kitchenette"),
                  ],
                  location: "Proximité Universités",
                  onTap: () => _navigateToSearch("Studio"),
                ).animate().fadeIn(delay: 650.ms).slideX(begin: 0.2),

                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Vous ne savez pas quoi choisir ?",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.support_agent_rounded,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Trouvez le bien idéal avec nous",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Obtenez des recommandations personnalisées",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),

                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required String announces,
    required String badgeText,
    required Color badgeColor,
    required String imagePlaceholderUrl,
    required List<Widget> attributes,
    required String location,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Column(
            children: [
              // Image and Badges
              Stack(
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      image: DecorationImage(
                        image: imagePlaceholderUrl.startsWith('http') 
                               ? CachedNetworkImageProvider(imagePlaceholderUrl) as ImageProvider
                               : AssetImage(imagePlaceholderUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.home_work_rounded,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  subtitle,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "$announces annonces",
                            style: GoogleFonts.poppins(
                              color: Colors.green[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Attributes Row
                    Wrap(spacing: 8, runSpacing: 8, children: attributes),
                    const SizedBox(height: 16),
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            location,
                            style: GoogleFonts.poppins(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Voir toutes les $title →",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttrChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
