class ChargeTransactionModel {
  final String image;
  final String chargingStopTime;
  final double amount;
  final int bookingId;
  final String stationAddress;
  final String chargingStartTime;
  final String stationName;
  final String chargerName;
  final double tariff;
  final String tax;
  final double taxAmount;
  final double unitConsumed;
  final int transactionId;

  ChargeTransactionModel({
    required this.image,
    required this.chargingStopTime,
    required this.amount,
    required this.stationAddress,
    required this.bookingId,
    required this.chargingStartTime,
    required this.stationName,
    required this.chargerName,
    required this.tariff,
    required this.tax,
    required this.taxAmount,
    required this.unitConsumed,
    required this.transactionId,
  });

  factory ChargeTransactionModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return ChargeTransactionModel(
      image: json['image'] ?? '',
      chargingStopTime: json['chargingStopTime'] ?? '',
      amount: parseDouble(json['amount']),
      bookingId: json['bookingId'] is int
          ? json['bookingId']
          : int.tryParse(json['bookingId']?.toString() ?? '') ?? -1,
      stationAddress: json['stationAddress'] ?? '',
      chargingStartTime: json['chargingStartTime'] ?? '',
      stationName: json['stationName'] ?? '',
      chargerName: json['chargerName'] ?? '',
      tariff: parseDouble(json['tariff']),
      tax: json['tax']?.toString() ?? '',
      taxAmount: parseDouble(json['taxAmount']),
      unitConsumed: parseDouble(json['unitConsumed']),
      transactionId: json['transactionId'] is int
          ? json['transactionId']
          : int.tryParse(json['transactionId']?.toString() ?? '') ?? 0,
    );
  }

  // Map<String, dynamic> toJson() => {
  //       'image': image,
  //       "ChargingStopTime": chargingStopTime,
  //       "amount": amount,
  //       "chargerName": chargerName,
  //       "startReading": startReading,
  //       "bookingId": bookingId,
  //       "stationAddress": stationAddress,
  //       "unit": unit,
  //       "price": price,
  //       "chargingStartTime": chargingStartTime,
  //       "stationName": stationName,
  //       "stopReading": stopReading,
  //       "chargingPoint": chargingPoint,
  //       "status": status,
  //     };
}
