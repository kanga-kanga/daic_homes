import 'package:daic_home/models/house.dart';
import 'package:daic_home/utils/price_formatter.dart';
import 'package:daic_home/utils/image_utils.dart';

import 'package:daic_home/pages/details_page.dart';
import 'package:daic_home/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ResultSearchPage extends StatefulWidget {
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final int? nbrRooms;
  final String? location;
  final String? state; // e.g., 'location' or 'vente'
  final double? minSurface; // Nouveau paramètre

  const ResultSearchPage({
    super.key,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.nbrRooms,
    this.location,
    this.state,
    this.minSurface,
  });

  @override
  State<ResultSearchPage> createState() => _ResultSearchPageState();
}

class _ResultSearchPageState extends State<ResultSearchPage> {
  late Future<List<House>> _filteredHousesFuture;

  @override
  void initState() {
    super.initState();
    _filteredHousesFuture = _fetchFilteredHouses();
  }

  Future<List<House>> _fetchFilteredHouses() async {
    return await AuthService().searchProperties(
      category: widget.category,
      minPrice: widget.minPrice,
      maxPrice: widget.maxPrice,
      nbrRooms: widget.nbrRooms,
      location: widget.location,
      state: widget.state,
      minSurface: widget.minSurface,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Background color logic
      appBar: AppBar(
        title: FutureBuilder<List<House>>(
          future: _filteredHousesFuture,
          builder: (context, snapshot) {
            final count = snapshot.hasData ? snapshot.data!.length : 0;
            return Text(
              "Résultats ($count)",
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey[900],
              ),
            );
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white, // Match image 5 background
        foregroundColor: Colors.grey[900],
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.map_rounded), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Active Filters Strip
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  if (widget.category != null && widget.category != "Toutes")
                    _buildFilterChip(widget.category!),
                  if (widget.state != null && widget.state!.isNotEmpty)
                    _buildFilterChip(
                      widget.state == 'A Louer' ? 'À louer' : 'À vendre',
                    ),
                  if (widget.location != null && widget.location!.isNotEmpty)
                    _buildFilterChip(widget.location!),
                  _buildFilterChip(
                    "${PriceFormatter.format(widget.minPrice?.toInt() ?? 0)}\$ - ${widget.maxPrice != null ? PriceFormatter.format(widget.maxPrice!.toInt()) : 'Max'}\$",
                  ),
                  if (widget.nbrRooms != null)
                    _buildFilterChip("${widget.nbrRooms}+ Pièces"),
                  if (widget.minSurface != null)
                    _buildFilterChip("${widget.minSurface?.toInt()}m²+"),

                  // "+ de filtres" button
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 16,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "de filtres",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

          Expanded(
            child: FutureBuilder<List<House>>(
              future: _filteredHousesFuture,
              builder: (context, snapshot) {
                final isLoading =
                    snapshot.connectionState == ConnectionState.waiting;
                final hasError = snapshot.hasError;
                final hasData = snapshot.hasData && snapshot.data!.isNotEmpty;

                if (hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Une erreur est survenue",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!isLoading && !hasData) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Animate(
                          delay: 200.ms,
                          effects: const [ScaleEffect()],
                          child: Lottie.asset(
                            'assets/lottie/crying.json',
                            width: 150,
                            height: 150,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Aucun résultat trouvé',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Essayez de modifier vos critères de recherche pour obtenir plus de résultats.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final houses =
                    snapshot.data ??
                    List.generate(
                      5,
                      (index) => House(
                        id: 'skeleton-$index',
                        price: 0,
                        nbr_pieces: 0,
                        link_home_images: 'https://via.placeholder.com/150',
                        other_images: [],
                        courant: '',
                        eau: '',
                        adress: 'Skeleton address',
                        description: '',
                        state: '',
                        categorie: 'Maison',
                        datePubishing: '',
                        surface: null,
                        is_cloture: null,
                      ),
                    );

                return Skeletonizer(
                  enabled: isLoading,
                  child: ListView.builder(
                    itemCount: houses.length,
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildResultCard(houses[index], context)
                            .animate()
                            .fadeIn(delay: (index * 100).ms)
                            .slideX(begin: 0.1),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildResultCard(House house, BuildContext context) {
    // Handling placeholder images if link_home_images is missing or invalid
    final imageUrl =
        (house.link_home_images.isNotEmpty)
            ? ImageUtils.cleanImageUrl(house.link_home_images)
            : ImageUtils.getDefaultImageForCategory(house.categorie);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailsPage(house: house)),
        );
      },
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: SizedBox(
                width: 130,
                height: 140,
                child: imageUrl.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(color: Colors.grey[200]),
                      errorWidget:
                          (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported),
                          ),
                    )
                  : Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
              ),
            ),

            // Right Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top row: transaction type / status badge and favorite icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            house.state == 'A Vendre' ? "À vendre" : "À louer",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color:
                                  house.state == 'A Vendre'
                                      ? Colors.orange[800]
                                      : Colors.blue[700],
                            ),
                          ),
                        ),
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 20,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),

                    // Title
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            "${house.categorie} • ${house.adress.split(',').first}",
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: Colors.blue[600],
                        ),
                      ],
                    ),

                    Text(
                      "${PriceFormatter.format(house.price.toInt())} \$${house.isForRent ? '/mois' : ''}",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            house.adress,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Divider and Features
                    const Divider(height: 12, thickness: 0.5),
                    Row(
                      children: [
                        _buildSmallFeature(
                          Icons.meeting_room_rounded,
                          "${house.nbr_pieces} pièces",
                        ),
                        const SizedBox(width: 12),
                        _buildSmallFeature(
                          Icons.bolt_rounded,
                          house.courant == "OUI" ? "Oui" : "Non",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallFeature(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
