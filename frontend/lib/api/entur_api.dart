import 'package:dio/dio.dart';

class EnturApi {
  static const String basePath =
      'https://api.entur.io/journey-planner/v3';

  final Dio _dio;

  EnturApi()
      : _dio = Dio(BaseOptions(
          baseUrl: basePath,
          connectTimeout: const Duration(milliseconds: 10000),
          receiveTimeout: const Duration(milliseconds: 10000),
          headers: {
            'User-Agent':
                'Mozilla/5.0 (X11; Linux x86_64; rv:145.0) Gecko/20100101 Firefox/145.0',
            'Accept': '*/*',
            'Content-Type': 'application/json',
            'ET-Client-Name': 'entur-tavla',
          },
        ));

  /// Execute a GraphQL query against the Entur API
  Future<Response<Map<String, dynamic>>> query({
    required String query,
    Map<String, dynamic>? variables,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/graphql',
      data: {
        'query': query,
        if (variables != null) 'variables': variables,
      },
      cancelToken: cancelToken,
    );

    return response;
  }
}
