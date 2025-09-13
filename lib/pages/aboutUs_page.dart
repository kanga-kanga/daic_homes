import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutusPage extends StatelessWidget {
  const AboutusPage({super.key});

  get icon => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("À propos de nous"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section d'introduction
            const Text(
              "Bienvenue sur Daic Home",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Bienvenue sur DAIC Homes, une application innovante développée par DAIC Tech, dédiée à la recherche et à la location de biens immobiliers.\n\n"
              "Elle vous offre une plateforme moderne, intuitive et facile à utiliser, conçue pour simplifier la connexion entre locataires et propriétaires.\n\n"
              "Que vous cherchiez une maison ou un appartement, DAIC Homes vous accompagne pour trouver le logement idéal en toute sérénité.",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            // Section "Notre mission"
            const Text(
              "Notre mission",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Notre mission chez DAIC Tech, à travers DAIC Homes, est de rendre la recherche immobilière plus simple, rapide et accessible.\n"
              "En centralisant les offres locatives sur une seule plateforme, nous facilitons les échanges entre locataires et propriétaires. Nous nous engageons à fournir un service de qualité, basé sur la confiance, la transparence et l’innovation, pour répondre aux besoins réels de nos utilisateurs.",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            // Section "Notre mission"
            const SizedBox(height: 20),
            // Section "Nos Valeurs"
            const Text(
              "Nos valeurs",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Chez DAIC Tech, les fondations de DAIC Homes reposent sur des valeurs essentielles :\n\n"
              "\t\t - Accessibilité : une plateforme pensée pour tous, facile à utiliser.\n\n"
              "\t\t - Transparence : des informations claires pour des décisions éclairées.\n\n"
              "\t\t - Confiance : un environnement sécurisé pour toutes les parties.\n\n"
              "\t\t - Innovation : des solutions technologiques au service de la simplicité.\n\n"
              "\t\t - Engagement : une écoute active pour améliorer continuellement nos services.",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            // Section "Contactez-nous"
            const Text(
              "Contactez-nous",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(Icons.email, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  "daictech2024@gmail.com",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(Icons.phone, color: Colors.green),
                SizedBox(width: 10),
                Text(
                  "+243 972 149 794",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                // Icon(
                FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                SizedBox(width: 10),
                Text(
                  "+243 972 149 794",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 10),
                Text(
                  "Lubumbashi, Haut-Katanga, RDC",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Section "Suivez-nous"
            const Text(
              "Suivez-nous sur : ",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.facebook, color: Colors.blue),
                  onPressed: () async {
                    const url =
                        'https://www.facebook.com/profile.php?id=61575629320948'; // Remplacez par l'URL de votre page Facebook
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Impossible d\'ouvrir le lien $url';
                    }
                  },
                ),
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.green,
                  ),
                  onPressed: () async {
                    const url =
                        'https://whatsapp.com/channel/0029VbATmWDEQIalOVk21f0c'; // Remplacez par l'URL de votre page Facebook
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Impossible d\'ouvrir le lien $url';
                    }
                  },
                ),
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.linkedin,
                    color: Colors.blue,
                  ),
                  onPressed: () async {
                    const url =
                        'https://www.linkedin.com/company/daic-tech/'; // Remplacez par l'URL de votre page Facebook
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Impossible d\'ouvrir le lien $url';
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
