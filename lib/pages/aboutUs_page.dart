import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AboutusPage extends StatelessWidget {
  const AboutusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "À propos de nous",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Gradient
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.home_work_rounded,
                        size: 80,
                        color: Colors.white,
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 10),
                      Text(
                        "DAIC Homes",
                        style: GoogleFonts.montserrat(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Notre Histoire"),
                  const SizedBox(height: 12),
                  _buildContentCard(
                    "Bienvenue sur DAIC Homes, une application innovante développée par DAIC Tech, dédiée à la recherche et à la location de biens immobiliers.\n\n"
                    "Elle vous offre une plateforme moderne, intuitive et facile à utiliser, conçue pour simplifier la connexion entre locataires et propriétaires.",
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

                  const SizedBox(height: 30),
                  _buildSectionTitle("Notre Mission"),
                  const SizedBox(height: 12),
                  _buildContentCard(
                    "Rendre la recherche immobilière plus simple, rapide et accessible. Nous nous engageons à fournir un service de qualité, basé sur la confiance, la transparence et l’innovation.",
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),

                  const SizedBox(height: 30),
                  _buildSectionTitle("Nos Valeurs"),
                  const SizedBox(height: 12),
                  _buildValuesList([
                    {"icon": Icons.accessibility_new, "label": "Accessibilité"},
                    {"icon": Icons.visibility, "label": "Transparence"},
                    {"icon": Icons.security, "label": "Confiance"},
                    {"icon": Icons.lightbulb, "label": "Innovation"},
                    {"icon": Icons.favorite, "label": "Engagement"},
                  ]).animate().fadeIn(delay: 600.ms).scale(),

                  const SizedBox(height: 40),
                  _buildSectionTitle("Rejoignez-nous"),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(FontAwesomeIcons.facebook, Colors.blue, 'https://www.facebook.com/profile.php?id=61575629320948'),
                      const SizedBox(width: 20),
                      _buildSocialButton(FontAwesomeIcons.whatsapp, Colors.green, 'https://whatsapp.com/channel/0029VbATmWDEQIalOVk21f0c'),
                      const SizedBox(width: 20),
                      _buildSocialButton(FontAwesomeIcons.linkedin, Colors.blue[800]!, 'https://www.linkedin.com/company/daic-tech/'),
                    ],
                  ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.5),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildContentCard(String content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        content,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: Colors.grey[800],
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildValuesList(List<Map<String, dynamic>> values) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: values.map((v) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(v['icon'], size: 18, color: Colors.green[800]),
            const SizedBox(width: 8),
            Text(v['label'], style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color, String url) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: FaIcon(icon, color: color, size: 28),
      ),
    );
  }
}
