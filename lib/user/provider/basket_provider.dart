import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:delivery/product/model/product_model.dart';
import 'package:delivery/user/model/basket_item_model.dart';
import 'package:delivery/user/model/patch_basket_body.dart';
import 'package:delivery/user/repository/user_me_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

final basketProvider = StateNotifierProvider
  <BasketProvider, List<BasketItemModel>>((ref) {
    final repository = ref.watch(userMeRepositoryProvider);
    return BasketProvider(repository: repository);
  }
);

class BasketProvider extends StateNotifier<List<BasketItemModel>> {

  final UserMeRepository repository;
  //디바운스 - 함수를 마지막으로 호출한 후 일정 시간이 경과한 후에 함수가 실행되도록 한다
  final updateBasketDebounce = Debouncer(
    Duration(seconds: 1),
    initialValue: null,
    checkEquality: false, //함수를 실행할 때 넣어주는 값이 똑같으면 실행을 하지 않는다
  );

  BasketProvider({
    required this.repository,
  }): super([]) {
    updateBasketDebounce.values.listen((state) {
      patchBasket();
    });
  }

  Future<void> patchBasket() async {
    await repository.patchBasket(
      body: PatchBasketBody(
        basket: state.map((e)
          => PatchBasketBodyBasket(
            productId: e.product.id,
            count: e.count,
          ),
        ).toList(),
      ),
    );
  }

  Future<void> addToBasket({
    required ProductModel product,
  }) async {
    final isExist = state.firstWhereOrNull((e) => e.product.id == product.id) != null;
    //이미 장바구니에 해당되는 상품이 들어있다 -> + 1
    if(isExist) {
      state = state.map((e)
        => e.product.id == product.id
          ? e.copyWith(
            count: e.count + 1,
          )
          : e,
      ).toList();
    //아직 장바구니에 해당되는 상품이 없음 -> 추가
    }else {
      state = [
        ...state,
        BasketItemModel(
          product: product,
          count: 1,
        ),
      ];
    }
    //캐시를 먼저 업데이트하고 요청 - Optimistic Response
    //응답이 성공할거라 가정하고 상태를 먼저 업데이트
    //앱이 빨라보이는 효과를 줄 수 있다
    //await patchBasket();
    updateBasketDebounce.setValue(null);
  }

  Future<void> removeFromBasket({
    required ProductModel product,
    bool isDelete = false,
  }) async {
    //장바구니에 상품이 존재할때
    //상품의 카운트가 1보다 크면 - 1
    //상품의 카운트가 1이면 삭제
    final isExist = state.firstWhereOrNull((e) => e.product.id == product.id) != null;
    if(!isExist) {
      return;
    }
    final existingProduct = state.firstWhere((e) => e.product.id == product.id);
    if(existingProduct.count == 1 || isDelete) {
      state = state.where((e) => e.product.id != product.id).toList();
    }else if (existingProduct.count > 1) {
      state = state.map((e)
        => e.product.id == product.id
          ? e.copyWith(
          count: e.count - 1,
          )
          : e,
      ).toList();
    }
    updateBasketDebounce.setValue(null);
  }
}