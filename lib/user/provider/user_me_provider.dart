import 'package:delivery/common/const/data.dart';
import 'package:delivery/common/secure_storage/secure_storage.dart';
import 'package:delivery/user/model/user_model.dart';
import 'package:delivery/user/repository/auth_repository.dart';
import 'package:delivery/user/repository/user_me_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final userMeProvider = StateNotifierProvider
  <UserMeStateNotifier, UserModelBase?>((ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    final userMeRepository = ref.watch(userMeRepositoryProvider);
    final storage = ref.watch(secureStorageProvider);
    return UserMeStateNotifier(
      authRepository: authRepository,
      userMeRepository: userMeRepository,
      storage: storage,
    );
  }
);

class UserMeStateNotifier extends StateNotifier<UserModelBase?> {

  final AuthRepository authRepository;
  final UserMeRepository userMeRepository;
  final FlutterSecureStorage storage;

  UserMeStateNotifier({
    required this.authRepository,
    required this.userMeRepository,
    required this.storage,
  }): super(UserModelLoading()) {
    getMe();
  }

  Future<void> getMe() async {
    //dio interceptor에서 토큰이 자동으로 들어가지만
    //토큰이 없으면 getMe 요청을 보낼 필요가 없다
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
    if(accessToken == null || refreshToken == null) {
      state = null; //로그아웃
      return;
    }
    final response = await userMeRepository.getMe();
    state = response;
  }

  Future<UserModelBase> login({
    required String username,
    required String password,
  }) async {
    try{
      state = UserModelLoading();

      final response = await authRepository.login(
        username: username,
        password: password,
      );

      await storage.write(key: REFRESH_TOKEN_KEY, value: response.refreshToken);
      await storage.write(key: ACCESS_TOKEN_KEY, value: response.accessToken);

      final userResponse = await userMeRepository.getMe();
      state = userResponse;
      return userResponse;
    }catch(e) {
      state = UserModelError(message: '로그인에 실패했습니다.');
      return Future.value(state);
    }
  }

  Future<void> logout() async {
    state = null;
    Future.wait([
      storage.delete(key: REFRESH_TOKEN_KEY),
      storage.delete(key: ACCESS_TOKEN_KEY),
    ]);
  }

}