import 'package:delivery/common/const/data.dart';
import 'package:delivery/common/dio/dio.dart';
import 'package:delivery/common/model/cursor_pagination_model.dart';
import 'package:delivery/restaurant/component/restaurant_card.dart';
import 'package:delivery/restaurant/model/restaurant_model.dart';
import 'package:delivery/restaurant/provider/restaurant_provider.dart';
import 'package:delivery/restaurant/repository/restaurant_repository.dart';
import 'package:delivery/restaurant/view/restaurant_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RestaurantScreen extends ConsumerStatefulWidget {
  const RestaurantScreen({super.key});

  @override
  ConsumerState<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends ConsumerState<RestaurantScreen> {

  //스크롤 컨트롤러를 사용하기 위해 Stateful 위젯 사용
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(scrollListener);
  }

  void scrollListener() {
    //현재 위치가 최대 길이보다 조금 덜되는 위치까지 온다면 추가 데이터 요청
    //maxScrollExtent - 최대 스크롤 가능한 길이
    if(controller.offset > controller.position.maxScrollExtent - 300) {
      ref.read(restaurantProvider.notifier).paginate(
        fetchMore: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    //Provider를 사용한 데이터 캐싱
    final data = ref.watch(restaurantProvider);

    //완전 처음 로딩
    if(data is CursorPaginationLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    //에러 발생
    if(data is CursorPaginationError) {
      return Center(
        child: Text(data.message,),
      );
    }

    final cursorPagination = data as CursorPagination;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.separated(
        controller: controller,
        itemCount: cursorPagination.data.length + 1,
        itemBuilder: (context, index) {
          //추가 요청 시 로딩바
          if(index == cursorPagination.data.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Center(
                child: data is CursorPaginationFetchingMore
                  ? CircularProgressIndicator()
                  : Text('더 이상 데이터가 없습니다.',),
              ),
            );
          }
          final item = cursorPagination.data[index];
          return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RestaurantDetailScreen(id: item.id,),
                  ),
                );
              },
              child: RestaurantCard.fromModel(model: item,)
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(height: 16.0,);
        },
      ),
    );
  }
}
