class ActiveSessionModel {
  final String transactionId;
  final String chargerName;
  final String outputType;
  final String connectorType;
  final String connectorId;
  final String startTime;
  final String cpid;
  final double tariff;
  final double unitUsed;
  final double capacity;
  final String chargingStationId;
  final int currentSoc;

  ActiveSessionModel({
    required this.transactionId,
    required this.chargerName,
    required this.outputType,
    required this.connectorType,
    required this.startTime,
    required this.connectorId,
    required this.cpid,
    required this.tariff,
    required this.unitUsed,
    required this.capacity,
    required this.chargingStationId,
    required this.currentSoc,
  });
  factory ActiveSessionModel.fromJson(Map<String, dynamic> json) {
    return ActiveSessionModel(
      transactionId: json['transactionId'] == null
          ? '-1'
          : json['transactionId'].toString(),
      chargerName: json['chargerName'] ?? '',
      startTime: json['startTime'] ?? '',
      outputType: json['outputType'] ?? '',
      connectorType: json['connectorType'] ?? '',
      connectorId:
          json['connectorId'] == null ? '' : json['connectorId'].toString(),
      cpid: json['cpid'] ?? '',
      tariff: json['tariff'] != null
          ? double.tryParse(json['tariff'].toString()) ?? 0
          : 0,
      unitUsed: json['unitUsed'] != null ? json['unitUsed'].toDouble() : 0,
      capacity: double.tryParse(json['capacity']) ?? 0,
      chargingStationId: json['chargingStationId'] ?? '',
      currentSoc: json['currentSoc'] != null ? json['currentSoc'].toInt() : 0,
    );
  }
}
