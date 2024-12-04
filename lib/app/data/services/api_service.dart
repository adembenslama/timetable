import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:timetable/app/controllers/auth_controller.dart';

class ApiService extends GetxService {
  late dio.Dio _dio;
  
  static const String baseUrl = 'http://10.0.2.2:3000';

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = dio.Dio(
      dio.BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        contentType: 'application/json',
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );

    _dio.interceptors.add(
      dio.LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );

    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) {
          print('Making request to: ${options.uri}');
          print('Headers: ${options.headers}');
          final token = Get.find<AuthController>().token;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('Received response: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('Error occurred: ${error.message}');
          print('Error response: ${error.response}');
          switch (error.response?.statusCode) {
            case 401:
              Get.find<AuthController>().logout();
              break;
            case 403:
              break;
          }
          return handler.next(error);
        },
      ),
    );
  }

  // GET request with error handling
  Future<dio.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      print('GET Request to: $baseUrl$path');
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: dio.Options(headers: headers),
      );
      print('Response received: ${response.data}');
      return response;
    } catch (e) {
      print('Error in GET request: $e');
      if (e is dio.DioException) {
        print('DioError type: ${e.type}');
        print('DioError message: ${e.message}');
        print('DioError response: ${e.response}');
      }
      rethrow;
    }
  }

  // POST request
  Future<dio.Response> post(
    String path,
    dynamic data, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: dio.Options(headers: headers),
    );
  }

  // PUT request
  Future<dio.Response> put(
    String path,
    dynamic data, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: dio.Options(headers: headers),
    );
  }

  // DELETE request
  Future<dio.Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return _dio.delete(
      path,
      queryParameters: queryParameters,
      options: dio.Options(headers: headers),
    );
  }
} 