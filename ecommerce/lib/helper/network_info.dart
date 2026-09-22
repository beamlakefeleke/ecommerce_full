import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkInfo {
  final Connectivity connectivity;
  NetworkInfo(this.connectivity);

  Future<bool> get isConnected async {
    List<ConnectivityResult> result = await connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.none) == false &&
        result.isNotEmpty;
  }

  static void checkConnectivity(BuildContext context) {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (Get.find<SplashController>().firstTimeConnectionCheck) {
        Get.find<SplashController>().setFirstTimeConnectionCheck(false);
      } else {
        bool isNotConnected =
            results.isEmpty ||
            results.every((r) => r == ConnectivityResult.none);
        isNotConnected
            ? const SizedBox()
            : ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: isNotConnected ? Colors.red : Colors.green,
            duration: Duration(seconds: isNotConnected ? 6000 : 3),
            content: Text(
              isNotConnected ? 'no_connection' : 'connected',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    });
  }

  static Future<XFile> compressImage(XFile file) async {
    final bytes = await file.readAsBytes();
    final sizeInMb = bytes.lengthInBytes / 1048576;
    final int quality = sizeInMb < 2
        ? 90
        : sizeInMb < 5
        ? 50
        : sizeInMb < 10
        ? 10
        : 1;
    final result = await FlutterImageCompress.compressWithList(
      bytes,
      quality: quality,
      format: CompressFormat.webp,
    );
    if (kDebugMode) {
      print('Input size : ${bytes.lengthInBytes / 1048576}');
      print('Output size : ${result.lengthInBytes / 1048576}');
    }
    return XFile.fromData(result);
  }
}
