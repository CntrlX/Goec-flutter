import 'package:freelancer_app/Model/vehicleModel.dart';
import 'package:freelancer_app/constants.dart';

class UserModel {
  String username;
  final String id;
  final String name;
  final String userId;
  final String image;
  final String email;
  final List rfidTag;
  final int total_sessions;
  final double total_units;
  double balanceAmount;
  final VehicleModel defaultVehicle;

  UserModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.email,
    required this.image,
    required this.name,
    required this.total_sessions,
    required this.total_units,
    required this.rfidTag,
    required this.balanceAmount,
    required this.defaultVehicle,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      username: json['username'],
      userId: json['userId'],
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      email: json['email'] ?? '',
      rfidTag: json['rfidTag'] ?? [],
      total_sessions: json['total_sessions'] ?? 0,
      total_units: json['total_units'].toDouble() ?? 0,
      balanceAmount: json['wallet'].toDouble() ?? 0,
      defaultVehicle: json['defaultVehicle'] != null
          ? VehicleModel.fromjson(json['defaultVehicle'])
          : kVehicleModel,
    );
  }

  // Map<String, dynamic> toJson() => {
  //       "userId": userId,
  //       "username": username,
  //       "name": name,
  //       "image": image,
  //       // "phone": phone,
  //       "email": email,
  //       "rfid": rfid,
  //       // "status": status,
  //       "total_sessions": total_sessions,
  //       "total_units": total_units,
  //       "wallet": balanceAmount,
  //       "defaultVehicle": defaultVehicle,
  //     };
}
