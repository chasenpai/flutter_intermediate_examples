import 'package:delivery/common/model/cursor_pagination_model.dart';
import 'package:delivery/common/model/pagination_params.dart';
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

class RestaurantStateNotifier extends StateNotifier<CursorPaginationBase> {

  final RestaurantRepository repository;

  RestaurantStateNotifier({
    required this.repository,
  }): super(CursorPaginationLoading()) {
    paginate();
  }

  Future<void> paginate({
    int fetchCount = 20,
    //true - 데이터 추가 요청
    //false - 데이터 유지하고 새로 고침
    bool fetchMore = false,
    bool forceReFetch = false, //ture - 강제로 다시 로딩
  }) async {
    try{
      //1. CursorPagination - 정상적으로 데이터가 있는 상태
      //2. CursorPaginationLoading - 데이터가 로딩중인 상태(현재 캐시 없음)
      //3. CursorPaginationError - 에러가 있는 상태
      //4. CursorPaginationReFetching - 첫번재 페이지부터 다시 데이터 요청
      //5. CursorPaginationFetchMore - 추가 데이터 요청

      //바로 리턴
      //1. hasMore = false
      if(state is CursorPagination && !forceReFetch) {
        final parsedState = state as CursorPagination;
        if(!parsedState.meta.hasMore) {
          return;
        }
      }
      //2. 로딩중 fetchMore = true,
      //fetchMore가 아닐 때 - 새로고침의 의도가 있을 수 있음
      final isLoading = state is CursorPaginationLoading; //완전 처음 로딩
      final isReFetching = state is CursorPaginationReFetching; //새로 고침
      final isFetchingMore = state is CursorPaginationFetchingMore; //추가 로딩
      if(fetchMore && (isLoading || isReFetching || isFetchingMore)) {
        return;
      }

      //PaginationParams 생성
      PaginationParams paginationParams = PaginationParams(
        count: fetchCount,
      );

      //fetchMore
      //데이터를 추가로 요청
      if(fetchMore) {
        final parsedState = state as CursorPagination;
        state = CursorPaginationFetchingMore(
          meta: parsedState.meta,
          data: parsedState.data,
        );
        paginationParams = paginationParams.copyWith(
          after: parsedState.data.last.id,
        );
        //데이터를 처음부터 가져오는 상황
      }else {
        //만약 데이터가 있다면
        //기존 데이터를 유지하고 Fetch
        if(state is CursorPagination && !forceReFetch) {
          final parsedState = state as CursorPagination;
          state = CursorPaginationReFetching(
            meta: parsedState.meta,
            data: parsedState.data,
          );
          //데이터를 유지할 필요가 없는 상황
        }else {
          state = CursorPaginationLoading();
        }
      }

      final response = await repository.paginate(
        paginationParams: paginationParams,
      );
      if(state is CursorPaginationFetchingMore) {
        final parsedState = state as CursorPaginationFetchingMore;
        //기존 데이터 + 새로운 데이터
        state = response.copyWith(
          data: [
            ...parsedState.data,
            ...response.data,
          ],
        );
      }else {
        //맨 처음 20개 데이터
        state = response;
      }
    }catch(e) {
      state = CursorPaginationError(message: '데이터를 가져오지 못했습니다.');
    }
  }

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