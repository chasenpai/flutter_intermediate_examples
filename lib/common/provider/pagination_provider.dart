import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:delivery/common/model/cursor_pagination_model.dart';
import 'package:delivery/common/model/model_with_id.dart';
import 'package:delivery/common/model/pagination_params.dart';
import 'package:delivery/common/repository/base_pagination_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaginationProvider<T extends IModelWithId, U extends IBasePaginationRepository<T>>
    extends StateNotifier<CursorPaginationBase> {

  final U repository;
  //쓰로틀링 - 함수가 호출되는 횟수와 상관없이 일정 간격으로 함수를 실행
  final paginationThrottle = Throttle(
    Duration(seconds: 3),
    initialValue: _PaginationInfo(),
    checkEquality: false, //함수를 실행할 때 넣어주는 값이 똑같으면 실행을 하지 않는다
  );

  PaginationProvider({
    required this.repository,
  }): super(CursorPaginationLoading()) {
    //1. paginate를 실행
    paginate();
    //state - 처음에 initialValue, 그다음 setValue(val)
    paginationThrottle.values.listen((state) {
      //2. paginationThrottle에 실행하는 값이 들어오면 리스너에서 함수를 실행
      _throttlePagination(state);
    });

  }

  Future<void> paginate({
    int fetchCount = 20,
    //true - 데이터 추가 요청
    //false - 데이터 유지하고 새로 고침
    bool fetchMore = false,
    bool forceReFetch = false, //ture - 강제로 다시 로딩
  }) async {
    paginationThrottle.setValue(
      _PaginationInfo(
        fetchCount: fetchCount,
        fetchMore: fetchMore,
        forceReFetch: forceReFetch,
      ),
    );
  }

  _throttlePagination(_PaginationInfo info) async {

    final fetchCount = info.fetchCount;
    final fetchMore = info.fetchMore;
    final forceReFetch = info.forceReFetch;

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
        final parsedState = state as CursorPagination<T>;
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
          final parsedState = state as CursorPagination<T>;
          state = CursorPaginationReFetching<T>(
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
        final parsedState = state as CursorPaginationFetchingMore<T>;
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
}

class _PaginationInfo {

  final int fetchCount;
  final bool fetchMore;
  final bool forceReFetch;

  _PaginationInfo({
    this.fetchCount = 20,
    this.fetchMore = false,
    this.forceReFetch = false,
  });
}