// import 'package:daic_home/datas/houses_data.dart';
import 'package:daic_home/models/house.dart';
import 'package:daic_home/services/auth_service.dart';
import 'package:daic_home/widget/card_house_sale.dart';
import 'package:daic_home/widget/shimmer_loading_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:motion_toast/motion_toast.dart';

class ResultSearchPage extends StatefulWidget {
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final int? nbrRooms;
  final String? location;

  const ResultSearchPage({
    super.key,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.nbrRooms,
    this.location,
  });

  @override
  State<ResultSearchPage> createState() => _SeeMorePageState();
}

class _SeeMorePageState extends State<ResultSearchPage> {
  late Future<List<House>> _filteredHousesFuture;

  @override
  void initState() {
    super.initState();
    _filteredHousesFuture = _fetchFilteredHouses();
  }

  Future<List<House>> _fetchFilteredHouses() async {
    // Appel à la méthode existante dans auth_service
    print("--------------------------------");
    print("VOICI LES FILTRES");
    print("Category: ${widget.category}");
    print("Min Price: ${widget.minPrice}");
    print("Max Price: ${widget.maxPrice}");
    print("Nbr Rooms: ${widget.nbrRooms}");
    print("Location: ${widget.location}");

    return await AuthService().searchProperties(
      category: widget.category,
      minPrice: widget.minPrice,
      maxPrice: widget.maxPrice,
      nbrRooms: widget.nbrRooms,
      location: widget.location,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: SafeArea(
          child: AppBar(
            title: Text(
              "Résultats de recherche",
              style: GoogleFonts.acme(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            centerTitle: false,
          ),
        ),
      ),
      body: FutureBuilder<List<House>>(
        future: _filteredHousesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Afficher l'effet shimmer pendant le chargement
            return ListView.builder(
              itemCount: 5, // Nombre de placeholders à afficher
              itemBuilder: (context, index) => const ShimmerLoadingCard(),
            );
          } else if (snapshot.hasError) {
            // Afficher un message d'erreur
            WidgetsBinding.instance.addPostFrameCallback((_) {
              MotionToast.error(
                title: const Text('Erreur de connexion'),
                description: Text('${snapshot.error}'),
                animationType: AnimationType.slideInFromBottom,
              ).show(context);
            });
            return ListView.builder(
              itemCount: 5, // Nombre de placeholders à afficher
              itemBuilder: (context, index) => const ShimmerLoadingCard(),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Afficher un message si aucune maison n'est trouvée
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
                  const SizedBox(height: 10),
                  const Text(
                    'Essayez de modifier vos critères de recherche.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final houses = snapshot.data!;
          return ListView.builder(
            itemCount: houses.length,
            itemBuilder:
                (context, index) =>
                    CardHouseSale(house: houses[index], index: index + 1),
          );
        },
      ),
    );
  }
}
