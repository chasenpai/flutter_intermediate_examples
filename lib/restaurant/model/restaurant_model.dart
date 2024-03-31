import 'package:delivery/common/model/model_with_id.dart';
import 'package:delivery/common/utils/data_utils.dart';
import 'package:json_annotation/json_annotation.dart';

//flutter pub run build_runner build
//flutter pub run build_runner watch - 변경될 때 마다 자동 빌드
part 'restaurant_model.g.dart';

enum RestaurantPriceRange { expensive, medium, cheap }

@JsonSerializable() //Json 직렬화 자동
class RestaurantModel implements IModelWithId {

  @override
  final String id;
  final String name;
  @JsonKey(
    fromJson: DataUtils.pathToUrl, //직렬화 시 실행
  )
  final String thumbUrl;
  final List<String> tags;
  final RestaurantPriceRange priceRange;
  final double ratings;
  final int ratingsCount;
  final int deliveryTime;
  final int deliveryFee;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.thumbUrl,
    required this.tags,
    required this.priceRange,
    required this.ratings,
    required this.ratingsCount,
    required this.deliveryTime,
    required this.deliveryFee
  });

  //json -> model
  factory RestaurantModel.fromJson(Map<String, dynamic> json)
    => _$RestaurantModelFromJson(json);

  //model -> json
  Map<String, dynamic> toJson() => _$RestaurantModelToJson(this);

  //무조건 static
  // static pathToUrl(String thumbUrl) {
  //   return 'http://$ip$thumbUrl';
  // }

}
