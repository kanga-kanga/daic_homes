import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoadingCard extends StatelessWidget {
  const ShimmerLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder pour l'image
            Container(
              width: MediaQuery.of(context).size.width,
              height: 150,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            // Placeholder pour le texte
            Container(
              width: MediaQuery.of(context).size.width * .7,
              height: 16,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Container(
              width: MediaQuery.of(context).size.width * .5,
              height: 16,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
