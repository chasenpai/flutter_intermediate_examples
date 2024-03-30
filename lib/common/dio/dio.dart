import 'package:delivery/common/const/data.dart';
import 'package:delivery/common/secure_storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//Provider를 사용하여 하나의 dio 인스턴스를 사용
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  final storage = ref.watch(secureStorageProvider);
  dio.interceptors.add(
    CustomInterceptor(
      storage: storage
    )
  );
  return dio;
});

class CustomInterceptor extends Interceptor {

  final FlutterSecureStorage storage;

  CustomInterceptor({required this.storage});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {

    print('[REQUEST] [${options.method}] ${options.uri}');

    if(options.headers['accessToken'] == 'true') { //더 좋은 방법이 있지 않을까..?
      options.headers.remove('accessToken');
      final token = await storage.read(key: ACCESS_TOKEN_KEY);
      options.headers.addAll({
        'Authorization': 'Bearer $token',
      });
    }

    if(options.headers['refreshToken'] == 'true') {
      options.headers.remove('refreshToken');
      final token = await storage.read(key: REFRESH_TOKEN_KEY);
      options.headers.addAll({
        'Authorization': 'Bearer $token',
      });
    }

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('[RESPONSE] [${response.requestOptions.method}] ${response.requestOptions.uri}');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    //401
    //토큰 재발급을 시도하고 다시 새로운 토큰으로 요청
    print('[ERROR] [${err.requestOptions.method}] ${err.requestOptions.uri}');

    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
    //리프레쉬 토큰이 없으면 에러 던짐
    if(refreshToken == null) {
      return handler.reject(err);
    }

    final isStatus401 = err.response?.statusCode == 401;
    final isPathRefresh = err.requestOptions.path == '/auth/token';
    if(isStatus401 && !isPathRefresh) {
      final dio = Dio();
      try{
        final tokenResp = await dio.post(
          'http://$ip/auth/token',
          options: Options(
            headers: {
              'Authorization': 'Bearer $refreshToken',
            },
          ),
        );
        final accessToken = tokenResp.data['accessToken'];
        final options = err.requestOptions; //에러를 발생시킨 모든 요청과 관련된 옵션
        options.headers.addAll({
          'Authorization': 'Bearer $accessToken',
        });
        await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);
        final response = await dio.fetch(options); //토큰만 변경하고 재요청
        return handler.resolve(response); //응답 반환
      }on DioException catch(e) {
        return handler.reject(e);
      }
    }
    return handler.reject(err);
  }

}