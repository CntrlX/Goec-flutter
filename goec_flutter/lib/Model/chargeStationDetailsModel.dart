import 'package:freelancer_app/Model/chargerModel.dart';

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
      amenities: json['amenities'] == '' ? [] : json['amenities'] ?? [],
      startTime: json['startTime'] ?? '',
      stopTime: json['stopTime'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
      chargers: json['chargers']
              .map<ChargerModel>((e) => ChargerModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
