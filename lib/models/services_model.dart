class TableRequestResponse {
  const TableRequestResponse({
    required this.success,
    required this.isReorder,
    required this.ticketId,
    required this.ticketName,
    required this.grandTotal,
    required this.adminId,
    required this.message,
  });

  final bool success;
  final bool isReorder;
  final String ticketId;
  final String ticketName;
  final double grandTotal;
  final String adminId;
  final String message;

  factory TableRequestResponse.fromJson(Map<String, dynamic> json) {
    return TableRequestResponse(
      success: json['success'] as bool,
      isReorder: json['isReorder'] as bool,
      ticketId: json['ticket_id'] as String,
      ticketName: json['ticketName'] as String,
      grandTotal: (json['grandTotal'] as num).toDouble(),
      adminId: json['adminId'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'isReorder': isReorder,
        'ticket_id': ticketId,
        'ticketName': ticketName,
        'grandTotal': grandTotal,
        'adminId': adminId,
        'message': message,
      };
}

class FoodAddonRequest {
  const FoodAddonRequest({
    required this.addonId,
    required this.quantity,
  });

  final String addonId;
  final int quantity;

  Map<String, dynamic> toJson() => {
        'addonId': addonId,
        'quantity': quantity,
      };
}

// Replace FoodItemRequest in your table_request_model.dart with this:

class FoodItemRequest {
  const FoodItemRequest({
    required this.product,
    required this.quantity,
    this.variant,
    this.note,
    this.addons = const [],
  });

  final String product;
  final int quantity;
  final String? variant;
  final String? note;
  final List<FoodAddonRequest> addons;

  Map<String, dynamic> toJson() => {
        'product': product,
        'quantity': quantity,
        if (variant != null) 'variant': variant,
        if (note != null && note!.isNotEmpty) 'note': note,
        if (addons.isNotEmpty)
          'addons': addons.map((a) => a.toJson()).toList(),
      };
}
class FoodRequest {
  const FoodRequest({
    required this.businessId,
    required this.foodItems,
  });

  final String businessId;
  final List<FoodItemRequest> foodItems;

  Map<String, dynamic> toJson() => {
        'requestType': 'food',
        'businessId': businessId,
        'foodItems': foodItems.map((i) => i.toJson()).toList(),
      };
}

class WaterRequest {
  const WaterRequest({
    required this.businessId,
    required this.tableNumber,
    required this.waterProductId,
  });

  final String businessId;
  final String tableNumber;
  final String waterProductId;

  Map<String, dynamic> toJson() => {
        'requestType': 'water',
        'table_number': tableNumber,
        'businessId': businessId,
        'waterProductId': waterProductId,
      };
}

class BillRequest {
  const BillRequest({required this.businessId});

  final String businessId;

  Map<String, dynamic> toJson() => {
        'requestType': 'bill',
        'businessId': businessId,
      };
}

class WaiterRequest {
  const WaiterRequest({
    required this.businessId,
    required this.tableNumber,
  });

  final String businessId;
  final String tableNumber;

  Map<String, dynamic> toJson() => {
        'requestType': 'waiter',
        'table_number': tableNumber,
        'businessId': businessId,
      };
}