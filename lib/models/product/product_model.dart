import 'package:equatable/equatable.dart';

class Addon extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final int maxAvailable;
  final String adminId;

  const Addon({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.maxAvailable,
    required this.adminId,
  });

  factory Addon.fromJson(Map<String, dynamic> json) => Addon(
        id: json['_id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        maxAvailable: json['maxAvailable'] as int,
        adminId: json['adminId'] as String,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'description': description,
        'price': price,
        'maxAvailable': maxAvailable,
        'adminId': adminId,
      };

  @override
  List<Object?> get props =>
      [id, name, description, price, maxAvailable, adminId];
}

class VariantItem extends Equatable {
  final String id;
  final List<String> optionValues;
  final double price;
  final double costPrice;
  final bool isAvailable;
  final int inStock;
  final int lowStock;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VariantItem({
    required this.id,
    required this.optionValues,
    required this.price,
    required this.costPrice,
    required this.isAvailable,
    required this.inStock,
    required this.lowStock,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VariantItem.fromJson(Map<String, dynamic> json) => VariantItem(
        id: json['_id'] as String,
        optionValues: List<String>.from(json['optionValues'] as List),
        price: (json['price'] as num).toDouble(),
        costPrice: (json['costPrice'] as num).toDouble(),
        isAvailable: json['isAvailable'] as bool,
        inStock: json['inStock'] as int,
        lowStock: json['lowStock'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'optionValues': optionValues,
        'price': price,
        'costPrice': costPrice,
        'isAvailable': isAvailable,
        'inStock': inStock,
        'lowStock': lowStock,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        optionValues,
        price,
        costPrice,
        isAvailable,
        inStock,
        lowStock,
        createdAt,
        updatedAt,
      ];
}

class VariantOption extends Equatable {
  final String id;
  final String title;
  final List<String> values;

  const VariantOption({
    required this.id,
    required this.title,
    required this.values,
  });

  factory VariantOption.fromJson(Map<String, dynamic> json) => VariantOption(
        id: json['_id'] as String,
        title: json['title'] as String,
        values: List<String>.from(json['values'] as List),
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'values': values,
      };

  @override
  List<Object?> get props => [id, title, values];
}

class Variants extends Equatable {
  final String id;
  final String productId;
  final String adminId;
  final List<VariantOption> options;
  final List<VariantItem> variantItems;

  const Variants({
    required this.id,
    required this.productId,
    required this.adminId,
    required this.options,
    required this.variantItems,
  });

  factory Variants.fromJson(Map<String, dynamic> json) => Variants(
        id: json['_id'] as String,
        productId: json['productId'] as String,
        adminId: json['adminId'] as String,
        options: (json['options'] as List)
            .map((e) => VariantOption.fromJson(e as Map<String, dynamic>))
            .toList(),
        variantItems: (json['variantItems'] as List)
            .map((e) => VariantItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'productId': productId,
        'adminId': adminId,
        'options': options.map((e) => e.toJson()).toList(),
        'variantItems': variantItems.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [id, productId, adminId, options, variantItems];
}

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final String image;
  final String adminId;
  final String sku;
  final String categories;
  final String soldBy;
  final double price;
  final double costPrice;
  final bool isVeg;
  final bool isAvailable;
  final bool usesOfferPrice;
  final bool isTaxable;
  final bool usesStocks;
  final bool showInOrdering;
  final int inStock;
  final int lowStock;
  final int orderedCount;
  final List<Addon> addons;
  final List<String> tags;
  final Variants? variants;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.adminId,
    required this.sku,
    required this.categories,
    required this.soldBy,
    required this.price,
    required this.costPrice,
    required this.isVeg,
    required this.isAvailable,
    required this.usesOfferPrice,
    required this.isTaxable,
    required this.usesStocks,
    required this.showInOrdering,
    required this.inStock,
    required this.lowStock,
    required this.orderedCount,
    required this.addons,
    required this.tags,
    this.variants,
  });

  bool get hasVariants => variants != null && variants!.variantItems.isNotEmpty;
  double get displayPrice {
    if (!hasVariants) return price;
    return variants!.variantItems
        .map((v) => v.price)
        .reduce((a, b) => a < b ? a : b);
  }

  List<double> get variantPrices =>
      hasVariants ? variants!.variantItems.map((v) => v.price).toList() : [];
  factory Product.fromJson(Map<String, dynamic> json) {
    final variantsJson = json['variants'];

    return Product(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      adminId: json['adminId'] as String,
      sku: json['sku'] as String,
      categories: json['categories'] as String? ?? '',
      soldBy: json['soldBy'] as String? ?? 'each',
      price: (json['price'] as num).toDouble(),
      costPrice: (json['costPrice'] as num).toDouble(),
      isVeg: json['isVeg'] as bool,
      isAvailable: json['isAvailable'] as bool,
      usesOfferPrice: json['usesOfferPrice'] as bool,
      isTaxable: json['isTaxable'] as bool? ?? false,
      usesStocks: json['usesStocks'] as bool? ?? false,
      showInOrdering: json['showInOrdering'] as bool? ?? true,
      inStock: json['inStock'] as int? ?? 0,
      lowStock: json['lowStock'] as int? ?? 0,
      orderedCount: json['orderedCount'] as int? ?? 0,
      addons: (json['addons'] as List? ?? [])
          .map((e) => Addon.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: List<String>.from(json['tags'] as List? ?? []),
      variants: variantsJson != null
          ? Variants.fromJson(variantsJson as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'description': description,
        'image': image,
        'adminId': adminId,
        'sku': sku,
        'categories': categories,
        'soldBy': soldBy,
        'price': price,
        'costPrice': costPrice,
        'isVeg': isVeg,
        'isAvailable': isAvailable,
        'usesOfferPrice': usesOfferPrice,
        'isTaxable': isTaxable,
        'usesStocks': usesStocks,
        'showInOrdering': showInOrdering,
        'inStock': inStock,
        'lowStock': lowStock,
        'orderedCount': orderedCount,
        'addons': addons.map((e) => e.toJson()).toList(),
        'tags': tags,
        if (variants != null) 'variants': variants!.toJson(),
      };

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        image,
        adminId,
        sku,
        categories,
        soldBy,
        price,
        costPrice,
        isVeg,
        isAvailable,
        usesOfferPrice,
        isTaxable,
        usesStocks,
        showInOrdering,
        inStock,
        lowStock,
        orderedCount,
        addons,
        tags,
        variants,
      ];
}
