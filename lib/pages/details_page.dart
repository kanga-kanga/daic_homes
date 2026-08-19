import 'package:daic_home/services/auth_service.dart';
import 'package:daic_home/utils/price_formatter.dart';
import 'package:daic_home/utils/image_utils.dart';

import 'package:flutter/material.dart';
import 'package:daic_home/models/house.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:daic_home/widget/elegant_snackbar.dart';
import 'package:daic_home/widget/full_screen_image_viewer.dart';

class DetailsPage extends StatefulWidget {
  final House house;

  const DetailsPage({super.key, required this.house});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final AuthService _authService = AuthService();
  bool _isFavorite = false;

  void _callNumber(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Impossible d\'ouvrir l\'application téléphone';
    }
  }

  void _openWhatsApp(
    String phoneNumber,
    String message,
    String house_id,
  ) async {
    final String formattedNumber = phoneNumber.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final String encodedMessage = Uri.encodeComponent(("$message $house_id"));
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$formattedNumber?text=$encodedMessage',
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      throw 'Impossible d\'ouvrir WhatsApp';
    }
  }

  String cleanUrl(String url) {
    return ImageUtils.cleanImageUrl(url);
  }


  // void _toggleFavorite() {
  //   setState(() {
  //     _isFavorite = !_isFavorite;
  //   });
  // }
  Future<void> _toggleFavorite() async {
    try {
      if (_isFavorite) {
        await _authService.removeFavorite(widget.house.id.toString());
      } else {
        await _authService.addFavorite(widget.house.id.toString());
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      ElegantSnackBar.show(
        context,
        message: "Connexion internet instable ou indisponible 😓",
        isError: true,
      );
    }
  }

  Future<void> _checkIfFavorite() async {
    try {
      final isFav = await _authService.isFavorite(widget.house.id.toString());
      setState(() {
        _isFavorite = isFav;
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            stretch: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.3),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.3),
                  child: IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'gallery-image-0',
                    child: GestureDetector(
                      onTap: () {
                        // On n'ouvre la galerie que si on a au moins une image (ou l'image par defaut)
                        final imageUrl = widget.house.link_home_images.isNotEmpty
                            ? ImageUtils.cleanImageUrl(widget.house.link_home_images)
                            : ImageUtils.getDefaultImageForCategory(widget.house.categorie);
                            
                        final cleanedOthers = widget.house.other_images
                            .map((e) => ImageUtils.cleanImageUrl(e))
                            .where((e) => e.isNotEmpty)
                            .toList();
                        
                        final allImages = [
                          imageUrl,
                          ...cleanedOthers,
                        ];

                        if (allImages.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImageViewer(
                                images: allImages,
                                initialIndex: 0,
                              ),
                            ),
                          );
                        }
                      },
                      child: widget.house.link_home_images.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: ImageUtils.cleanImageUrl(widget.house.link_home_images),
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey[200]),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: Icon(Icons.broken_image_rounded, color: Colors.grey[400], size: 64),
                              ),
                            )
                          : Image.asset(
                              ImageUtils.getDefaultImageForCategory(widget.house.categorie),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.house.categorie,
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${widget.house.categorie} à ${widget.house.state}",
                                style: GoogleFonts.montserrat(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "${PriceFormatter.format(widget.house.price)} \$${widget.house.isForRent ? '/mois' : ''}",
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 18, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.house.adress,
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureGrid(),
                    const SizedBox(height: 32),
                    Text(
                      "Description",
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.house.description,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (widget.house.other_images.isNotEmpty) ...[
                      Text(
                        "Galerie",
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: widget.house.other_images.length,
                          itemBuilder: (context, index) {
                            final galleryIndex = index + 1;
                            return GestureDetector(
                              onTap: () {
                                final imageUrl = widget.house.link_home_images.isNotEmpty
                                    ? ImageUtils.cleanImageUrl(widget.house.link_home_images)
                                    : ImageUtils.getDefaultImageForCategory(widget.house.categorie);
                                    
                                final cleanedOthers = widget.house.other_images
                                    .map((e) => ImageUtils.cleanImageUrl(e))
                                    .where((e) => e.isNotEmpty)
                                    .toList();
                                
                                final allImages = [
                                  imageUrl,
                                  ...cleanedOthers,
                                ];

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenImageViewer(
                                      images: allImages,
                                      initialIndex: index + 1,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: ImageUtils.cleanImageUrl(widget.house.other_images[index]).startsWith('http')
                                        ? CachedNetworkImageProvider(ImageUtils.cleanImageUrl(widget.house.other_images[index])) as ImageProvider
                                        : AssetImage(ImageUtils.cleanImageUrl(widget.house.other_images[index])),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Hero(
                                  tag: 'gallery-image-$galleryIndex',
                                  child: Container(), // Empty child for Hero tag
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _openWhatsApp(
                  '243972149794',
                  'Bonjour !🤗 \nJe suis intéressé par la maison id : ',
                  widget.house.id,
                ),
                icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 20),
                label: const Text("WhatsApp"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _callNumber('+243972149794'),
                icon: const Icon(Icons.phone_rounded, size: 20),
                label: const Text("Appeler"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    List<Widget> features = [];

    if (widget.house.isMaison) {
      features = [
        _buildFeatureItem(Icons.meeting_room_rounded, "${widget.house.nbr_pieces ?? 0} Pièces"),
        _buildFeatureItem(Icons.bolt_rounded, widget.house.courant == "OUI" ? "Oui" : "Non"),
        _buildFeatureItem(Icons.water_drop_rounded, widget.house.eau == "OUI" ? "Oui" : "Non"),
      ];
    } else if (widget.house.isAppartement) {
      features = [
        _buildFeatureItem(Icons.meeting_room_rounded, "${widget.house.nbr_pieces ?? 0} Pièces"),
        if (widget.house.etage != null && widget.house.etage!.isNotEmpty && widget.house.etage != "NON")
          _buildFeatureItem(Icons.stairs_rounded, "Étage"),
        _buildFeatureItem(Icons.bolt_rounded, widget.house.courant == "OUI" ? "Oui" : "Non"),
        _buildFeatureItem(Icons.water_drop_rounded, widget.house.eau == "OUI" ? "Oui" : "Non"),
      ];
    } else if (widget.house.isLand) {
      features = [
        if (widget.house.surface != null && widget.house.surface!.isNotEmpty)
          _buildFeatureItem(Icons.square_foot_rounded, widget.house.surface!),
        if (widget.house.dimension != null && widget.house.dimension!.isNotEmpty)
          _buildFeatureItem(Icons.straighten_rounded, widget.house.dimension!),
        if (widget.house.is_cloture != null)
          _buildFeatureItem(Icons.fence_rounded, widget.house.is_cloture == "OUI" ? "Clôturée" : "Non clôturée"),
      ];
    } else if (widget.house.isConcession) {
      features = [
        if (widget.house.surface != null && widget.house.surface!.isNotEmpty)
          _buildFeatureItem(Icons.square_foot_rounded, "Tot: ${widget.house.surface}"),
        if (widget.house.nbr_buildings != null && widget.house.nbr_buildings! > 0)
          _buildFeatureItem(Icons.domain_rounded, "${widget.house.nbr_buildings} Bât."),
        if (widget.house.main_house != null && widget.house.main_house == "OUI")
          _buildFeatureItem(Icons.home_rounded, "Maison Princ."),
        _buildFeatureItem(Icons.bolt_rounded, widget.house.courant == "OUI" ? "Oui" : "Non"),
      ];
    } else if (widget.house.isLocalCommercial) {
      features = [
        if (widget.house.surface != null && widget.house.surface!.isNotEmpty)
          _buildFeatureItem(Icons.square_foot_rounded, widget.house.surface!),
        if (widget.house.business_type != null && widget.house.business_type!.isNotEmpty)
          _buildFeatureItem(Icons.storefront_rounded, widget.house.business_type!),
        if (widget.house.commercial_zone != null && widget.house.commercial_zone!.isNotEmpty)
          _buildFeatureItem(Icons.location_city_rounded, widget.house.commercial_zone!),
        if (widget.house.visibility != null)
          _buildFeatureItem(Icons.visibility_rounded, widget.house.visibility == "OUI" ? "Bonne Visibilité" : "Peu Visible"),
        _buildFeatureItem(Icons.bolt_rounded, widget.house.courant == "OUI" ? "Oui" : "Non"),
        _buildFeatureItem(Icons.water_drop_rounded, widget.house.eau == "OUI" ? "Oui" : "Non"),
      ];
    } else {
      features = [
        _buildFeatureItem(Icons.meeting_room_rounded, "${widget.house.nbr_pieces ?? 0} Pièces"),
        _buildFeatureItem(Icons.bolt_rounded, widget.house.courant == "OUI" ? "Oui" : "Non"),
        _buildFeatureItem(Icons.water_drop_rounded, widget.house.eau == "OUI" ? "Oui" : "Non"),
      ];
    }

    return Wrap(
      spacing: 12,
      runSpacing: 16,
      alignment: WrapAlignment.start,
      children: features,
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
