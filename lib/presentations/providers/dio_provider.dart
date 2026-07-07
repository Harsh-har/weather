import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Add interceptors
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // Add connectivity check
      Connectivity().checkConnectivity().then((result) {
        if (result.contains(ConnectivityResult.none)) {
          throw DioException(
            requestOptions: options,
            error: 'No internet connection',
            type: DioExceptionType.connectionError,
          );
        }
      });
      return handler.next(options);
    },
    onError: (error, handler) {
      // Log errors
      print('Dio Error: ${error.message}');
      return handler.next(error);
    },
  ));

  return dio;
});