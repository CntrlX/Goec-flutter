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
    return ChargeTransactionModel(
      image: json['image'] ?? '',
      chargingStopTime: json['chargingStopTime'] ?? '',
      amount: json['amount'] != null ? double.parse(json['amount']) : 0,
      bookingId: json['bookingId'] ?? -1,
      stationAddress: json['stationAddress'] ?? '',
      chargingStartTime: json['chargingStartTime'] ?? '',
      stationName: json['stationName'] ?? '',
      chargerName: json['chargerName'] ?? '',
      tariff: json['tariff'] != null ? json['tariff'].toDouble() : 0,
      tax: json['tax'] ?? '',
      taxAmount: json['taxAmount'] != null ? json['taxAmount'].toDouble() : 0,
      unitConsumed:
          json['unitConsumed'] != null ? json['unitConsumed'].toDouble() : 0,
      transactionId: json['transactionId'] ?? 0,
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
