// // Created by: Heritier KANGA-KANGA

import 'package:daic_home/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:daic_home/models/house.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:motion_toast/motion_toast.dart';

class DetailsPage extends StatefulWidget {
  final House house;

  const DetailsPage({super.key, required this.house});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final AuthService _authService = AuthService();
  int _index = 0;
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
    return Uri.parse(url.trim()).toString();
  }

  void _updateIndex(AssetImage file) {
    setState(() {
      _index = widget.house.other_images.indexOf(file);
    });
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
      MotionToast.error(
        title: const Text('Erreur de connexion'),
        description: Text("Connexion internet instable ou indisponible 😓"),
        animationType: AnimationType.slideInFromBottom,
      ).show(context);
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
    // Color themeColor = Theme.of(context).colorScheme.inversePrimary;
    Color primaryColor =
        Theme.of(
          context,
        ).colorScheme.inversePrimary; // Couleur principale du nouveau design

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Image de fond
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image:
                            (widget.house.other_images.isNotEmpty &&
                                    widget.house.other_images.length > _index)
                                ? NetworkImage(
                                  cleanUrl(
                                    widget.house.other_images[_index].assetName,
                                  ),
                                )
                                : const AssetImage('assets/images/profile.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Stack(

              //   children: [
              //     // Image de fond
              //     Container(
              //       width: double.infinity,
              //       decoration: BoxDecoration(
              //         image: DecorationImage(
              //           image:
              //               (widget.house.other_images.isNotEmpty &&
              //                       widget.house.other_images.length > _index)
              //                   ? NetworkImage(
              //                     cleanUrl(
              //                       widget.house.other_images[_index].assetName,
              //                     ),
              //                   )
              //                   : const AssetImage('assets/images/profile.jpg'),
              //           fit: BoxFit.cover,
              //         ),
              //       ),
              //       child: Container(
              //         decoration: BoxDecoration(
              //           gradient: LinearGradient(
              //             colors: [
              //               Colors.black.withOpacity(0.6),
              //               Colors.transparent,
              //             ],
              //             begin: Alignment.bottomCenter,
              //             end: Alignment.topCenter,
              //           ),
              //         ),
              //       ),
              //     ),
              //
              //     // Bouton favori
              //     Positioned(
              //       top: 20,
              //       right: 10,
              //       child: CircleAvatar(
              //         backgroundColor: Colors.black.withOpacity(0.4),
              //         child: IconButton(
              //           icon: Icon(
              //             _isFavorite ? Icons.favorite : Icons.favorite_border,
              //             color: _isFavorite ? Colors.red : Colors.white,
              //           ),
              //           onPressed: _toggleFavorite,
              //         ),
              //       ),
              //     ),
              //   ],

              // ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.black.withOpacity(0.4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ),
              ),
            ],
            backgroundColor: Colors.transparent,
            pinned: true,
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Titre et prix
                Text(
                  "${widget.house.categorie} à ${widget.house.state}",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "${widget.house.price.toString()} \$",
                  style: TextStyle(
                    fontSize: 20,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                // Localisation
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      widget.house.adress,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Galerie d'images
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        widget.house.other_images.map((img) {
                          return InkWell(
                            onTap: () => _updateIndex(img),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: NetworkImage(img.assetName),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
                SizedBox(height: 24),

                // Description
                Text(
                  "Description",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  widget.house.description,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                SizedBox(height: 24),

                // Détails
                Text(
                  "Détails",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildDetailRow("Pièces", widget.house.nbr_pieces.toString()),
                _buildDetailRow("Électricité", widget.house.courant),
                _buildDetailRow("Eau", widget.house.eau),
                SizedBox(height: 24),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            () => _openWhatsApp(
                              '243970346890',
                              'Bonjour !🤗 \nJe suis interesser par la maison \n portant l\'id : ',
                              widget.house.id,
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            48,
                            65,
                            71,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.whatsapp,
                              color: Colors.white,
                            ),
                            SizedBox(width: 15),
                            Text(
                              "Contacter",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _callNumber('+243970346890'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(FontAwesomeIcons.phone, color: Colors.white),
                            SizedBox(width: 15),
                            Text(
                              "Appeler",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
