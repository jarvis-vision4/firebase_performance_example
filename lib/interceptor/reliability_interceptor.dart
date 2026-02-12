import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
class ReliabilityInterceptor extends Interceptor{
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: implement onRequest
    options.extra['request_start_time'] = DateTime.now().millisecondsSinceEpoch;
    options.extra['retry_count'] = options.extra['retry_count'] ?? 0;
    super.onRequest(options, handler);
  }
  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    // TODO: implement onResponse
    final startTime = response.requestOptions.extra['request_start_time'] as int?;
    if (startTime != null) {
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      debugPrint('Request duration: ${duration}ms');
    }
    super.onResponse(response, handler);
  }
}