class AppNotificationModel {
  final String id;
  final String title;
  final String body;
  final int? orderId;
  final DateTime timestamp;
  bool isRead;
  final String type; // 'order_new', 'order_status', 'low_stock', 'test'

  AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.orderId,
    required this.timestamp,
    this.isRead = false,
    this.type = 'order_new',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'orderId': orderId,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type,
    };
  }

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      orderId: json['orderId'] != null ? int.tryParse(json['orderId'].toString()) : null,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      type: json['type']?.toString() ?? 'order_new',
    );
  }
}
