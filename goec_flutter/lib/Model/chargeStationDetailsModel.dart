import 'package:freelancer_app/Model/chargerModel.dart';
import 'package:freelancer_app/Model/stationMarkerModel.dart';

class ChargeStationDetailsModel {
  final String id;
  final String name;
  final String address;
  final double rating;
  final String image;
  final double latitude;
  final double longitude;
  final List amenities;
  final String startTime;
  final String stopTime;
  bool isFavorite;
  final List<ChargerModel> chargers;

  ChargeStationDetailsModel({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.amenities,
    required this.isFavorite,
    required this.chargers,
    required this.startTime,
    required this.stopTime,
  });

  /// Instant navigation payload from map / search list data.
  /// Connectors are empty until details API fills them in.
  factory ChargeStationDetailsModel.fromStationMarker(
    StationMarkerModel marker, {
    bool isFavorite = false,
  }) {
    return ChargeStationDetailsModel(
      id: marker.id,
      name: marker.name,
      address: marker.address,
      rating: marker.rating,
      image: marker.image,
      latitude: marker.latitude,
      longitude: marker.longitude,
      amenities: List.from(marker.amenities),
      startTime: marker.startTime,
      stopTime: marker.stopTime,
      isFavorite: isFavorite,
      chargers: const [],
    );
  }

  factory ChargeStationDetailsModel.fromJson(Map<String, dynamic> json) {
    return ChargeStationDetailsModel(
      id: json['_id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      rating: json['rating'] == null ? 0 : json['rating'].toDouble() ?? 0,
      image: json['image'] == ''
          ? 'https://sternbergclinic.com.au/wp-content/uploads/2020/03/placeholder.png'
          : json['image'] ??
              'https://sternbergclinic.com.au/wp-content/uploads/2020/03/placeholder.png',
      latitude: json['latitude'] == null ? 0 : json['latitude'].toDouble() ?? 0,
      longitude:
          json['longitude'] == null ? 0 : json['longitude'].toDouble() ?? 0,
      amenities: _parseAmenities(json['amenities']),
      startTime: json['startTime'] ?? '',
      stopTime: json['stopTime'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
      chargers: json['chargers']
              .map<ChargerModel>((e) => ChargerModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  static List _parseAmenities(dynamic value) {
    if (value == null || value == '') return [];
    if (value is List) {
      return value
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (value is String) {
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }
}
