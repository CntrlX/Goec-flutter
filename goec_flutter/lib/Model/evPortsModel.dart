class EvPortModel {
  final int connectorId;
  final String ocppStatus;
  final String connectorType;
  final String currentSoc;
  EvPortModel({
    required this.connectorId,
    required this.ocppStatus,
    required this.connectorType,
    required this.currentSoc,
  });

  factory EvPortModel.fromJson(Map<String, dynamic> json) {
    return EvPortModel(
      connectorId: json['connectorId'],
      ocppStatus: json['status'] ?? '',
      connectorType: json['connectorType'] ?? '',
      currentSoc: json['currentSoc'] ?? '',
    );
  }

  // Map<String, dynamic> toJson() => {
  //       "seqNumber": connectorId,
  //       "ocppStatus": ocppStatus,
  //       "connectorType": connectorType,
  //     };
}
