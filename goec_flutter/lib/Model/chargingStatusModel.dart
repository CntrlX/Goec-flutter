class ChargingStatusModel {
  double amount;
  int percentage;
  double unitUsed;
  final double balance;
  String status;
  double capacity;
  String outputType;
  String connectorType;
  // final int tran_id;
  // final int connector;
  // double taxamount;

  ChargingStatusModel({
    // required this.tran_id,
    // required this.connector,
    required this.amount,
    required this.percentage,
    required this.unitUsed,
    required this.status,
    // required this.taxamount,
    required this.capacity,
    required this.outputType,
    required this.connectorType,
    required this.balance,
  });
  factory ChargingStatusModel.fromJson(Map<String, dynamic> json) {
    return ChargingStatusModel(
      // tran_id: json['tran_id'] ?? -1,
      // connector: json['Connector'] ?? -1,
      amount: json['amount'] ?? 0,
      percentage: (double.tryParse(json['percentage'] ?? '0') ?? 0).toInt(),
      unitUsed: json['unitUsed'].toDouble() ?? 0.0,
      status: json['status'] ?? '',
      // taxamount: json['taxamount'] ?? 0,
      capacity: json['capacity'] != null ? json['capacity'].toDouble() : 0,
      outputType: json['outputType'] ?? '',
      connectorType: json['connectorType'] ?? '',
      balance: json['balance'].toDouble() ?? 0,
    );
  }
  // Map<String, dynamic> toJson() => {
  //       "tran_id": tran_id,
  //       "Connector": connector,
  //       "amount": amount,
  //       "SOC": soc,
  //       // "Duration": Duration,
  //       // "PriceBy": "PriceBy",
  //       "unit": unit,
  //       // "load": load,
  //       // "price": price,
  //       // "startTime": startTime,
  //       // "lastupdated": lastupdated,
  //       // "Charger": Charger,
  //       "status": status,
  //       // "Chargingstatus": Chargingstatus,
  //       // "tariff": tariff,
  //       "taxamount": taxamount,
  //       "Capacity": capacity,
  //       "OutputType": outputType,
  //       "ConnectorType": connectorType,
  //       "balance": balance,
  //     };
}
