import 'package:daic_home/models/house.dart';
import 'package:daic_home/widget/card_house_sale.dart';
import 'package:flutter/material.dart';

class ListHouses extends StatefulWidget {
  /// Liste des maisons à afficher
  /// [houses] : Liste des maisons à afficher
  final List<House> houses;

  const ListHouses({super.key, required this.houses});

  @override
  State<ListHouses> createState() => _ListHousesState();
}

class _ListHousesState extends State<ListHouses> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder:
          ((context, index) =>
              CardHouseSale(house: widget.houses[index], index: index + 1)),
      separatorBuilder:
          ((context, index) => const Divider(
            color: Colors.lightBlue,
            indent: 16,
            endIndent: 16,
          )),
      itemCount: widget.houses.length,
    );
  }
}
