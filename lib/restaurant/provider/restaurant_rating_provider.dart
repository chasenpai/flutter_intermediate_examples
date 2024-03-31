import 'package:delivery/common/model/cursor_pagination_model.dart';
import 'package:delivery/common/provider/pagination_provider.dart';
import 'package:delivery/rating/model/rating_model.dart';
import 'package:delivery/restaurant/repository/restaurant_rating_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final restaurantRatingProvider = StateNotifierProvider.family
  <RestaurantRatingStateNotifier, CursorPaginationBase, String>((ref, id) {
    final repository = ref.watch(restaurantRatingRepositoryProvider(id));
    return RestaurantRatingStateNotifier(repository: repository);
  }
);

class RestaurantRatingStateNotifier
    extends PaginationProvider<RatingModel, RestaurantRatingRepository> {
  RestaurantRatingStateNotifier({
    required super.repository
  });
}