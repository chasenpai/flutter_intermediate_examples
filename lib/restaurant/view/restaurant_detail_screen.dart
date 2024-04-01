import 'package:delivery/common/const/colors.dart';
import 'package:delivery/common/layout/default_layout.dart';
import 'package:delivery/common/model/cursor_pagination_model.dart';
import 'package:delivery/common/utils/pagination_utils.dart';
import 'package:delivery/product/component/product_card.dart';
import 'package:delivery/product/model/product_model.dart';
import 'package:delivery/rating/component/rating_card.dart';
import 'package:delivery/rating/model/rating_model.dart';
import 'package:delivery/restaurant/component/restaurant_card.dart';
import 'package:delivery/restaurant/model/restaurant_detail_model.dart';
import 'package:delivery/restaurant/model/restaurant_model.dart';
import 'package:delivery/restaurant/provider/restaurant_provider.dart';
import 'package:delivery/restaurant/provider/restaurant_rating_provider.dart';
import 'package:delivery/restaurant/view/basket_screen.dart';
import 'package:delivery/user/provider/basket_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletons/skeletons.dart';
import 'package:badges/badges.dart' as badges;

class RestaurantDetailScreen extends ConsumerStatefulWidget {

  static String get routeName => 'restaurantDetail';

  final String id;

  const RestaurantDetailScreen({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends ConsumerState<RestaurantDetailScreen> {

  final ScrollController controller = ScrollController();
  
  @override
  void initState() {
    super.initState();
    ref.read(restaurantProvider.notifier).getDetail(id: widget.id);
    controller.addListener(scrollListener);
  }

  void scrollListener() {
    PaginationUtils.paginate(
      controller: controller,
      provider: ref.read(restaurantRatingProvider(widget.id).notifier),
    );
  }
  
  @override
  Widget build(BuildContext context) {

    final state = ref.watch(restaurantDetailProvider(widget.id));
    final ratingsState = ref.watch(restaurantRatingProvider(widget.id));
    final basket = ref.watch(basketProvider);

    if(state == null) {
      return DefaultLayout(child: Center(child: CircularProgressIndicator(),));
    }

    return DefaultLayout(
      title: '떡볶이',
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed(BasketScreen.routeName);
        },
        //Badges
        backgroundColor: PRIMARY_COLOR,
        child: badges.Badge(
          showBadge: basket.isNotEmpty,
          badgeContent: Text(
            basket.fold(0, (previous, next)
              => previous + next.count,
            ).toString(),
            style: TextStyle(
              color: PRIMARY_COLOR,
              fontSize: 12.0,
            ),
          ),
          child: Icon(
            Icons.shopping_basket_outlined,
            color: Colors.white,
          ),
          badgeStyle: badges.BadgeStyle(
            badgeColor: Colors.white,
          ),
        ),
      ),
      child: CustomScrollView(
        controller: controller,
        slivers: [
          renderTop(model: state,),
          if(state is! RestaurantDetailModel)
            renderLoading(),
          if(state is RestaurantDetailModel)
            renderLabel(),
          if(state is RestaurantDetailModel)
            renderProducts(
              products: state.products,
              restaurant: state,
            ),
          if(ratingsState is CursorPagination<RatingModel>)
            renderRatings(models: ratingsState.data,),
        ],
      ),
    );
  }

  SliverPadding renderRatings({required List<RatingModel> models}) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0,),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((_, index)
          => Padding(
            padding: const EdgeInsets.only(bottom: 16.0,),
            child: RatingCard.fromModel(model: models[index],),
          ),
          childCount: models.length,
        ),
      ),
    );
  }

  //Skeletons
  SliverPadding renderLoading() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          List.generate(3, (index)
            => Padding(
              padding: const EdgeInsets.only(bottom: 32.0,),
              child: SkeletonParagraph(
                style: SkeletonParagraphStyle(
                  lines: 5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter renderTop({required RestaurantModel model}) {
    return SliverToBoxAdapter( //슬리버안에 일반 위젯을 넣을 때
      child: RestaurantCard.fromModel(model: model, isDetail: true,),
    );
  }

  SliverPadding renderLabel() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0,),
      sliver: SliverToBoxAdapter(
        child: Text(
          '메뉴',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  SliverPadding renderProducts({
    required List<RestaurantProductModel> products,
    required RestaurantModel restaurant,
  }) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0,),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final model = products[index];
            //InkWell - 눌렀을 때 액션을 정의할 수 있음
            //주로 액션이 발생 했을 때 화면에 머물러있는 경우에 사용
            return InkWell(
              onTap: () {
                ref.read(basketProvider.notifier).addToBasket(
                  product: ProductModel(
                    id: model.id,
                    name: model.name,
                    detail: model.detail,
                    imgUrl: model.imgUrl,
                    price: model.price,
                    restaurant: restaurant,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0,),
                child: ProductCard.fromRestaurantModel(model: model),
              ),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

}
