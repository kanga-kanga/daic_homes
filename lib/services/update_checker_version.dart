import 'package:daic_home/services/auth_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateCheckerVersion {
  final AuthService _versionService = AuthService();

  Future<void> checkForUpdate(BuildContext context) async {
    // Obtenez la version actuelle de l'application
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    // Récupérez la dernière version depuis Supabase
    final latestVersion = await _versionService.getLatestVersion(
      'android',
    ); // Changez en 'ios' si nécessaire
    if (latestVersion != null &&
        _isNewVersionAvailable(currentVersion, latestVersion)) {
      _showUpdateDialog(context, latestVersion);
    }
  }

  bool _isNewVersionAvailable(String currentVersion, String latestVersion) {
    final current = currentVersion.split('.').map(int.parse).toList();
    final latest = latestVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < latest.length; i++) {
      if (i >= current.length || latest[i] > current[i]) {
        return true;
      } else if (latest[i] < current[i]) {
        return false;
      }
    }
    return false;
  }

  void _showUpdateDialog(BuildContext context, String latestVersion) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Mise à jour disponible'),
            content: Text(
              'Une nouvelle version ($latestVersion) de l\'application est disponible. Veuillez mettre à jour Afin de profiter des dernières fonctionnalités.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Plus tard'),
              ),
              ElevatedButton(
                onPressed: () async {
                  const appStoreUrl = 'https://play.google.com/store';
                  if (await canLaunch(appStoreUrl)) {
                    await launch(appStoreUrl);
                  }
                },
                child: const Text('Mettre à jour'),
              ),
            ],
          ),
    );
  }
}
