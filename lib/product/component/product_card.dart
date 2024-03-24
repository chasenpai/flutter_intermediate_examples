import 'dart:ui';

import 'package:delivery/common/const/colors.dart';
import 'package:delivery/restaurant/model/restaurant_detail_model.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {

  final Image image;
  final String name;
  final String detail;
  final int price;

  const ProductCard({
    super.key,
    required this.image,
    required this.name,
    required this.detail,
    required this.price,
  });

  factory ProductCard.fromModel({
    required RestaurantProductModel model,
  }) {
    return ProductCard(
      image: Image.network(
        model.imgUrl,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
      ),
      name: model.name,
      detail: model.detail,
      price: model.price,
    );
  }

  @override
  Widget build(BuildContext context) {
    //로우안의 자식 위젯은 각각의 고유 높이를 갖는다
    //IntrinsicHeight를 사용하면 내부에 있는 모든 위젯들이 최대 크기를 차지한 위젯만큼 크기를 차지하게 된다
    //반대는 IntrinsicWidth
    return IntrinsicHeight(
      child: Row(
         children: [
           ClipRRect(
             borderRadius: BorderRadius.circular(8.0,),
             child: image,
           ),
           const SizedBox(width: 16.0,),
           Expanded(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                 Text(
                   name,
                   style: TextStyle(
                     fontSize: 18.0,
                     fontWeight: FontWeight.w500,
                   ),
                 ),
                 Text(
                   detail,
                   overflow: TextOverflow.ellipsis, //글자가 넘어가면 ...으로 표시
                   style: TextStyle(
                     color: BODY_TEXT_COLOR,
                     fontSize: 14.0,
                   ),
                 ),
                 Text(
                   '$price원',
                   style: TextStyle(
                     color: PRIMARY_COLOR,
                     fontSize: 12.0,
                     fontWeight: FontWeight.w500,
                   ),
                   textAlign: TextAlign.right,
                 ),
               ],
             )
           )
         ],
      ),
    );
  }
}
