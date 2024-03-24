import 'package:delivery/common/const/data.dart';
import 'package:delivery/restaurant/component/restaurant_card.dart';
import 'package:delivery/restaurant/model/restaurant_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({super.key});

  Future<List> paginateRestaurant() async {
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    final dio = Dio();
    final response = await dio.get(
      'http://$ip/restaurant',
      options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          }
      ),
    );
    return response.data['data'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: FutureBuilder<List>(
          future: paginateRestaurant(),
          builder: (context, AsyncSnapshot<List> snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return ListView.separated(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = RestaurantModel.fromJson(json: snapshot.data![index],);
                return RestaurantCard.fromModel(model: item,);
              },
              separatorBuilder: (context, index) {
                return SizedBox(height: 16.0,);
              },
            );
          },
        ),
      ),
    );
  }
}
