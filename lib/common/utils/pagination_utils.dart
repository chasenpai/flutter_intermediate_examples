import 'package:delivery/common/provider/pagination_provider.dart';
import 'package:flutter/cupertino.dart';

class PaginationUtils {
  static void paginate({
    required ScrollController controller,
    required PaginationProvider provider
  }) {
    //현재 위치가 최대 길이보다 조금 덜되는 위치까지 온다면 추가 데이터 요청
    //maxScrollExtent - 최대 스크롤 가능한 길이
    if(controller.offset > controller.position.maxScrollExtent - 300) {
      provider.paginate(fetchMore: true,);
    }
  }
}