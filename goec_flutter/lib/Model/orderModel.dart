class OrderModel {
  final String transactionId;
  final String type;
  final String pgOrderId;
  final double amount;
  final String status;
  // final String pgOrderGenTime;
  final String createdAt;

  OrderModel({
    required this.transactionId,
    required this.type,
    required this.pgOrderId,
    required this.amount,
    required this.status,
    // required this.pgOrderGenTime,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final amountRaw = json['amount'];
    return OrderModel(
      transactionId: json['transactionId']?.toString() ??
          json['_id']?.toString() ??
          '-1',
      type: json['type'] ?? '',
      pgOrderId: json['pgOrderId'] ?? '',
      amount: amountRaw is num ? amountRaw.toDouble() : 0,
      status: json['status'] ?? '',
      // pgOrderGenTime: json['pgOrderGenTime'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  // Map<String, dynamic> toJson() => {
  //       "transactionId": transactionId,
  //       "type": type,
  //       "pgOrderId": pgOrderId,
  //       "amount": amount,
  //       "status": status,
  //       "pgOrderGenTime": pgOrderGenTime,
  //     };
}
