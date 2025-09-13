// import 'package:daic_home/datas/houses_data.dart';
import 'package:daic_home/models/house.dart';
import 'package:daic_home/pages/result_search_page.dart';
import 'package:daic_home/services/auth_service.dart';
import 'package:daic_home/services/navigation_helper.dart';
import 'package:daic_home/widget/card_house_sale.dart';
import 'package:daic_home/widget/card_house_sale_row.dart';
import 'package:daic_home/widget/shimmer_loading_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:motion_toast/motion_toast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePagePrincipaleState();
}

class _HomePagePrincipaleState extends State<HomePage> {
  String? _selectedCategory;
  String? _selectedRooms;
  late Future<List<House>> _housesFuture;
  late Future firstnameUser;
  final TextEditingController _minRentController = TextEditingController();
  final TextEditingController _maxRentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    firstnameUser =
        AuthService().getUserFirstName(); // Récupérer le nom de l'utilisateur
    _housesFuture =
        AuthService().fetchHouses(); // Initialiser la liste des maisons
  }

  @override
  Widget build(BuildContext context) {
    // final houses = DataHouse().allHouse();

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
              title: const Text('Connexion instable'),
              description: Text("Verifier votre connexion internet"),
              animationType: AnimationType.slideInFromBottom,
              toastDuration: Duration(seconds: 45),
              dismissable: true,
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
              ],
            ),
          );
        }

        final houses = snapshot.data!;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Afficher le premier élément de la liste
                SizedBox(
                  child:
                  // "Bienvenue ${firstnameUser.toString()} 🤗",
                  FutureBuilder(
                    future: firstnameUser,

                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          "",
                          style: GoogleFonts.pacifico(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            // color: Colors.black,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Text("");
                      } else {
                        return Text(
                          "Bienvenue ${snapshot.data}",
                          style: GoogleFonts.pacifico(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            // color: Colors.black,
                          ),
                        );
                      }
                    },
                  ),
                ),

                SizedBox(height: 10),
                CardHouseSale(
                  house: houses.first, // Premier élément de la liste
                  index: 1,
                ),
                const SizedBox(height: 20),

                // Barre de recherche
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recherche rapide",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Dropdown pour la catégorie
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            items: const [
                              DropdownMenuItem(
                                value: "Appartement",
                                child: Text("Appartement"),
                              ),
                              DropdownMenuItem(
                                value: "Maison",
                                child: Text("Maison"),
                              ),
                              DropdownMenuItem(
                                value: "Studio",
                                child: Text("Studio"),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: "Catégorie",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Dropdown pour le nombre de pièces
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedRooms,
                            items: const [
                              DropdownMenuItem(
                                value: "1",
                                child: Text("1 pièce"),
                              ),
                              DropdownMenuItem(
                                value: "2",
                                child: Text("2 pièces"),
                              ),
                              DropdownMenuItem(
                                value: "3",
                                child: Text("3 pièces"),
                              ),
                              DropdownMenuItem(
                                value: "4+",
                                child: Text("4+ pièces"),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedRooms = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: "Pièces",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Champ pour le loyer minimum
                        Expanded(
                          child: TextFormField(
                            controller: _minRentController,
                            decoration: InputDecoration(
                              labelText: "Loyer min",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Champ pour le loyer maximum
                        Expanded(
                          child: TextFormField(
                            controller: _maxRentController,
                            decoration: InputDecoration(
                              labelText: "Loyer max",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),

                // const SizedBox(height: 20),
                // Bouton de recherche
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        // icon: Icon(Icons.search),
                        onPressed: () {
                          // Action pour effectuer la recherche
                          final category = _selectedCategory ?? "Toutes";
                          final rooms = _selectedRooms ?? "Toutes";
                          final minRent =
                              _minRentController.text.isNotEmpty
                                  ? int.tryParse(_minRentController.text)
                                  : null;
                          final maxRent =
                              _maxRentController.text.isNotEmpty
                                  ? int.tryParse(_maxRentController.text)
                                  : null;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ResultSearchPage(
                                    category: category,
                                    minPrice:
                                        minRent != null
                                            ? double.tryParse(
                                              minRent.toString(),
                                            )
                                            : null,
                                    maxPrice:
                                        maxRent != null
                                            ? double.tryParse(
                                              maxRent.toString(),
                                            )
                                            : null,
                                    nbrRooms: int.tryParse(rooms),
                                    // location: _selectedLocation,
                                  ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor:
                              Theme.of(context).colorScheme.inversePrimary,
                        ),
                        child: const Text(
                          "Rechercher",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    // Afficher un texte
                    TextButton(
                      onPressed:
                          () => NavigatorHelper.toSeeMore(context: context),
                      child: const Text("Voir plus"),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Liste horizontale des maisons
                SizedBox(
                  height: 200, // Fixer une hauteur pour éviter les conflits
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: houses.length > 4 ? 3 : houses.length - 1,
                    itemBuilder:
                        (context, index) => CardHouseSaleRow(
                          house:
                              houses[index + 1], // Exclure le premier élément
                          index: index + 2,
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
}
