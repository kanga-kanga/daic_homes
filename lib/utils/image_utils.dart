class ImageUtils {
  /// Nettoye une URL d'image pour corriger les erreurs de syntaxe (doubles slashs, espaces).
  /// Spécialement conçu pour les URLs Supabase Storage.
  static String cleanImageUrl(String url) {
    if (url.isEmpty) return '';
    
    // 1. On nettoie les espaces
    String cleaned = url.trim();
    
    // 2. On remplace les doubles slashs, sauf celui après le protocole (http:// ou https://)
    // On utilise un Regex qui cherche '//' non précédé par ':'
    final reg = RegExp(r'(?<!:)/{2,}');
    cleaned = cleaned.replaceAll(reg, '/');
    
    return cleaned;
  }

  /// Retourne une image par défaut (générique) en fonction de la catégorie
  static String getDefaultImageForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'maison':
      case 'maisons':
        return 'assets/images/maisons.png';
      case 'appartement':
      case 'appartements':
        return 'assets/images/appartement.png';
      case 'parcelle':
      case 'parcelles':
        return 'assets/images/parcelles.png';
      case 'locaux commerciaux':
      case 'local commercial':
      case 'commercial':
      case 'local':
        return 'assets/images/locaux_commerciaux.png';
      case 'concession':
      case 'concessions':
        return 'assets/images/concessions.png';
      case 'studio':
      case 'studios':
        return 'assets/images/studio.png';
      default:
        return 'assets/images/maisons.png';
    }
  }
}
