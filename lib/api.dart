import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'models/City.dart';
import 'models/states.dart';
import 'models/token.dart';

class Api{
  Future<Token?> fetchAndGetToken() async {
    const url = 'https://www.universal-tutorial.com/api/getaccesstoken';
    final response = await http.get(Uri.parse(url), headers: {
      'api-token':
      'EaqDHoLMwM1RpY6f1za8rM4jdz2O7zZKbmE2mPhm9nlX9j6P0SGQIwQ8l7OHDrfVt_I',
      'user-email': 'darshak@test.com'
    });
    final extractedData = tokenFromJson(response.body);
    if (extractedData == null) {
      return null;
    } else {
      return extractedData;
    }
  }

  Future<List<StateName>?> fetchAndGetStates() async {
    const url = 'https://www.universal-tutorial.com/api/states/India';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer ${token.authToken}',
    });
    final extractedData = stateFromJson(response.body);
    if (extractedData == null) {
      return null;
    } else {
      return extractedData;
    }
  }


}