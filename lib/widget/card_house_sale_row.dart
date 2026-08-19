import 'package:daic_home/models/house.dart';
import 'package:daic_home/services/navigation_helper.dart';
import 'package:daic_home/utils/price_formatter.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap:
              () => NavigatorHelper.toDetails(
                context: context,
                house: widget.house,
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: 'house-row-${widget.house.id}-${widget.index}',
                    child: CachedNetworkImage(
                      imageUrl: widget.house.link_home_images,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) =>
                              Container(height: 120, color: Colors.grey[200]),
                      errorWidget:
                          (context, url, error) => Container(
                            height: 120,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.home_work_rounded,
                              color: Colors.grey,
                            ),
                          ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${PriceFormatter.format(widget.house.price)} \$${widget.house.isForRent ? '/mois' : ''}",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.house.adress,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSmallInfo(
                          Icons.meeting_room_rounded,
                          "${widget.house.nbr_pieces} Ch.",
                        ),
                        _buildSmallInfo(
                          Icons.bolt_rounded,
                          widget.house.courant == "OUI" ? "Oui" : "Non",
                        ),
                        _buildSmallInfo(
                          Icons.water_drop_rounded,
                          widget.house.eau == "OUI" ? "Oui" : "Non",
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

  Widget _buildSmallInfo(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
