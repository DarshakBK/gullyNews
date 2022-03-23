import 'package:flutter/material.dart';
import 'package:gully_news/resources/resources.dart';

class SettingScreen extends StatefulWidget {
  static const route = '/Setting-Screen';
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  Widget iconText(String icon, String title){
    return Row(
      children: [
        Container(
            height: deviceHeight(context) * 0.1,
            width: deviceWidth(context) * 0.12,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorGrey.withOpacity(0.11)
            ),
            child: Center(child: Image.asset(icon,width: icon == icAboutUs ? deviceWidth(context) * 0.028 : deviceWidth(context) * 0.05))),
        SizedBox(width: deviceWidth(context) * 0.06),
        Text(title, style: textStyle16Bold(colorBlue2A4))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: deviceHeight(context),
              width: deviceWidth(context),
              color: colorBlue2A4.withOpacity(0.08),
            ),
            Image.asset(icDesignBG,height: deviceHeight(context) * 0.2, width: deviceWidth(context),fit: BoxFit.fill),
            Positioned(
              top: deviceHeight(context) * 0.065,
                left: deviceWidth(context) * 0.08,
                child: Row(
              children: [
                GestureDetector(
                    onTap: (){
                      Navigator.of(context).pop();
                    },
                    child: Image.asset(icBack, color: colorWhite, width: deviceWidth(context) * 0.027)),
                SizedBox(width: deviceWidth(context) * 0.1),
                Text('Settings',style: textStyle24Bold(colorWhite))
              ],
            )),
            Padding(
              padding: EdgeInsets.only(top: deviceHeight(context) * 0.145,left: deviceWidth(context) * 0.06,right: deviceWidth(context) * 0.06),
              child: Container(
                height: deviceHeight(context),
                decoration: const BoxDecoration(
                  color: colorWhite,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10))
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(left: deviceWidth(context) * 0.06),
                    child: Column(
                      children: [
                        SizedBox(height: deviceHeight(context) * 0.02),
                        iconText(icRateUs, 'Rate Us'),
                        iconText(icPrivacy, 'Privacy'),
                        iconText(icSettingShare, 'Share'),
                        iconText(icMore, 'More'),
                        iconText(icVersion, 'Version'),
                        iconText(icFeedback, 'Feedback'),
                        iconText(icAboutUs, 'About Us')
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
