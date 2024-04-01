import 'package:delivery/common/view/root_tab.dart';
import 'package:delivery/common/view/splash_screen.dart';
import 'package:delivery/order/view/order_done_screen.dart';
import 'package:delivery/restaurant/view/basket_screen.dart';
import 'package:delivery/restaurant/view/restaurant_detail_screen.dart';
import 'package:delivery/user/model/user_model.dart';
import 'package:delivery/user/provider/user_me_provider.dart';
import 'package:delivery/user/view/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(ref: ref);
});

class AuthProvider extends ChangeNotifier {

  final Ref ref;
  
  AuthProvider({
    required this.ref
  }) {
    ref.listen<UserModelBase?>(userMeProvider, (previous, next) {
      //UserMeProvider에 변경사항이 생겼을 때 AuthProvider에서도 변경사항이
      //생겼다고 알려준다
      if(previous != next) {
        notifyListeners();
      }
    });
  }

  List<GoRoute> get routes => [
    GoRoute(
      path: '/',
      name: RootTab.routeName,
      builder: (context, state) => RootTab(),
      routes: [
        GoRoute(
          path: 'restaurant/:rid',
          name: RestaurantDetailScreen.routeName,
          builder: (context, state) => RestaurantDetailScreen(
            id: state.pathParameters['rid'].toString(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/basket',
      name: BasketScreen.routeName,
      builder: (context, state) => BasketScreen(),
    ),
    GoRoute(
      path: '/order_done',
      name: OrderDoneScreen.routeName,
      builder: (context, state) => OrderDoneScreen(),
    ),
    GoRoute(
      path: '/splash',
      name: SplashScreen.routeName,
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: LoginScreen.routeName,
      builder: (context, state) => LoginScreen(),
    ),
  ];

  //SplashScreen
  String? redirectLogic(GoRouterState state) {
    final UserModelBase? user = ref.read(userMeProvider);
    final loggingIn = state.location == '/login';
    //유저 정보 없음
    //로그인 중이면 그대로 두고
    //로그인중이 아니라면 로그인 페이지로 이동
    if(user == null) {
      return loggingIn ? null : '/login';
    }
    //유저 정보가 있음
    //로그인 중이거나 현재 위치가 SplashScreen이면 홈으로 이동
    if(user is UserModel) {
      return loggingIn || state.location == '/splash' ? '/' : null;
    }
    //로그인 오류
    if(user is UserModelError) {
      return !loggingIn ? 'login' : null;
    }
    return null;
  }

  void logout() {
    ref.read(userMeProvider.notifier).logout();
  }
}