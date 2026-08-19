import 'package:daic_home/pages/result_search_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _selectedTransactionType = "À louer";
  String? _selectedCategory;
  int? _selectedRooms;
  final TextEditingController _surfaceController = TextEditingController();
  RangeValues _budgetRange = const RangeValues(0, 5000);
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minBudgetController = TextEditingController(
    text: "0",
  );
  final TextEditingController _maxBudgetController = TextEditingController(
    text: "5000",
  );

  List<String> _searchHistory = []; // Sera des chaines JSON

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('search_history') ?? [];
    });
  }

  Future<void> _saveSearch() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('search_history') ?? [];
    
    // Create criteria map
    Map<String, dynamic> criteria = {
      'query': _searchController.text,
      'category': _selectedCategory,
      'transactionType': _selectedTransactionType,
      'minPrice': _minBudgetController.text,
      'maxPrice': _maxBudgetController.text,
      'rooms': _selectedRooms,
      'surface': _surfaceController.text,
    };
    
    // Ignore empty search
    if (criteria['query'].toString().trim().isEmpty && criteria['category'] == null) {
      return;
    }

    String jsonString = jsonEncode(criteria);

    // Eviter les doublons et limiter à 5
    history.remove(jsonString);
    history.insert(0, jsonString);
    if (history.length > 5) history = history.sublist(0, 5);
    
    await prefs.setStringList('search_history', history);
    _loadSearchHistory();
  }

  Future<void> _clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history');
    setState(() {
      _searchHistory = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recherche - Toggles
              Text(
                "Recherche",
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap:
                            () => setState(
                              () => _selectedTransactionType = "À louer",
                            ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                _selectedTransactionType == "À louer"
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              "À louer",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color:
                                    _selectedTransactionType == "À louer"
                                        ? Colors.white
                                        : Colors.grey[800],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap:
                            () => setState(
                              () => _selectedTransactionType = "À vendre",
                            ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                _selectedTransactionType == "À vendre"
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              "À vendre",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color:
                                    _selectedTransactionType == "À vendre"
                                        ? Colors.white
                                        : Colors.grey[800],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1),

              const SizedBox(height: 16),

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Quartier, commune, ville...",
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                    icon: Icon(Icons.search_rounded, color: Colors.grey[500]),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ).animate().fadeIn().slideY(begin: 0.1),

              const SizedBox(height: 24),

              // Type de bien
              Text(
                "Type de bien",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildCategoryChip("Maison", Icons.home_rounded),
                    _buildCategoryChip("Appartement", Icons.apartment_rounded),
                    _buildCategoryChip("Parcelle", Icons.map_rounded),
                    _buildCategoryChip(
                      "Local Commercial",
                      Icons.storefront_rounded,
                    ),
                    _buildCategoryChip(
                      "Concession",
                      Icons.house_siding_rounded,
                    ),
                    _buildCategoryChip("Studio", Icons.king_bed_rounded),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1),

              const SizedBox(height: 24),

              // Budget
              Text(
                "Budget",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "\$${_budgetRange.start.toInt()}",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "\$${_budgetRange.end.toInt()}",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: Colors.grey[300],
                  thumbColor: Theme.of(context).colorScheme.primary,
                  overlayColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.2),
                ),
                child: RangeSlider(
                  values: _budgetRange,
                  min: 0,
                  max: 1000000,
                  divisions: 100,
                  onChanged: (RangeValues values) {
                    setState(() {
                      _budgetRange = values;
                      _minBudgetController.text =
                          values.start.toInt().toString();
                      _maxBudgetController.text = values.end.toInt().toString();
                    });
                  },
                ),
              ).animate().fadeIn().slideY(begin: 0.1),

              Row(
                children: [
                  Expanded(child: _buildBudgetInput(_minBudgetController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildBudgetInput(_maxBudgetController)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.compare_arrows_rounded,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ],
              ).animate().fadeIn().slideY(begin: 0.1),

              const SizedBox(height: 24),

              // Filtres Dynamiques
              if (_selectedCategory != null) ...[
                const SizedBox(height: 24),

                // Nombre de pièces (pour tout sauf Parcelle)
                if (_selectedCategory != "Parcelle") ...[
                  Text(
                    "Nombre de pièces minimum",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children:
                          [
                            1,
                            2,
                            3,
                            4,
                            5,
                          ].map((n) => _buildRoomChip(n)).toList(),
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),
                  const SizedBox(height: 24),
                ],

                // Surface (pour Parcelle et Concession)
                if (_selectedCategory == "Parcelle" ||
                    _selectedCategory == "Concession") ...[
                  Text(
                    "Surface minimale (m²)",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _surfaceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Ex: 200",
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                        suffixText: "m²",
                        border: InputBorder.none,
                      ),
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),
                ],
              ],

              const SizedBox(height: 32),

              // Rechercher Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _saveSearch();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ResultSearchPage(
                              category: _selectedCategory,
                              minPrice: double.tryParse(
                                _minBudgetController.text,
                              ),
                              maxPrice: double.tryParse(
                                _maxBudgetController.text,
                              ),
                              nbrRooms: _selectedRooms,
                              minSurface: double.tryParse(
                                _surfaceController.text,
                              ),
                              state:
                                  _selectedTransactionType == "À louer"
                                      ? "A Louer"
                                      : "A Vendre",
                              location:
                                  _searchController.text.isNotEmpty
                                      ? _searchController.text
                                      : null,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Rechercher",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().fadeIn().scale(),

              const SizedBox(height: 32),

              // Recherches récentes
              if (_searchHistory.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recherches récentes",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: _clearSearchHistory,
                      child: Text(
                        "Tout effacer",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn().slideY(begin: 0.1),
                const SizedBox(height: 8),
                ..._searchHistory.map((text) {
                  try {
                    Map<String, dynamic> criteria = jsonDecode(text);
                    String label = criteria['query'] ?? "";
                    if (label.isEmpty) {
                      label = criteria['category'] ?? "Recherche";
                    } else if (criteria['category'] != null) {
                      label += " • ${criteria['category']}";
                    }
                    if (label.isEmpty) label = "Recherche";

                    return GestureDetector(
                      onTap: () {
                        // Mettre à jour l'état si on veut que l'interface reflète les critères ?
                        // Le plus simple c'est de lancer directement la recherche.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultSearchPage(
                              category: criteria['category'],
                              minPrice: double.tryParse(criteria['minPrice'] ?? ""),
                              maxPrice: double.tryParse(criteria['maxPrice'] ?? ""),
                              nbrRooms: criteria['rooms'],
                              minSurface: double.tryParse(criteria['surface'] ?? ""),
                              state: criteria['transactionType'] == "À louer" ? "A Louer" : "A Vendre",
                              location: (criteria['query'] != null && criteria['query'].toString().isNotEmpty) ? criteria['query'] : null,
                            ),
                          ),
                        );
                      },
                      child: _buildRecentSearch(label)
                          .animate()
                          .fadeIn()
                          .slideY(begin: 0.1),
                    );
                  } catch (e) {
                    // Pour la compatibilité avec l'ancien historique en chaines de caractères simples
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                           _searchController.text = text;
                        });
                      },
                      child: _buildRecentSearch(text)
                          .animate()
                          .fadeIn()
                          .slideY(begin: 0.1),
                    );
                  }
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    final bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = isSelected ? null : label;
          // Reset dependent fields if needed
          if (_selectedCategory == "Parcelle") _selectedRooms = null;
          if (_selectedCategory != "Parcelle" &&
              _selectedCategory != "Concession")
            _surfaceController.clear();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[800],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomChip(int number) {
    final bool isSelected = _selectedRooms == number;
    return GestureDetector(
      onTap: () => setState(() => _selectedRooms = isSelected ? null : number),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                  : null,
        ),
        child: Center(
          child: Text(
            "$number${number == 5 ? '+' : ''}",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey[800],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetInput(TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          prefixText: "\$ ",
          prefixStyle: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildRecentSearch(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: GoogleFonts.poppins(color: Colors.grey[700])),
          Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
