import 'evPortsModel.dart';

class ChargerModel {
  final String chargerName;
  final String outputType;
  final String cpid;
  final String capacity;
  final String tariff;
  final String ocppStatus;
  final List<EvPortModel> evports;

  ChargerModel({
    required this.chargerName,
    required this.outputType,
    required this.cpid,
    required this.evports,
    required this.capacity,
    required this.tariff,
    required this.ocppStatus,
  });

  factory ChargerModel.fromJson(Map<String, dynamic> json) {
    return ChargerModel(
      chargerName: json['name'] ?? '',
      outputType: json['output_types'] ?? '',
      capacity: json['capacity'] != null ? json['capacity'].toString() : '0',
      ocppStatus: json['cpidStatus'] ?? '',
      cpid: json['CPID'] ?? '',
      tariff: json['charger_tariff'] != null
          ? json['charger_tariff'].toString()
          : '0',
      evports: json['connectors']
              .map<EvPortModel>((e) => EvPortModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  // Map<String, dynamic> toJson() => {
  //       "name": chargerName,
  //       "type": outputType,
  //       "capacity": capacity,
  //       "tariff": tariff,
  //       "ocppStatus": ocppStatus,
  //       "evports": evports.map((e) => e.toJson()).toList(),
  //     };
}
