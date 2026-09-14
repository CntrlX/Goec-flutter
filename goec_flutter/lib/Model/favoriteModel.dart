class FavoriteModel {
  final String id;
  final String rating;
  final String name;
  final String address;
  final String image;
  final double latitude;
  final double longitude;
  FavoriteModel({
    required this.id,
    required this.rating,
    required this.name,
    this.address = '',
    required this.image,
    required this.latitude,
    required this.longitude,
  });
  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] ?? '-1',
      rating: json['rating']?.toString() ?? '0',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      image: json['image'] != null && json['image'].toString().isNotEmpty
          ? json['image']
          : 'https://sternbergclinic.com.au/wp-content/uploads/2020/03/placeholder.png',
      latitude: json['latitude'] == null ? 0 : json['latitude'].toDouble() ?? 0,
      longitude:
          json['longitude'] == null ? 0 : json['longitude'].toDouble() ?? 0,
    );
  }
  Map<String, dynamic> toJson() => {
        "id": id,
        "rating": rating,
        "name": name,
        "address": address,
        "image": image,
        "latitude": latitude,
        "longitude": longitude
      };
}
