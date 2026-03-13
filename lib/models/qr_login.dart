import 'package:equatable/equatable.dart';

class QrBusinessModel extends Equatable {
  const QrBusinessModel({
    required this.id,
    required this.name,
    required this.address,
  });

  final String id;
  final String name;
  final String address;

  factory QrBusinessModel.fromJson(Map<String, dynamic> json) {
    return QrBusinessModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
    };
  }

  @override
  List<Object?> get props => [id, name, address];
}

class QrLoginModel extends Equatable {
  const QrLoginModel({
    required this.status,
    required this.sessionToken,
    required this.userId,
    required this.role,
    required this.customerName,
    required this.adminId,
    required this.business,
    required this.expiresAt,
  });

  final String status;
  final String sessionToken;
  final String userId;
  final String role;
  final String customerName;
  final String adminId;
  final QrBusinessModel business;
  final DateTime expiresAt;

  factory QrLoginModel.fromJson(Map<String, dynamic> json) {
    return QrLoginModel(
      status: json['status'] as String,
      sessionToken: json['sessionToken'] as String,
      userId: json['userId'] as String,
      role: json['role'] as String,
      customerName: json['customerName'] as String,
      adminId: json['adminId'] as String,
      business: QrBusinessModel.fromJson(json['business'] as Map<String, dynamic>),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'sessionToken': sessionToken,
      'userId': userId,
      'role': role,
      'customerName': customerName,
      'adminId': adminId,
      'business': business.toJson(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  /// Checks if the session is expired.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [
        status,
        sessionToken,
        userId,
        role,
        customerName,
        adminId,
        business,
        expiresAt,
      ];
}