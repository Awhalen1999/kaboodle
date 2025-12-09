import 'package:purchases_flutter/purchases_flutter.dart';

Future<bool> checkEntitlement() async {
  CustomerInfo customerInfo = await Purchases.getCustomerInfo();
  return customerInfo.entitlements.active.containsKey('Kaboodle Pro');
}
