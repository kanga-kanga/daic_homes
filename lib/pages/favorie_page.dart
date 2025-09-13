import 'package:daic_home/models/house.dart';
import 'package:daic_home/services/auth_service.dart';
import 'package:daic_home/widget/card_house_sale.dart';
import 'package:daic_home/widget/shimmer_loading_card.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:motion_toast/motion_toast.dart';

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
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Afficher le shimmer effect pendant le chargement
          return ListView.builder(
            itemCount: 5, // Nombre de placeholders à afficher
            itemBuilder: (context, index) => const ShimmerLoadingCard(),
          );
        } else if (snapshot.hasError) {
          // Afficher un SnackBar pour signaler l'erreur
          WidgetsBinding.instance.addPostFrameCallback((_) {
            MotionToast.error(
              title: const Text('Erreur de connexion'),
              description: Text("${snapshot.error}"),
              animationType: AnimationType.slideInFromBottom,
            ).show(context);
          });

          return ListView.builder(
            itemCount: 5, // Nombre de placeholders à afficher
            itemBuilder: (context, index) => const ShimmerLoadingCard(),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emoji ou icône d'un visage triste
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Lottie.asset('assets/lottie/crying.json'),
                ),
                const SizedBox(
                  height: 20,
                ), // Espacement entre l'icône et le texte
                // Texte indiquant qu'aucune maison n'a été trouvée
                const Text(
                  'Aucune maison trouvée.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                // Texte supplémentaire pour guider l'utilisateur
                // const Text(
                //   'Essayez de modifier vos critères de recherche.',
                //   style: TextStyle(fontSize: 14, color: Colors.grey),
                //   textAlign: TextAlign.center,
                // ),
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
    );
  }
}
