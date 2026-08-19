import 'package:daic_home/models/house.dart';
import 'package:daic_home/services/auth_service.dart';
import 'package:daic_home/widget/card_house_sale.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoriePage extends StatefulWidget {
  const FavoriePage({super.key});

  @override
  State<FavoriePage> createState() => _FavoriePageState();
}

class _FavoriePageState extends State<FavoriePage> {
  late Future<List<House>> _housesFuture;

  @override
  void initState() {
    super.initState();
    _housesFuture =
        AuthService().getFavorites(); // Initialiser la liste des maisons
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<House>>(
      future: _housesFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
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
                  delay: const Duration(milliseconds: 200),
                  effects: [const ScaleEffect()],
                  child: Lottie.asset(
                    'assets/lottie/crying.json',
                    width: 200,
                    height: 200,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Vos favoris sont vides',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Ajoutez des maisons à vos favoris pour les retrouver ici.',
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
                link_home_images: '',
                other_images: [],
                courant: '',
                eau: '',
                adress: 'Skeleton address',
                description: '',
                state: '',
                categorie: '',
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
            itemBuilder: (context, index) {
              return CardHouseSale(
                house: houses[index],
                index: index,
                heroPrefix: 'fav-',
              ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1);
            },
          ),
        );
      },
    );
  }
}
