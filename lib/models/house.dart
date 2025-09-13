import 'package:flutter/material.dart';

class House {
  String id;
  int price;
  int nbr_pieces;
  String adress;
  String description;
  String categorie;
  String courant;
  String datePubishing;
  String eau;
  String state;
  String link_home_images;
  List<AssetImage> other_images;

  House({
    required this.id,
    required this.price,
    required this.nbr_pieces,
    required this.link_home_images,
    required this.other_images,
    required this.courant,
    required this.eau,
    required this.adress,
    required this.description,
    required this.state,
    required this.categorie,
    required this.datePubishing,
  });
  // factory House.fromJson(Map<String, dynamic> json) {
  //   return House(
  //     id: json['id'],
  //     price: json['price'],
  //     nbr_pieces: json['nbr_pieces'],
  //     link_home_images: json['link_home_images'],
  //     other_images: List<String>.from(json['other_images'].map((x) => x)),
  //   );
  // }

  // methode pour convertir un JSON en un objet 'House'

  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      id: json['id'] ?? '',
      price: json['price'] ?? '',
      adress: json['adress'] ?? '',
      nbr_pieces: json['nbr_pieces'] ?? '',
      link_home_images: json['link_home_images'] ?? '',
      description: json['description'] ?? '',
      courant: json['courant'] ?? '',
      eau: json['eau'] ?? '',
      state: json['state'] ?? '',
      datePubishing: json['date_pubishing'] ?? '',
      categorie: json['categorie'] ?? '',
      other_images:
          (json['other_images'] as List<dynamic>)
              .map((image) => AssetImage(image as String))
              .toList(),
    );
  }
}
