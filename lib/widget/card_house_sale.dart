import 'package:daic_home/models/house.dart';
import 'package:daic_home/services/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CardHouseSale extends StatefulWidget {
  final House house;
  final int index;

  const CardHouseSale({super.key, required this.house, required this.index});

  @override
  State<CardHouseSale> createState() => _CardHouseSaleState();
}

class _CardHouseSaleState extends State<CardHouseSale> {
  String cleanUrl(String url) {
    return Uri.parse(url.trim()).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      // elevation: 4, // Ajoute une ombre pour un effet de profondeur
      // margin: const EdgeInsets.symmetric(
      //   horizontal: 16,
      //   vertical: 8,
      // ), // Marges autour de la carte
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Coins arrondis
      ),
      child: InkWell(
        onTap:
            () => NavigatorHelper.toDetails(
              context: context,
              house: widget.house,
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de la maison
            // Version optimisée pour les listes (performances)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl: cleanUrl(widget.house.link_home_images),
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                memCacheHeight: 300, // Optimise le cache mémoire
                memCacheWidth: 300,
                maxHeightDiskCache: 300, // Optimise le cache disque
                maxWidthDiskCache: 300,
                placeholder:
                    (context, url) => Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[200],
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(Icons.home, color: Colors.grey),
                    ),
              ),
            ),

            // Contenu de la carte
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prix et catégorie
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${widget.house.price} \$",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        widget.house.categorie,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Adresse
                  Text(
                    widget.house.adress,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),

                  // Informations supplémentaires (pièces, courant, eau)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.meeting_room,
                            size: 18,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${widget.house.nbr_pieces} pièces",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.electrical_services,
                            size: 18,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.house.courant,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.water_drop,
                            size: 18,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.house.eau,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
