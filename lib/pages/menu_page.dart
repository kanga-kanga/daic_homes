import 'package:daic_home/services/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête du menu
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage("assets/images/logo2.jpg"),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Bienvenue !",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Accédez à vos options",
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Liste des options du menu
              _buildMenuOption(
                context,
                icon: Icons.edit,
                label: "Editer mon profil",
                onTap: () => NavigatorHelper.toEditPage(context: context),
              ),
              _buildMenuOption(
                context,
                icon: Icons.info_outline,
                label: "À propos de nous",
                onTap: () => NavigatorHelper.toAboutUs(context: context),
              ),
              _buildMenuOption(
                context,
                icon: Icons.contact_mail,
                label: "Contact",
                onTap: () => NavigatorHelper.toContactPage(context: context),
              ),
              _buildMenuOption(
                context,
                icon: Icons.help_outline,
                label: "Aide",
                onTap: () => NavigatorHelper.toHelpPage(context: context),
              ),

              _buildMenuOption(
                context,
                icon: Icons.star,
                label: "Noter l'application",
                onTap: () {
                  // Action pour noter l'application
                  // Vous pouvez utiliser un package comme 'url_launcher' pour ouvrir le Play Store ou l'App Store
                },
              ),
              _buildMenuOption(
                context,
                icon: Icons.share,
                label: "Partager l'application",
                onTap: () {
                  // Action pour partager l'application
                  // Vous pouvez utiliser un package comme 'share' pour partager l'application
                  const url =
                      'https://play.google.com/store/apps/details?id=com.daic_homes';
                  // Utilisez le package 'url_launcher' ou 'share' pour partager l'URL
                  Share.share(
                    'Découvrez l\'application Daic Homes ! Téléchargez-la ici : $url',
                    subject: 'Partage de l\'application Daic Homes',
                  );
                },
              ),
              FutureBuilder<String>(
                future: _getAppVersion(),
                builder: (context, snapshot) {
                  final version = snapshot.data ?? "Inconnue";
                  return _buildMenuOption(
                    context,
                    icon: Icons.info,
                    label: "Version de l'application",
                    onTap: () {
                      // Action pour afficher la version
                      showAboutDialog(
                        context: context,
                        applicationName: "Daic Homes",
                        applicationVersion: version,
                        applicationIcon: const Icon(Icons.home),
                        children: const [
                          Text("Merci d'utiliser notre application !"),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: Colors.grey[200],
      ),
    );
  }
}
