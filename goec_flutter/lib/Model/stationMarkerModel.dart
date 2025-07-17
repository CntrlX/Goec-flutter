class StationMarkerModel {
  final String id;
  final String name;
  final String image;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final List amenities;
  final String startTime;
  final String stopTime;
  final String charger_status;
  final String ac_dc;
  final List charger_type;
  final String charger_capacity;

  StationMarkerModel({
    required this.id,
    required this.name,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.address,
    required this.amenities,
    required this.charger_status,
    required this.startTime,
    required this.stopTime,
    required this.ac_dc,
    required this.charger_type,
    required this.charger_capacity,
  });

  factory StationMarkerModel.fromJson(Map<String, dynamic> json) {
    return StationMarkerModel(
      id: json['_id'],
      latitude: json['latitude'] == null ? 0 : json['latitude'].toDouble() ?? 0,
      image: json['image'] == ''
          ? 'https://sternbergclinic.com.au/wp-content/uploads/2020/03/placeholder.png'
          : json['image'] ??
              'https://sternbergclinic.com.au/wp-content/uploads/2020/03/placeholder.png',
      longitude:
          json['longitude'] == null ? 0 : json['longitude'].toDouble() ?? 0,
      rating: json['rating'] == null ? 0 : json['rating'].toDouble() ?? 0,
      amenities: json['amenities'] ?? [],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      startTime: json['startTime'] ?? '',
      stopTime: json['stopTime'] ?? '',
      charger_status: json['charger_status'] ?? '',
      ac_dc: json['outputType'] ?? '',
      charger_type: json['connectorType'] ?? [],
      charger_capacity: json['capacity'] ?? '',
    );
  }
}
