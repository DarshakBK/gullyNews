import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gully_news/api.dart';
import 'package:gully_news/handlers/preference.dart';
import 'package:gully_news/models/token.dart';
import 'package:http/http.dart' as http;
import 'package:gully_news/resources/resources.dart';

import '../models/City.dart';
import '../models/states.dart';
import 'home_screen.dart';

class FillDetailScreen extends StatefulWidget {
  static const route = '/Fill-Details';

  const FillDetailScreen({Key? key}) : super(key: key);

  @override
  _FillDetailScreenState createState() => _FillDetailScreenState();
}

class _FillDetailScreenState extends State<FillDetailScreen> {
  final TextEditingController _pinCodeController = TextEditingController();
  bool isStateOpen = false;
  bool isCityOpen = false;
  bool isPinOpen = false;
  String? stateDropdownValue;
  String? cityDropdownValue;

  void storeData() async {
    print('-----state----$stateDropdownValue');
    print('----city------$cityDropdownValue');
    await SharedPreference().storeValue('state', stateDropdownValue);
    await SharedPreference().storeValue('city', cityDropdownValue);
    Navigator.of(context).pushNamed(HomeScreen.route);
  }

  Future<List<CityName>?> fetchAndGetCities(String stateDropdownValue) async {
    var url =
        'https://www.universal-tutorial.com/api/cities/$stateDropdownValue';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer ${token.authToken}',
    });
    if (kDebugMode) {
      print('=====data of city====${response.body}');
    }
    final extractedData = cityFromJson(response.body);
    if (extractedData == null) {
      return null;
    } else {
      cities = extractedData;
      setState(() {});
      return cities;
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: deviceWidth(context) * 0.06,
                right: deviceWidth(context) * 0.06,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Details',
                        style: textStyle32Bold(colorBlue2A4),
                      ),
                      Text(
                        'Please fill the details',
                        style: textStyle18(Colors.black45),
                      ),
                    ],
                  ),
                  SizedBox(height: deviceHeight(context) * 0.1),
                  Container(
                    height: deviceHeight(context) * 0.065,
                    decoration: BoxDecoration(
                        border: isStateOpen
                            ? Border.all(color: colorBlue2A4, width: 1)
                            : null,
                        borderRadius: BorderRadius.circular(7),
                        color: colorGrey.withOpacity(0.15)),
                    child: Center(
                      child: Padding(
                        padding:
                            EdgeInsets.only(left: deviceWidth(context) * 0.05),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2(
                              value: stateDropdownValue,
                              hint: Text(
                                'Select States',
                                style: textStyle16(isStateOpen
                                    ? colorBlack
                                    : colorBlack.withOpacity(0.45)),
                              ),
                              onTap: () {
                                setState(() {
                                  isStateOpen = true;
                                  isCityOpen = false;
                                  isPinOpen = false;
                                });
                              },
                              onChanged: (String? newValue) {
                                setState(() {
                                  stateDropdownValue = newValue!;
                                });
                                fetchAndGetCities(stateDropdownValue!);
                                setState(() {});
                              },
                              dropdownMaxHeight: deviceHeight(context) * 0.45,
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: colorBlue2A4, size: 40),
                              items: states.map<DropdownMenuItem<String>>(
                                  (StateName value) {
                                return DropdownMenuItem<String>(
                                  value: value.stateName,
                                  child: SizedBox(
                                      width: deviceWidth(context) * 0.7,
                                      child: Text(value.stateName,
                                          style: textStyle16(isStateOpen
                                              ? colorBlack
                                              : colorBlack.withOpacity(0.45)))),
                                );
                              }).toList()),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: deviceHeight(context) * 0.03),
                  Container(
                    height: deviceHeight(context) * 0.065,
                    decoration: BoxDecoration(
                        border: isCityOpen
                            ? Border.all(color: colorBlue2A4, width: 1)
                            : null,
                        borderRadius: BorderRadius.circular(7),
                        color: colorGrey.withOpacity(0.15)),
                    child: Center(
                      child: Padding(
                        padding:
                            EdgeInsets.only(left: deviceWidth(context) * 0.05),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2(
                            value: cityDropdownValue,
                            hint: Text('Select City',
                                style: textStyle16(isCityOpen
                                    ? colorBlack
                                    : colorBlack.withOpacity(0.45))),
                            onTap: () {
                              setState(() {
                                isCityOpen = true;
                                isStateOpen = false;
                                isPinOpen = false;
                              });
                            },
                            onChanged: (String? newValue) {
                              setState(() {
                                cityDropdownValue = newValue!;
                              });
                            },
                            dropdownMaxHeight: deviceHeight(context) * 0.45,
                            icon: const Icon(Icons.arrow_drop_down,
                                color: colorBlue2A4, size: 40),
                            items: cities.map<DropdownMenuItem<String>>(
                                (CityName value) {
                              return DropdownMenuItem<String>(
                                value: value.cityName,
                                child: SizedBox(
                                    width: deviceWidth(context) * 0.7,
                                    child: Text(value.cityName,
                                        style: textStyle16(isCityOpen
                                            ? colorBlack
                                            : colorBlack.withOpacity(0.45)))),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: deviceHeight(context) * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('or', style: textStyle20Bold(colorBlue2A4)),
                    ],
                  ),
                  SizedBox(height: deviceHeight(context) * 0.03),
                  SizedBox(
                    height: deviceHeight(context) * 0.065,
                    child: TextFormField(
                      controller: _pinCodeController,
                      onTap: () {
                        setState(() {
                          isPinOpen = true;
                          isStateOpen = false;
                          isCityOpen = false;
                        });
                      },
                      decoration: InputDecoration(
                          hintText: 'Enter Pincode',
                          hintStyle: textStyle16(isPinOpen
                              ? colorBlack
                              : colorBlack.withOpacity(0.45)),
                          filled: true,
                          fillColor: colorGrey.withOpacity(0.15),
                          border: isPinOpen
                              ? OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide: const BorderSide(
                                      color: colorBlue2A4, width: 1))
                              : OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide: BorderSide.none)),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(height: deviceHeight(context) * 0.06),
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
                      onPressed: storeData,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: deviceHeight(context) * 0.003),
                        child: Text(
                          'SUBMIT',
                          style: textStyle20(),
                        ),
                      ),
                      style: TextButton.styleFrom(
                          primary: colorWhite,
                          backgroundColor: colorBlue2A4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                    ),
                  ),
                  SizedBox(height: deviceHeight(context) * 0.06),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
