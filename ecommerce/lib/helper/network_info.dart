import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_event.dart';
import 'package:flutter/material.dart';

class NetworkInfo {
  final Connectivity connectivity;
  NetworkInfo(this.connectivity);

  Future<bool> get isConnected async {
    List<ConnectivityResult> result = await connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  static void checkConnectivity(BuildContext context) {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      if (getIt<SplashBloc>().state.firstTimeConnectionCheck) {
        getIt<SplashBloc>().add(const SplashFirstConnectionCheckDone());
      } else {
        bool isNotConnected = result.contains(ConnectivityResult.none);
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
    final Uint8List rawBytes = await file.readAsBytes();
    final double sizeInMb = rawBytes.lengthInBytes / 1048576;
    final int quality = sizeInMb < 2
        ? 90
        : sizeInMb < 5
        ? 50
        : sizeInMb < 10
        ? 10
        : 1;
    try {
      final Uint8List? output = await FlutterImageCompress.compressWithList(
        rawBytes,
        quality: quality,
      );
      if (output != null) {
        if (kDebugMode) {
          print('Input size : $sizeInMb');
          print('Output size : ${output.lengthInBytes / 1048576}');
        }
        return XFile.fromData(output);
      }
    } catch (_) {}
    return file;
  }
}
