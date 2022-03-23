import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gully_news/routes.dart';
import 'package:gully_news/screens/add_news_screen.dart';
import 'package:gully_news/screens/fill_details_screen.dart';
import 'package:gully_news/screens/home_screen.dart';
import 'package:gully_news/screens/login_screen.dart';
import 'package:gully_news/screens/profile_screen.dart';
import 'package:gully_news/screens/setting_screen.dart';
import 'package:gully_news/screens/welcome_screen.dart';

import 'handlers/preference.dart';

// List<CameraDescription> cameras = [];

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // try {
  //   cameras = await availableCameras();
  // } on CameraException catch (e) {
  //   logError(e.code, e.description);
  // }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // String? state;
  // String? city;
  //
  // _getState() async {
  //   setState(() {});
  //   var state = await SharedPreference().getState('state');
  //   setState(() {});
  //   state = state;
  // }
  //
  // _getCity() async {
  //   setState(() {});
  //   var city = await SharedPreference().getCity('city');
  //   setState(() {});
  //   city = city;
  // }

  @override
  Widget build(BuildContext context) {
    // _getState();
    // _getCity();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomeScreen(),
      routes: {
        LoginScreen.route: (ctx) => const LoginScreen(),
        FillDetailScreen.route: (ctx) => const FillDetailScreen(),
        HomeScreen.route: (ctx) => HomeScreen(),
        SettingScreen.route: (ctx) => const SettingScreen(),
        ProfileScreen.route: (ctx) => const ProfileScreen(),
        AddNewsScreen.route: (ctx) => const AddNewsScreen(),
      },
    );
  }
}
