class PriceFormatter {
  /// Formate un nombre en ajoutant des espaces comme séparateurs de milliers.
  /// Exemple: 10000 -> 10 000
  static String format(num price) {
    // Utilisation d'une expression régulière pour insérer un espace tous les 3 chiffres
    final String priceStr = price.toString();
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return priceStr.replaceAllMapped(reg, (Match m) => '${m[1]} ');
  }
}
