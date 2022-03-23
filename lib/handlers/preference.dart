import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference{
  Future<void> storeValue(key,value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  getState(key) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? state = prefs.getString(key);
    print('------ssssss-----$state');
    return state;
  }

  getCity(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? city = prefs.getString(key);
    return city;
  }
}