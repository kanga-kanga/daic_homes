import 'package:daic_home/models/house.dart';
import 'package:daic_home/services/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CardHouseSaleRow extends StatefulWidget {
  final House house;
  final int index;

  const CardHouseSaleRow({super.key, required this.house, required this.index});

  @override
  State<CardHouseSaleRow> createState() => _CardHouseSaleRowState();
}

class _CardHouseSaleRowState extends State<CardHouseSaleRow> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6, // Largeur de chaque carte
      child: Card(
        // elevation: 4, // Ajoute une ombre pour un effet de profondeur
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
        ), // Espacement horizontal entre les cartes
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
              // Version avec imageBuilder pour des effets avancés
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: widget.house.link_home_images,
                    imageBuilder:
                        (context, imageProvider) => Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    placeholder:
                        (context, url) => Container(
                          height: 120,
                          width: double.infinity,
                          color: Colors.grey[200],
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          height: 120,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.home_work_outlined,
                            size: 32,
                            color: Colors.grey,
                          ),
                        ),
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
                            fontSize: 16,
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
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .fade, // Coupe le texte s'il est trop long
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
                              size: 16,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${widget.house.nbr_pieces} pièces",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.electrical_services,
                              size: 16,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.house.courant,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.water_drop,
                              size: 16,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.house.eau,
                              style: const TextStyle(
                                fontSize: 12,
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
      ),
    );
  }
}
