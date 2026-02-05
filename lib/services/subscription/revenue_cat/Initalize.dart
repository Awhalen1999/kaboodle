import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io';

Future<void> initializeRevenueCat() async {
  // Platform-specific API keys
  // todo: replace with actual api keys
  String apiKey;
  if (Platform.isIOS) {
    // apple key
    apiKey = 'appl_WgUgyZNJMkQbxUQLbKSfAMmEbzt';
    // test key
    // apiKey = 'test_jTuNfakbMmCOfdxdlTMaBTUvhGy';
  } else if (Platform.isAndroid) {
    // android key
    apiKey = 'goog_QyEkCxSQHlrwXcehGaCzPJXsYAd';
    // test key
    // apiKey = 'test_jTuNfakbMmCOfdxdlTMaBTUvhGy';
  } else {
    throw UnsupportedError('Platform not supported');
  }

  await Purchases.configure(PurchasesConfiguration(apiKey));
}
