import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aide"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre principal
            const Text(
              "Besoin d'aide ?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Trouvez des réponses aux questions fréquentes ou contactez-nous pour plus d'assistance.",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            // Section FAQ
            const Text(
              "Questions fréquentes",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ExpansionTile(
              title: const Text("Comment puis-je créer un compte ?"),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Pour créer un compte, cliquez sur le bouton 'S'inscrire' sur la page d'accueil et remplissez le formulaire avec vos informations personnelles.",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text(
                "Comment puis-je rechercher un bien immobilier ?",
              ),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Utilisez la barre de recherche sur la page principale pour entrer vos critères, tels que le type de bien, le prix ou la localisation.",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text("Comment puis-je contacter un propriétaire ?"),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Une fois que vous avez trouvé un bien qui vous intéresse, cliquez sur le bouton 'Contacter' pour envoyer un message au propriétaire.",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text(
                "Comment puis-je modifier mes informations personnelles ?",
              ),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Accédez à la page 'Mon Profil', puis cliquez sur 'Modifier' pour mettre à jour vos informations personnelles.",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Section "Contactez-nous"
            const Text(
              "Contactez-nous",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          ],
        ),
      ),
    );
  }
}
