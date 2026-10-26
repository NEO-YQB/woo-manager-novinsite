import 'order_model.dart';

class CustomerModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String username;
  final String avatarUrl;
  final int ordersCount;
  final double totalSpent;
  final OrderAddress billing;
  final OrderAddress shipping;

  CustomerModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.avatarUrl,
    required this.ordersCount,
    required this.totalSpent,
    required this.billing,
    required this.shipping,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    if (name.isNotEmpty) return name;
    if (username.isNotEmpty) return username;
    return 'مشتری #${id}';
  }

  String get phone {
    if (billing.phone.isNotEmpty) return billing.phone;
    return shipping.phone;
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as int? ?? 0,
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ?? '',
      ordersCount: int.tryParse(json['orders_count']?.toString() ?? '0') ?? 0,
      totalSpent: double.tryParse(json['total_spent']?.toString() ?? '0') ?? 0,
      billing: OrderAddress.fromJson(json['billing'] as Map<String, dynamic>? ?? {}),
      shipping: OrderAddress.fromJson(json['shipping'] as Map<String, dynamic>? ?? {}),
    );
  }
}
