import 'package:daic_home/models/house.dart';
import 'package:daic_home/services/navigation_helper.dart';
import 'package:daic_home/utils/price_formatter.dart';
import 'package:daic_home/utils/image_utils.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

class CardHouseSale extends StatefulWidget {
  final House house;
  final int index;
  final String heroPrefix;

  const CardHouseSale({
    super.key,
    required this.house,
    required this.index,
    this.heroPrefix = '',
  });

  @override
  State<CardHouseSale> createState() => _CardHouseSaleState();
}

class _CardHouseSaleState extends State<CardHouseSale> {
  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.house.link_home_images.isNotEmpty
        ? ImageUtils.cleanImageUrl(widget.house.link_home_images)
        : ImageUtils.getDefaultImageForCategory(widget.house.categorie);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Reduced from 24
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => NavigatorHelper.toDetails(
          context: context,
          house: widget.house,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: '${widget.heroPrefix}house-${widget.house.id}-${widget.index}',
                  child: imageUrl.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        height: 90, // Match the height for Compact mode
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 90,
                          color: Colors.grey[200],
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 90,
                          color: Colors.grey[200],
                          child: const Icon(Icons.home_work_rounded, color: Colors.grey, size: 24),
                        ),
                      )
                    : Image.asset(
                        imageUrl,
                        height: 90,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.house.categorie,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, color: Colors.white, size: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(6.0), // Reduced from 12
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "${PriceFormatter.format(widget.house.price)} \$${widget.house.isForRent ? '/mois' : ''}",
                          style: GoogleFonts.montserrat(
                            fontSize: 14, // Reduced from 16
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            "4.8",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.house.adress,
                    style: GoogleFonts.poppins(
                      fontSize: 10, // Reduced from 12
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4), // Reduced from 12
                  // Info Icons Row - Using Wrap to prevent overflow
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: widget.house.isLand 
                      ? [
                          _buildInfoItem(Icons.square_foot_rounded, widget.house.surface ?? "N/A"),
                          _buildInfoItem(Icons.fence_rounded, widget.house.is_cloture == "OUI" ? "Oui" : "Non"),
                        ]
                      : [
                          _buildInfoItem(Icons.meeting_room_rounded, "${widget.house.nbr_pieces ?? 0}"),
                          _buildInfoItem(Icons.bolt_rounded, widget.house.courant == "OUI" ? "Oui" : "Non"),
                          _buildInfoItem(Icons.water_drop_rounded, widget.house.eau == "OUI" ? "Oui" : "Non"),
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

  Widget _buildInfoItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]), // Reduced from 16
        const SizedBox(width: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10, // Reduced from 12
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
