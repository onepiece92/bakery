class CustomerLoginResponse {
  final String status;
  final String sessionToken;
  final String userId;
  final String customerName;

  CustomerLoginResponse({
    required this.status,
    required this.sessionToken,
    required this.userId,
    required this.customerName,
  });

  factory CustomerLoginResponse.fromJson(Map<String, dynamic> json) {
    return CustomerLoginResponse(
      status: json['status'] ?? '',
      sessionToken: json['sessionToken'] ?? '',
      userId: json['userId'] ?? '',
      customerName: json['customerName'] ?? '',
    );
  }
}