// import 'package:flutter/foundation.dart';
// import '../models/address.dart';
// import '../data/bakery_data.dart';

// /// Manages the currently selected delivery/pickup address.
// class AddressProvider extends ChangeNotifier {
//   int _selectedId = 1;

//   int get selectedId => _selectedId;

//   Address get selected => BakeryData.savedAddresses.firstWhere(
//         (a) => a.id == _selectedId,
//         orElse: () => BakeryData.savedAddresses.first,
//       );

//   void select(int id) {
//     _selectedId = id;
//     notifyListeners();
//   }
// }
