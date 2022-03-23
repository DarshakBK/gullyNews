import 'package:flutter/material.dart';
import 'package:gully_news/resources/resources.dart';

class ProfileScreen extends StatefulWidget {
  static const route = '/Profile-Screen';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numController = TextEditingController();

  Widget icBackEdit(String icon, Function() onTap) {
    return GestureDetector(
        onTap: onTap,
        child: Image.asset(icon, width: deviceWidth(context) * 0.07));
  }

  Widget textField(String icon, String hintText,
      [TextEditingController? controller, TextInputType? type]) {
    return Container(
      height: deviceHeight(context) * 0.062,
      decoration: BoxDecoration(
          border: Border.all(
              color: colorBlue2A4, width: deviceHeight(context) * 0.0015),
          borderRadius: BorderRadius.circular(7),
          color: colorGrey.withOpacity(0.1)),
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(left: deviceWidth(context) * 0.05),
          child: (hintText == 'State' || hintText == 'City') ? Row(
            children: [
              Image.asset(icon,width: deviceWidth(context) * 0.042),
              SizedBox(width: deviceWidth(context) * 0.03),
              Text(hintText,style: textStyle14(Colors.black45))
            ],
          ) : TextFormField(
            controller: controller,
            decoration: InputDecoration(
                hintText: hintText,
                hintStyle: textStyle14(Colors.black45),
                border: InputBorder.none,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(right: deviceWidth(context) * 0.03),
                  child: Image.asset(icon),
                ),
                prefixIconConstraints: BoxConstraints.expand(
                    width: deviceWidth(context) * 0.07)),
            keyboardType: type,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: deviceWidth(context) * 0.06),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: deviceHeight(context) * 0.05),
                Row(
                  children: [
                    SizedBox(width: deviceWidth(context) * 0.05),
                    icBackEdit(icSqrBack, () {Navigator.of(context).pop();}),
                    const Spacer(),
                    icBackEdit(icSqrEdit, () {}),
                    SizedBox(width: deviceWidth(context) * 0.05),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: deviceHeight(context) * 0.038),
                      child: Container(
                        height: deviceHeight(context) * 0.14,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: colorGrey.withOpacity(0.2),
                                width: deviceWidth(context) * 0.015)),
                        child: Image.asset(icProfileUser, fit: BoxFit.fill),
                      ),
                    ),
                    textField(icName, 'Name', _nameController, TextInputType.name),
                    SizedBox(height: deviceHeight(context) * 0.03),
                    textField(icEmailID, 'Email Id', _emailController,
                        TextInputType.emailAddress),
                    SizedBox(height: deviceHeight(context) * 0.03),
                    textField(icMobNum, 'Mobile Number', _numController,
                        TextInputType.number),
                    SizedBox(height: deviceHeight(context) * 0.03),
                    textField(icState, 'State'),
                    SizedBox(height: deviceHeight(context) * 0.03),
                    textField(icCity, 'City'),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
