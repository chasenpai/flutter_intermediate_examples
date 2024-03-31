import 'package:delivery/common/model/cursor_pagination_model.dart';
import 'package:delivery/common/model/pagination_params.dart';
import 'package:delivery/common/provider/pagination_provider.dart';
import 'package:delivery/restaurant/model/restaurant_model.dart';
import 'package:delivery/restaurant/repository/restaurant_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final restaurantDetailProvider =
  Provider.family<RestaurantModel?, String>((ref, id) {
    final state = ref.watch(restaurantProvider);
    if(state is! CursorPagination) {
      return null;
    }
    return state.data.firstWhere((e) => e.id == id);
  }
);

final restaurantProvider =
  StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>((ref) {
    final repository = ref.watch(restaurantRepositoryProvider);
    final notifier = RestaurantStateNotifier(repository: repository);
    return notifier;
  },
);

class RestaurantStateNotifier
    extends PaginationProvider<RestaurantModel, RestaurantRepository> {

  RestaurantStateNotifier({
    required super.repository,
  });

  getDetail({required String id}) async {
    //아직 데이터가 하나도 없다면 데이터를 가져온다
    if(state is! CursorPagination) {
      await this.paginate();
    }
    //paginate를 했는데 state가 CursorPagination이 아닐 땐 그냥 리턴
    //서버에서 오류가 났을 것
    if(state is! CursorPagination) {
      return;
    }
    final parsedState = state as CursorPagination;
    final response = await repository.getRestaurantDetail(id: id);
    //[Model(1), Model(2), Model(3)]
    //get detail 2
    //[Model(1), ModelDetail(2), Model(3)]
    state = parsedState.copyWith(
      data: parsedState.data.map<RestaurantModel>((e) => e.id == id ? response : e).toList(),
    );
  }

}