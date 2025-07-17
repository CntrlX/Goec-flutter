class NotificationModel {
  // final int id;
  final String title;
  final String body;
  final String createdAt;
  final String imageUrl;
  // final bool isPromotional;

  NotificationModel({
    // required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.imageUrl,
    // required this.isPromotional,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      // id: json['id'],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      createdAt: json['createdAt'] ?? '',
      imageUrl: json['image'] ?? '',
      // isPromotional: json['isPromotional'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "body": body,
        "title": title,
        "image": imageUrl,
        "createdAt": createdAt,
        // "isPromotional": isPromotional,
        // "id": id
      };
}
