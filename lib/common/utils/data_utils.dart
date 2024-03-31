import 'package:delivery/common/const/data.dart';

class DataUtils {

  static String pathToUrl(String thumbUrl) {
    return 'http://$ip$thumbUrl';
  }

  static List<String> listPathToUrls(List paths) {
    return paths.map((e) => pathToUrl(e)).toList();
  }
}