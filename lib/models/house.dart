class House {
  String id;
  int price;
  int? nbr_pieces;
  String adress;
  String description;
  String categorie;
  String? courant;
  String datePubishing;
  String? eau;
  String state; // e.g., location or vente
  String link_home_images;
  List<String> other_images;
  String? surface;
  String? is_cloture;

  // Global specific fields
  String? availability_status; // e.g., disponible, loué, vendu
  bool is_verified;
  String? published_by; // e.g., Agent, Propriétaire

  // Appartement specific
  String? etage; // e.g., Oui, Non, ou numéro d'étage

  // Parcelle specific
  String? dimension;

  // Concession specific
  int? nbr_buildings;
  bool? main_house;
  bool? outbuildings;

  // Local Commercial specific
  String? business_type; // e.g., boutique, bureau, restaurant...
  String? commercial_zone; // e.g., marché, centre-ville...
  String? visibility; // route principale oui/non (OUI / NON)

  House({
    required this.id,
    required this.price,
    this.nbr_pieces,
    required this.link_home_images,
    required this.other_images,
    this.courant,
    this.eau,
    required this.adress,
    required this.description,
    required this.state,
    required this.categorie,
    required this.datePubishing,
    this.surface,
    this.is_cloture,
    this.availability_status,
    this.is_verified = false,
    this.published_by,
    this.etage,
    this.dimension,
    this.nbr_buildings,
    this.main_house,
    this.outbuildings,
    this.business_type,
    this.commercial_zone,
    this.visibility,
  });

  bool get isMaison => categorie.toLowerCase() == 'maison';
  bool get isAppartement => categorie.toLowerCase() == 'appartement';
  bool get isLand => categorie.toLowerCase() == 'parcelle';
  bool get isConcession => categorie.toLowerCase() == 'concession';
  bool get isLocalCommercial => ['local commercial', 'local', 'commercial'].contains(categorie.toLowerCase());

  bool get isForRent => state.toLowerCase().contains('louer') || state.toLowerCase().contains('location');
  bool get isForSale => state.toLowerCase().contains('vendre') || state.toLowerCase().contains('vente');

  factory House.fromJson(Map<String, dynamic> json) {
    String normalize(dynamic value) {
      if (value == null) return 'NON';
      final s = value.toString().toUpperCase();
      if (s == 'OUI' || s == 'TRUE' || s == '1') return 'OUI';
      return 'NON';
    }

    return House(
      id: json['id']?.toString() ?? '',
      price: json['price'] is int ? json['price'] : int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      adress: json['adress'] ?? '',
      nbr_pieces: json['nbr_pieces'] is int ? json['nbr_pieces'] : int.tryParse(json['nbr_pieces']?.toString() ?? '0'),
      link_home_images: json['link_home_images'] ?? '',
      description: json['description'] ?? '',
      courant: normalize(json['courant']),
      eau: normalize(json['eau']),
      state: json['state'] ?? '',
      datePubishing: json['date_pubishing'] ?? '',
      categorie: json['categorie'] ?? '',
      surface: json['surface']?.toString(),
      is_cloture: normalize(json['is_cloture']),
      availability_status: json['availability_status']?.toString(),
      is_verified: json['is_verified'] == true || json['is_verified'] == 'true' || json['is_verified'] == 1,
      published_by: json['published_by']?.toString(),
      etage: json['etage']?.toString(),
      dimension: json['dimension']?.toString(),
      nbr_buildings: json['nbr_buildings'] is int ? json['nbr_buildings'] : int.tryParse(json['nbr_buildings']?.toString() ?? '0'),
      main_house: json['main_house'] == true || json['main_house'] == 'true' || json['main_house'] == 'OUI' || json['main_house'] == 1,
      outbuildings: json['outbuildings'] == true || json['outbuildings'] == 'true' || json['outbuildings'] == 'OUI' || json['outbuildings'] == 1,
      business_type: json['business_type']?.toString(),
      commercial_zone: json['commercial_zone']?.toString(),
      visibility: normalize(json['visibility']),
      other_images: (json['other_images'] as List<dynamic>?)
              ?.map((image) => image.toString())
              .toList() ??
          [],
    );
  }
}
