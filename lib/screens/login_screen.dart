import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gully_news/models/states.dart';
import 'package:gully_news/models/token.dart';
import 'package:gully_news/resources/resources.dart';

import '../api.dart';
import 'fill_details_screen.dart';

class LoginScreen extends StatefulWidget {
  static const route = '/Login-Screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numController = TextEditingController();

  Widget buildTextField(
      String title, String hintText, TextEditingController controller, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textStyle18Bold(colorBlack.withOpacity(0.9)),
        ),
        SizedBox(height: deviceHeight(context) * 0.01),
        Container(
          height: deviceHeight(context) * 0.065,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: colorGrey.withOpacity(0.11)),
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(left: deviceWidth(context) * 0.05),
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: textStyle16(colorBlack.withOpacity(0.45)),
                    border: InputBorder.none),
                keyboardType: type,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    Api().fetchAndGetStates().then((value) => states = value!);
  }

  @override
  Widget build(BuildContext context) {
    print('------token----${token.authToken}');
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: deviceWidth(context) * 0.06,
                      right: deviceWidth(context) * 0.06,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Log in',
                            style: textStyle32Bold(colorBlue2A4),
                          ),
                          Text(
                            'Please log in into your account',
                            style: textStyle18(Colors.black45),
                          ),
                        ],
                      ),
                      SizedBox(height: deviceHeight(context) * 0.06),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildTextField(
                                'Name', 'Enter your name', _nameController,TextInputType.name),
                            SizedBox(height: deviceHeight(context) * 0.045),
                            buildTextField('Mobile number',
                                'Enter your mobile number', _numController,TextInputType.number),
                          ],
                        ),
                      ),
                      SizedBox(height: deviceHeight(context) * 0.07),
                      Container(
                        width: deviceWidth(context),
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                            color: colorBlue2A4.withOpacity(0.3),
                            offset: const Offset(0.0, 7.0),
                            blurRadius: 6.0,
                          ),
                        ]),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              if(_formKey.currentState!.validate()) {
                                if (kDebugMode) {
                                  print('Login Successful');
                                }
                              } else {
                                if (kDebugMode) {
                                  print('Unsuccessful');
                                }
                              }
                            });
                            setState(() {});
                            Navigator.of(context).pushNamed(FillDetailScreen.route);
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: deviceHeight(context) * 0.003),
                            child: Text(
                              'Log in',
                              style: textStyle20Bold(),
                            ),
                          ),
                          style: TextButton.styleFrom(
                              primary: colorWhite,
                              backgroundColor: colorBlue2A4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                        ),
                      ),
                      SizedBox(height: deviceHeight(context) * 0.055),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: deviceHeight(context) * 0.001,
                            width: deviceWidth(context) * 0.35,
                            color: colorBlue2A4,
                          ),
                          Text('or', style: textStyle18(colorBlue2A4)),
                          Container(
                            height: deviceHeight(context) * 0.001,
                            width: deviceWidth(context) * 0.35,
                            color: colorBlue2A4,
                          ),
                        ],
                      ),
                      SizedBox(height: deviceHeight(context) * 0.05),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: deviceHeight(context) * 0.065,
                            width: deviceWidth(context) * 0.35,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(30),
                                    right: Radius.circular(30)),
                                border:
                                    Border.all(width: 1, color: colorBlue2A4)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(icGoogle,
                                    width: deviceWidth(context) * 0.09),
                                SizedBox(width: deviceWidth(context) * 0.019),
                                Text('Google', style: textStyle16(colorBlue2A4)),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                top: deviceHeight(context) * 0.055,
                right: -deviceWidth(context) * 0.005,
                child: Container(
                  height: deviceHeight(context) * 0.055,
                    width: deviceWidth(context) * 0.2,
                    decoration: BoxDecoration(
                      color: colorBlue2A4.withOpacity(0.05),
                      border: Border.all(width: 0.1,color: colorBlue2A4),
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(20))
                    ),
                    child: Center(child: Text('Skip', style: textStyle14(colorBlue2A4)))))
          ],
        ),
      ),
    );
  }
}
