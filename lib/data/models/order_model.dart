import '../../core/constants/app_colors.dart';

class OrderModel {
  final int id;
  final String number;
  final String status;
  final String dateCreated;
  final double total;
  final double subtotal;
  final double shippingTotal;
  final double discountTotal;
  final double totalTax;
  final String currency;
  final String currencySymbol;
  final String paymentMethodTitle;
  final String customerNote;
  final OrderAddress billing;
  final OrderAddress shipping;
  final List<OrderItem> lineItems;

  OrderModel({
    required this.id,
    required this.number,
    required this.status,
    required this.dateCreated,
    required this.total,
    required this.subtotal,
    required this.shippingTotal,
    required this.discountTotal,
    required this.totalTax,
    required this.currency,
    required this.currencySymbol,
    required this.paymentMethodTitle,
    required this.customerNote,
    required this.billing,
    required this.shipping,
    required this.lineItems,
  });

  String get statusFa => AppColors.getStatusTitleFa(status);

  String get customerFullName {
    final name = '${billing.firstName} ${billing.lastName}'.trim();
    if (name.isNotEmpty) return name;
    final shipName = '${shipping.firstName} ${shipping.lastName}'.trim();
    if (shipName.isNotEmpty) return shipName;
    return 'مشتری بدون نام';
  }

  String get customerPhone {
    if (billing.phone.isNotEmpty) return billing.phone;
    return shipping.phone;
  }

  int get itemsCount {
    return lineItems.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['line_items'] as List? ?? [];
    List<OrderItem> items = rawItems.map((e) => OrderItem.fromJson(e)).toList();

    return OrderModel(
      id: json['id'] as int? ?? 0,
      number: json['number']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      dateCreated: json['date_created']?.toString() ?? '',
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      subtotal: double.tryParse(json['discount_total']?.toString() ?? '0') ?? 0,
      shippingTotal: double.tryParse(json['shipping_total']?.toString() ?? '0') ?? 0,
      discountTotal: double.tryParse(json['discount_total']?.toString() ?? '0') ?? 0,
      totalTax: double.tryParse(json['total_tax']?.toString() ?? '0') ?? 0,
      currency: json['currency']?.toString() ?? 'IRT',
      currencySymbol: json['currency_symbol']?.toString() ?? 'تومان',
      paymentMethodTitle: json['payment_method_title']?.toString() ?? 'پرداخت آنلاین',
      customerNote: json['customer_note']?.toString() ?? '',
      billing: OrderAddress.fromJson(json['billing'] as Map<String, dynamic>? ?? {}),
      shipping: OrderAddress.fromJson(json['shipping'] as Map<String, dynamic>? ?? {}),
      lineItems: items,
    );
  }

  OrderModel copyWith({
    String? status,
  }) {
    return OrderModel(
      id: id,
      number: number,
      status: status ?? this.status,
      dateCreated: dateCreated,
      total: total,
      subtotal: subtotal,
      shippingTotal: shippingTotal,
      discountTotal: discountTotal,
      totalTax: totalTax,
      currency: currency,
      currencySymbol: currencySymbol,
      paymentMethodTitle: paymentMethodTitle,
      customerNote: customerNote,
      billing: billing,
      shipping: shipping,
      lineItems: lineItems,
    );
  }
}

class OrderAddress {
  final String firstName;
  final String lastName;
  final String company;
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String postcode;
  final String country;
  final String email;
  final String phone;

  OrderAddress({
    required this.firstName,
    required this.lastName,
    required this.company,
    required this.address1,
    required this.address2,
    required this.city,
    required this.state,
    required this.postcode,
    required this.country,
    required this.email,
    required this.phone,
  });

  String get fullAddress {
    final parts = [state, city, address1, address2]
        .where((p) => p.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'آدرسی ثبت نشده است';
    var res = parts.join('، ');
    if (postcode.isNotEmpty) {
      res += ' (کد پستی: $postcode)';
    }
    return res;
  }

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      address1: json['address_1']?.toString() ?? '',
      address2: json['address_2']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      postcode: json['postcode']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
}

class OrderItem {
  final int id;
  final String name;
  final int productId;
  final int variationId;
  final int quantity;
  final double subtotal;
  final double total;
  final double price;
  final String sku;
  final String? imageUrl;

  OrderItem({
    required this.id,
    required this.name,
    required this.productId,
    required this.variationId,
    required this.quantity,
    required this.subtotal,
    required this.total,
    required this.price,
    required this.sku,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    String? img;
    if (json['image'] is Map && json['image']['src'] != null) {
      img = json['image']['src'].toString();
    }

    return OrderItem(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      productId: json['product_id'] as int? ?? 0,
      variationId: json['variation_id'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 1,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      sku: json['sku']?.toString() ?? '',
      imageUrl: img,
    );
  }
}

class OrderNote {
  final int id;
  final String dateCreated;
  final String note;
  final bool customerNote;

  OrderNote({
    required this.id,
    required this.dateCreated,
    required this.note,
    required this.customerNote,
  });

  factory OrderNote.fromJson(Map<String, dynamic> json) {
    return OrderNote(
      id: json['id'] as int? ?? 0,
      dateCreated: json['date_created']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      customerNote: json['customer_note'] as bool? ?? false,
    );
  }
}
