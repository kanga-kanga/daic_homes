import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactusPage extends StatefulWidget {
  const ContactusPage({super.key});

  @override
  State<ContactusPage> createState() => _ContactusPageState();
}

class _ContactusPageState extends State<ContactusPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  void sendEmailEncoded({
    required String to,
    String? subject,
    String? body,
    List<String>? cc,
    List<String>? bcc,
  }) async {
    String query = '';
    if (subject != null) query += 'subject=${Uri.encodeComponent(subject)}';
    if (body != null) query += '&body=${Uri.encodeComponent(body)}';
    if (cc != null && cc.isNotEmpty) {
      query += '&cc=${Uri.encodeComponent(cc.join(','))}';
    }
    if (bcc != null && bcc.isNotEmpty) {
      query += '&bcc=${Uri.encodeComponent(bcc.join(','))}';
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: to,
      query: query.isNotEmpty ? query : null,
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Impossible d\'ouvrir le client email';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nous Contacter"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section d'introduction
            const Text(
              "Contactez-nous",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Si vous avez des questions ou des préoccupations, n'hésitez pas à nous contacter en utilisant le formulaire ci-dessous.",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            // Formulaire de contact
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Champ pour le nom
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Nom",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer votre nom";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Champ pour l'email
                  TextFormField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      labelText: "Sujet",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer l'objet de votre requette";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Champ pour le message
                  TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: "Message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.message),
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer votre message";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  // Bouton d'envoi
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Action pour envoyer le message
                          sendEmailEncoded(
                            to: "daichomes2024@gmail.com",
                            subject: _subjectController.text,
                            body: _messageController.text,
                          );
                          _nameController.clear();
                          _subjectController.clear();
                          _messageController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor:
                            Theme.of(context).colorScheme.inversePrimary,
                      ),
                      child: const Text(
                        "Envoyer",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Section d'informations de contact
            const Text(
              "Informations de contact",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(Icons.email, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  "daichomes2024@gmail.com",
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
          ],
        ),
      ),
    );
  }
}
