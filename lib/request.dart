import 'package:dio/dio.dart';

class RestRequest {
  static final BaseOptions _options = BaseOptions(
    baseUrl: "https://markovid.herokuapp.com/api/fokontany",
    connectTimeout: 5000,
    receiveTimeout: 3000,
    contentType: Headers.formUrlEncodedContentType,
  );
  Dio _dio = Dio(RestRequest._options);

  Future<Dio> getDioInstance() async {
    return _dio;
  }
}
