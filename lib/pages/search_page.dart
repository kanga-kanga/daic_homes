import 'package:daic_home/pages/result_search_page.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? _selectedType;
  String? _selectedMinPrice;
  String? _selectedMaxPrice;
  String? _selectedRooms;
  String? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image de fond avec dégradé
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.asset(
                  "assets/images/imgSearch.jpg",
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: Text(
                  "Rechercher un bien immobilier",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Dropdown pour le type
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedType,
              items: const [
                DropdownMenuItem(
                  value: "Appartement",
                  child: Text("Appartement"),
                ),
                DropdownMenuItem(value: "Maison", child: Text("Maison")),
                DropdownMenuItem(value: "Studio", child: Text("Studio")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
              decoration: InputDecoration(
                labelText: "Type",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Dropdown pour le prix minimum
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedMinPrice?.toString(),
              items: const [
                DropdownMenuItem(value: "1", child: Text("1 \$ +")),
                DropdownMenuItem(value: "200", child: Text("200 \$ +")),
                DropdownMenuItem(value: "500", child: Text("500 \$ +")),
                DropdownMenuItem(value: "800", child: Text("800 \$ +")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedMinPrice = value;
                });
              },
              decoration: InputDecoration(
                labelText: "Prix Minimum",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Dropdown pour le prix maximum
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedMaxPrice?.toString(),
              items: const [
                DropdownMenuItem(value: "200", child: Text("200 \$ -")),
                DropdownMenuItem(value: "500", child: Text("500 \$ -")),
                DropdownMenuItem(value: "800", child: Text("800 \$ -")),
                DropdownMenuItem(value: "1000", child: Text("1000 \$ -")),
                DropdownMenuItem(value: "1500", child: Text("1500 \$ -")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedMaxPrice = value;
                });
              },
              decoration: InputDecoration(
                labelText: "Prix Maximum",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Dropdown pour le nombre de pièces
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedRooms?.toString(),
              items: List.generate(
                8,
                (index) => DropdownMenuItem(
                  value: "${index + 1}",
                  child: Text("${index + 1} + pièce${index > 0 ? 's' : ''}"),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedRooms = value;
                });
              },
              decoration: InputDecoration(
                labelText: "Nombre de pièces",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Dropdown pour le Ville
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedLocation,
              items: const [
                DropdownMenuItem(
                  value: "Lubumbashi",
                  child: Text("Lubumbashi"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value;
                });
              },
              decoration: InputDecoration(
                labelText: "Ville",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Bouton de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ResultSearchPage(
                            category: _selectedType,
                            minPrice: double.tryParse(_selectedMinPrice ?? "0"),
                            maxPrice: double.tryParse(_selectedMaxPrice ?? "0"),
                            nbrRooms: int.tryParse(_selectedRooms ?? "0"),
                            location: _selectedLocation,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Rechercher", style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
