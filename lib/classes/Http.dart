import 'package:health/config/constants.dart';
import 'package:http/http.dart' as http;

class Http {
  static Future<http.Response> post({String uri = '', headers, body}) async {
    var completeUrl = API_URL + '/' + uri;
    var url = Uri.parse(completeUrl);

    return await http.post(url, headers: headers, body: body);
  }
}
