import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io';

Future<void> initializeRevenueCat() async {
  // Platform-specific API keys
  // todo: replace with actual api keys
  String apiKey;
  if (Platform.isIOS) {
    apiKey = 'test_jTuNfakbMmCOfdxdlTMaBTUvhGy';
  } else if (Platform.isAndroid) {
    apiKey = 'test_jTuNfakbMmCOfdxdlTMaBTUvhGy';
  } else {
    throw UnsupportedError('Platform not supported');
  }
  
  await Purchases.configure(PurchasesConfiguration(apiKey));
}