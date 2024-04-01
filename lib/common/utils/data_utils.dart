import 'dart:convert';

import 'package:delivery/common/const/data.dart';

class DataUtils {

  static String pathToUrl(String thumbUrl) {
    return 'http://$ip$thumbUrl';
  }

  static List<String> listPathToUrls(List paths) {
    return paths.map((e) => pathToUrl(e)).toList();
  }

  static String plainToBase64(String plain) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    return stringToBase64.encode(plain);
  }

  static DateTime stringToDateTime(String value){
    return DateTime.parse(value);
  }
}