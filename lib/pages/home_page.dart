import 'package:daic_home/models/house.dart';
import 'package:daic_home/pages/result_search_page.dart';
import 'package:daic_home/services/auth_service.dart';
import 'package:daic_home/services/navigation_helper.dart';
import 'package:daic_home/widget/card_house_sale.dart';
import 'package:daic_home/widget/shimmer_loading_card.dart';
import 'package:daic_home/widget/elegant_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePagePrincipaleState();
}

class _HomePagePrincipaleState extends State<HomePage> {
  String _selectedTransactionType = "À louer";
  String? _selectedCategory;
  String? _selectedLocation;
  late Future<List<House>> _housesFuture;

  @override
  void initState() {
    super.initState();
    _housesFuture = AuthService().fetchHouses();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<House>>(
      future: _housesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const ShimmerLoadingCard(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("Une erreur est survenue"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Lottie.asset('assets/lottie/crying.json'),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Aucune maison trouvée.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        final houses = snapshot.data!;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header / Greeting
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Trouvez votre prochain Chez-vous",
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      // Container(
                      //   padding: const EdgeInsets.all(8),
                      //   decoration: BoxDecoration(
                      //     color: Theme.of(
                      //       context,
                      //     ).colorScheme.primary.withOpacity(0.1),
                      //     shape: BoxShape.circle,
                      //   ),
                      //   child: Icon(
                      //     Icons.notifications_none_rounded,
                      //     color: Theme.of(context).colorScheme.primary,
                      //   ),
                      // ),
                    ],
                  ),
                ).animate().fadeIn().slideX(),

                // Search & Filter Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Transaction Type Toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: _buildToggleItem("À louer")),
                            Expanded(child: _buildToggleItem("À vendre")),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category Dropdown
                      _buildDropdownField(
                        icon: Icons.category_rounded,
                        label: "Type des biens",
                        value: _selectedCategory,
                        items: [
                          "Maison",
                          "Appartement",
                          "Parcelle",
                          "Local Commercial",
                          "Concession",
                          "Studio",
                        ],
                        onChanged:
                            (val) => setState(() => _selectedCategory = val),
                      ),
                      const SizedBox(height: 12),

                      // Location Input (simplified for now)
                      _buildDropdownField(
                        icon: Icons.location_on_rounded,
                        label: "Emplacement",
                        value: _selectedLocation,
                        items: ["Lubumbashi"],
                        onChanged:
                            (val) => setState(() => _selectedLocation = val),
                      ),
                      const SizedBox(height: 20),

                      // Search Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ResultSearchPage(
                                      category: _selectedCategory,
                                      state:
                                          _selectedTransactionType == "À louer"
                                              ? "A Louer"
                                              : "A Vendre",
                                    ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Rechercher",
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),

                // Horizontal Categories Tiles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Parcourir par type",
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed:
                          () => NavigatorHelper.toSeeMore(context: context),
                      child: Text("Voir tout >"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildCategoryTile(
                        "Maison",
                        Icons.home_rounded,
                        const Color(0xFF6A9977),
                      ),
                      _buildCategoryTile(
                        "Appartement",
                        Icons.apartment_rounded,
                        Colors.blue[100]!,
                      ),
                      _buildCategoryTile(
                        "Parcelle",
                        Icons.map_rounded,
                        Colors.orange[100]!,
                      ),
                      _buildCategoryTile(
                        "Local Commercial",
                        Icons.storefront_rounded,
                        Colors.cyan[100]!,
                      ),
                      _buildCategoryTile(
                        "Concession",
                        Icons.house_siding_rounded,
                        Colors.purple[100]!,
                      ),
                      _buildCategoryTile(
                        "Studio",
                        Icons.king_bed_rounded,
                        Colors.amber[100]!,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 24),

                // Recent Properties
                Text(
                  "Biens récents",
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 185,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: houses.length > 5 ? 5 : houses.length,
                    itemBuilder:
                        (context, index) => Container(
                          width: 220,
                          margin: const EdgeInsets.only(right: 16),
                          child: CardHouseSale(
                            house: houses[index],
                            index: index,
                            heroPrefix: 'recent-',
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleItem(String label) {
    bool isSelected = _selectedTransactionType == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTransactionType = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required IconData icon,
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[400]),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(item, style: GoogleFonts.poppins(fontSize: 14)),
                    ],
                  ),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCategoryTile(String title, IconData icon, Color color) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultSearchPage(category: title),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
