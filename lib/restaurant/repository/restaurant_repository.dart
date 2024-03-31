import 'package:delivery/common/const/data.dart';
import 'package:delivery/common/dio/dio.dart';
import 'package:delivery/common/model/cursor_pagination_model.dart';
import 'package:delivery/common/model/pagination_params.dart';
import 'package:delivery/common/repository/base_pagination_repository.dart';
import 'package:delivery/restaurant/model/restaurant_detail_model.dart';
import 'package:delivery/restaurant/model/restaurant_model.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/http.dart';

part 'restaurant_repository.g.dart';

final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  //만약 변경사항이 생기면 빌드를 다시해야 하기 때문에
  //Provider안에서는 watch를 사용하는게 좋다
  final dio = ref.watch(dioProvider);
  final repository = RestaurantRepository(
    dio,
    baseUrl: 'http://$ip/restaurant',
  );
  return repository;
});

//retrofit
@RestApi()
abstract class RestaurantRepository implements IBasePaginationRepository<RestaurantModel> {

  factory RestaurantRepository(Dio dio, {String baseUrl})
    = _RestaurantRepository;

  @override
  @GET('/')
  @Headers({
    'accessToken': 'true',
  })
  Future<CursorPagination<RestaurantModel>> paginate({
    //PaginationParams의 값을 자동으로 쿼리 파라미터로 변환
    @Queries() PaginationParams? paginationParams = const PaginationParams(),
  });

  @GET('/{id}')
  @Headers({
    'accessToken': 'true',
  })
  Future<RestaurantDetailModel> getRestaurantDetail({ //실제로 응답 받는 형태와 모델의 형태가 일치해야 한다
    @Path() required String id,
  });

}