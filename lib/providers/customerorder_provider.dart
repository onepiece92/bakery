import 'package:bakery_flutter/services/customerorderservices/customerorder_services.dart';
import 'package:flutter/material.dart';

class CustomerOrderProvider with ChangeNotifier {
  final CustomerOrderServices _service = CustomerOrderServices.instance;

  Future<void> placeOrder() async {
    try {
      final response = _service.createTicket();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
