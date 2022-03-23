import 'package:flutter/material.dart';
import 'package:gully_news/models/token.dart';
import 'package:gully_news/resources/images.dart';
import 'package:gully_news/resources/resources.dart';
import 'package:gully_news/screens/login_screen.dart';

import '../api.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  @override
  void initState() {
    super.initState();
    Api().fetchAndGetToken().then((value) => token = value!);
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: deviceHeight(context) * 0.2),
              Image.asset(imgWelcome,width: deviceWidth(context) * 0.7),
              SizedBox(height: deviceHeight(context) * 0.05),
              Text(
                'Gully News',
                style: textStyle28Bold(colorBlue2A4),
              ),
              SizedBox(height: deviceHeight(context) * 0.007),
              Expanded(
                child: Text(
                  'Local updates on crime, politics and news',
                  style: textStyle14(Colors.black45),
                ),
              ),
              Container(
                height: deviceHeight(context) * 0.07,
                width: deviceWidth(context) * 0.5,
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: colorBlue2A4.withOpacity(0.3),
                    offset: const Offset(0.0, 7.0),
                    blurRadius: 6.0,
                  ),
                ]),
                child: TextButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.of(context).pushNamed(LoginScreen.route);
                  },
                  child: Text(
                    'Get Started',
                    style: textStyle20(),
                  ),
                  style: TextButton.styleFrom(
                      primary: colorWhite,
                      backgroundColor: colorBlue2A4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                ),
              ),
              SizedBox(height: deviceHeight(context) * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
