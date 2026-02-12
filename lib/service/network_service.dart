import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_performance_dio/firebase_performance_dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../models/create_post_request.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../models/user_profile.dart';
import 'api_response.dart';

class NetworkService {
  static NetworkService? _instance;

  static NetworkService get instance => _instance ??= NetworkService._();
  late final Dio _dio;
  late final Connectivity _connectivity;

  NetworkService._() {
    _connectivity = Connectivity();
    _setupDio();
  }

  void _setupDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        sendTimeout: Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(DioFirebasePerformanceInterceptor());
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }
  Future<ApiResponse<List<Post>>> getPostsWithManualTracking() async {
    // Create manual HTTP metric
    final HttpMetric httpMetric = FirebasePerformance.instance.newHttpMetric(
      'https://jsonplaceholder.typicode.com/posts',
      HttpMethod.Get,
    );

    await httpMetric.start();

    try {
      // Add custom attributes to network request
      httpMetric.putAttribute('api_version', 'v2');
      httpMetric.putAttribute('user_type', 'premium');
      httpMetric.putAttribute('cache_enabled', 'false');

      // Set request payload size (0 for GET)
      httpMetric.requestPayloadSize = 0;

      final response = await _dio.get('/posts');

      // Set response details
      httpMetric.responseContentType = 'application/json';
      httpMetric.responsePayloadSize = response.data.toString().length;
      httpMetric.httpResponseCode = response.statusCode!;

      final posts = (response.data as List)
          .map((json) => Post.fromJson(json))
          .toList();

      return ApiResponse.success(posts);
    } on DioException catch (e) {
      httpMetric.httpResponseCode = e.response?.statusCode ?? 0;
      return ApiResponse.error(_handleDioError(e));
    } finally {
      // Always stop the HTTP metric
      await httpMetric.stop();
    }
  }
  Future<ApiResponse<List<Post>>> getPosts() async {
    try {
      final response = await _dio.get('/posts');
      final posts = (response.data as List)
          .map((json) => Post.fromJson(json))
          .toList();
      return ApiResponse.success(posts);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }
  Future<ApiResponse<Post>> createPost(CreatePostRequest request) async {
    try {
      final response = await _dio.post('/posts', data: request.toJson());
      final post = Post.fromJson(response.data);
      return ApiResponse.success(post);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }
  Future<ApiResponse<UserProfile>> getUserProfile(int userId) async {
    try {
      // These will all be tracked automatically
      final userResponse = await _dio.get('/users/$userId');
      final postsResponse = await _dio.get('/posts?userId=$userId');
      final albumsResponse = await _dio.get('/albums?userId=$userId');

      final profile = UserProfile(
        user: User.fromJson(userResponse.data),
        posts: (postsResponse.data as List)
            .map((json) => Post.fromJson(json))
            .toList(),
        albumCount: (albumsResponse.data as List).length,
      );

      return ApiResponse.success(profile);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        return 'Server error: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error';
      default:
        return 'Network error occurred';
    }
  }

}