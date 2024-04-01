import 'package:delivery/common/const/colors.dart';
import 'package:delivery/product/model/product_model.dart';
import 'package:delivery/restaurant/model/restaurant_detail_model.dart';
import 'package:delivery/user/provider/basket_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductCard extends ConsumerWidget {

  final Image image;
  final String name;
  final String detail;
  final int price;
  final VoidCallback? onSubtract;
  final VoidCallback? onAdd;
  final String productId;

  const ProductCard({
    super.key,
    required this.image,
    required this.name,
    required this.detail,
    required this.price,
    required this.productId,
    this.onSubtract,
    this.onAdd,
  });

  factory ProductCard.fromProductModel({
    required ProductModel model,
    VoidCallback? onSubtract,
    VoidCallback? onAdd,
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
      onSubtract: onSubtract,
      onAdd: onAdd,
      productId: model.id,
    );
  }

  factory ProductCard.fromRestaurantModel({
    required RestaurantProductModel model,
    VoidCallback? onSubtract,
    VoidCallback? onAdd,
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
      onSubtract: onSubtract,
      onAdd: onAdd,
      productId: model.id,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final basket = ref.watch(basketProvider);

    //로우안의 자식 위젯은 각각의 고유 높이를 갖는다
    //IntrinsicHeight를 사용하면 내부에 있는 모든 위젯들이 최대 크기를 차지한 위젯만큼 크기를 차지하게 된다
    //반대는 IntrinsicWidth
    return Column(
      children: [
        IntrinsicHeight(
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
        ),
        if(onSubtract != null && onAdd != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0,),
            child: _Footer(
              total: (basket.firstWhere((e) => e.product.id == productId).count *
                      basket.firstWhere((e) => e.product.id == productId).product.price)
                     .toString(),
              count: basket.firstWhere((e) => e.product.id == productId).count,
              onSubtract: onSubtract!,
              onAdd: onAdd!,
            ),
          ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {

  final String total;
  final int count;
  final VoidCallback onSubtract;
  final VoidCallback onAdd;

  const _Footer({
    required this.total,
    required this.count,
    required this.onSubtract,
    required this.onAdd,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '총액 $total원',
            style: TextStyle(
              color: PRIMARY_COLOR,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: [
            renderButton(
              icon: Icons.remove,
              onTap: onSubtract,
            ),
            const SizedBox(width: 8.0,),
            Text(
              count.toString(),
              style: TextStyle(
                color: PRIMARY_COLOR,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8.0,),
            renderButton(
              icon: Icons.add,
              onTap: onAdd,
            ),
          ],
        ),
      ],
    );
  }

  Widget renderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: PRIMARY_COLOR,
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Icon(
          icon,
          color: PRIMARY_COLOR,
        ),
      ),
    );
  }
}
