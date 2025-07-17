class SearchStationrModel {
  final String id;
  final String chargestation_name;
  final String location_name;
  final double latitude;
  final double longitude;

  SearchStationrModel({
    required this.id,
    required this.chargestation_name,
    required this.location_name,
    required this.latitude,
    required this.longitude,
  });

  factory SearchStationrModel.fromJson(Map<String, dynamic> json) {
    return SearchStationrModel(
      id: json['_id'],
      chargestation_name: json['name'] ?? '',
      location_name: json['address'] ?? '',
      latitude: json['latitude'] == null ? 0 : json['latitude'].toDouble() ?? 0,
      longitude:
          json['longitude'] == null ? 0 : json['longitude'].toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "chargstation_name": chargestation_name,
        "location_name": location_name,
        "latitude": latitude,
        "longitude": longitude
      };
}
