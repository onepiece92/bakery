
import 'package:bakery_flutter/services/api_service.dart';
import 'package:bakery_flutter/services/localstorage_service.dart';
import 'package:flutter/rendering.dart';
class CustomerOrderServices{
    CustomerOrderServices._();
  static final CustomerOrderServices instance = CustomerOrderServices._();
  final ApiService _api = ApiService.instance;
Future<void> createTicket ()async{
try{


  final response = _api.post(
    '/ticket',
    data: {
      
    }
  );
}catch(e){
  debugPrint(e.toString());
}
}
}