class ProductModel {
  final int id;
  final String name;
  final String slug;
  final String permalink;
  final String type;
  final String status;
  final bool featured;
  final String description;
  final String shortDescription;
  final String sku;
  final double price;
  final double regularPrice;
  final double? salePrice;
  final bool onSale;
  final bool manageStock;
  final int? stockQuantity;
  final String stockStatus;
  final List<ProductCategory> categories;
  final List<ProductImage> images;
  final double averageRating;
  final int ratingCount;
  final int totalSales;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.permalink,
    required this.type,
    required this.status,
    required this.featured,
    required this.description,
    required this.shortDescription,
    required this.sku,
    required this.price,
    required this.regularPrice,
    this.salePrice,
    required this.onSale,
    required this.manageStock,
    this.stockQuantity,
    required this.stockStatus,
    required this.categories,
    required this.images,
    required this.averageRating,
    required this.ratingCount,
    required this.totalSales,
  });

  String get mainImageUrl {
    if (images.isNotEmpty) {
      return images.first.src;
    }
    return '';
  }

  bool get isPublished => status == 'publish';
  bool get isInStock => stockStatus == 'instock';

  String get stockStatusFa {
    switch (stockStatus) {
      case 'instock':
        if (manageStock && stockQuantity != null) {
          return '$stockQuantity عدد در انبار';
        }
        return 'موجود در انبار';
      case 'outofstock':
        return 'ناموجود';
      case 'onbackorder':
        return 'پیش‌سفارش';
      default:
        return stockStatus;
    }
  }

  String get categoriesString {
    if (categories.isEmpty) return 'بدون دسته‌بندی';
    return categories.map((c) => c.name).join('، ');
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    var rawCats = json['categories'] as List? ?? [];
    List<ProductCategory> cats = rawCats.map((e) => ProductCategory.fromJson(e)).toList();

    var rawImgs = json['images'] as List? ?? [];
    List<ProductImage> imgs = rawImgs.map((e) => ProductImage.fromJson(e)).toList();

    double regPrice = double.tryParse(json['regular_price']?.toString() ?? '') ??
        double.tryParse(json['price']?.toString() ?? '0') ??
        0;

    double? sPrice;
    if (json['sale_price'] != null && json['sale_price'].toString().isNotEmpty) {
      sPrice = double.tryParse(json['sale_price'].toString());
    }

    return ProductModel(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      permalink: json['permalink']?.toString() ?? '',
      type: json['type']?.toString() ?? 'simple',
      status: json['status']?.toString() ?? 'publish',
      featured: json['featured'] as bool? ?? false,
      description: json['description']?.toString() ?? '',
      shortDescription: json['short_description']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      regularPrice: regPrice,
      salePrice: sPrice,
      onSale: json['on_sale'] as bool? ?? false,
      manageStock: json['manage_stock'] as bool? ?? false,
      stockQuantity: json['stock_quantity'] != null ? int.tryParse(json['stock_quantity'].toString()) : null,
      stockStatus: json['stock_status']?.toString() ?? 'instock',
      categories: cats,
      images: imgs,
      averageRating: double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0,
      ratingCount: int.tryParse(json['rating_count']?.toString() ?? '0') ?? 0,
      totalSales: int.tryParse(json['total_sales']?.toString() ?? '0') ?? 0,
    );
  }

  ProductModel copyWith({
    String? name,
    String? status,
    String? sku,
    double? price,
    double? regularPrice,
    double? salePrice,
    bool? onSale,
    bool? manageStock,
    int? stockQuantity,
    String? stockStatus,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      slug: slug,
      permalink: permalink,
      type: type,
      status: status ?? this.status,
      featured: featured,
      description: description,
      shortDescription: shortDescription,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      regularPrice: regularPrice ?? this.regularPrice,
      salePrice: salePrice ?? this.salePrice,
      onSale: onSale ?? this.onSale,
      manageStock: manageStock ?? this.manageStock,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      stockStatus: stockStatus ?? this.stockStatus,
      categories: categories,
      images: images,
      averageRating: averageRating,
      ratingCount: ratingCount,
      totalSales: totalSales,
    );
  }
}

class ProductCategory {
  final int id;
  final String name;
  final String slug;

  ProductCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }
}

class ProductImage {
  final int id;
  final String src;
  final String name;
  final String alt;

  ProductImage({
    required this.id,
    required this.src,
    required this.name,
    required this.alt,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] as int? ?? 0,
      src: json['src']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      alt: json['alt']?.toString() ?? '',
    );
  }
}
