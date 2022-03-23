import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gully_news/handlers/handler.dart';
import 'package:gully_news/handlers/preference.dart';
import 'package:gully_news/models/newsData.dart';
import 'package:gully_news/resources/images.dart';
import 'package:gully_news/resources/resources.dart';
import 'package:gully_news/screens/profile_screen.dart';
import 'package:gully_news/screens/setting_screen.dart';
import 'package:gully_news/widgets/video_player_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:video_player/video_player.dart';

import '../models/City.dart';
import '../models/token.dart';
import 'add_news_screen.dart';

final List<String> dataList = [
  imgBlank,
  imgBlank,
  imgBlank,
  imgBlank,
  imgBlank
];

class HomeScreen extends StatefulWidget {
  static const route = '/Home-Screen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Token token = Token(authToken: '');

  String? _state;
  String? _city;
  bool isCity = true;
  bool isState = false;

  bool isHome = true;
  bool isHeadline = false;

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<NewsData>? newsData;
  int count = 0;

  bool isPlaying = false;
  var _onUpdateControllerTime;

  Widget titleIcon(String image, Function() onClick) {
    return GestureDetector(
        onTap: onClick,
        child: Image.asset(image, width: deviceWidth(context) * 0.08));
  }

  Widget complimentIcon(String icon, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {},
              child: Image.asset(icon, width: deviceWidth(context) * 0.05),
            ),
            SizedBox(width: deviceWidth(context) * 0.01),
            Padding(
              padding: EdgeInsets.only(top: deviceHeight(context) * 0.004),
              child: Text('0', style: textStyle10(colorBlack.withOpacity(0.3))),
            ),
          ],
        ),
        SizedBox(height: deviceHeight(context) * 0.003),
        Text(title, style: textStyle10Bold(colorBlack.withOpacity(0.3))),
      ],
    );
  }

  void updateNewsView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<NewsData>?> newsListFuture = databaseHelper.getNewsList();
      newsListFuture.then((newsList) {
        setState(() {
          newsData = newsList!;
          count = newsData!.length;
        });
      });
    });
  }

  _getState() async {
    setState(() {});
    var state = await SharedPreference().getState('state');
    setState(() {});
    _state = state;
  }

  _getCity() async {
    setState(() {});
    var city = await SharedPreference().getCity('city');
    setState(() {});
    _city = city;
  }

  @override
  void initState() {
    super.initState();
    _getState();
    _getCity();
  }

  void _onControllerUpdate(VideoPlayerController videoController,
      Duration _duration, Duration _position) async {
    print('---------helooo');
    _onUpdateControllerTime = 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_onUpdateControllerTime > now) {
      return;
    }
    _onUpdateControllerTime = now + 500;

    if (videoController == null) {
      debugPrint('controller is null');
      return;
    }
    if (!videoController.value.isInitialized) {
      debugPrint('controller can not be initialized');
      return;
    }

    final playing = videoController.value.isPlaying;
    if (playing) {
      setState(() {});
    }
    isPlaying = playing;
  }

  Widget newsDetails(int index) {
    print(
        '-----picture----${newsData![index].picture}');
    return Column(
      children: [
        SizedBox(height: deviceHeight(context) * 0.025),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(icUser, width: deviceWidth(context) * 0.07),
                SizedBox(width: deviceWidth(context) * 0.02),
                Text('Darshak Kakadiya', style: textStyle16Bold(colorBlack))
              ],
            ),
            Row(
              children: [
                Image.asset(icMoreVert, width: deviceWidth(context) * 0.06),
                SizedBox(width: deviceWidth(context) * 0.02),
              ],
            )
          ],
        ),
        SizedBox(height: deviceHeight(context) * 0.015),
        Container(
          height: deviceHeight(context) * 0.5,
          decoration: BoxDecoration(
              border: Border.all(
                  width: deviceWidth(context) * 0.0025,
                  color: colorBlack.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(17)),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: deviceWidth(context) * 0.03,
                      vertical: deviceHeight(context) * 0.01),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: deviceWidth(context) * 0.022),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Weather', style: textStyle14Bold()),
                            Text(
                                '${newsData![index].date!}, ${newsData![index].time!}',
                                style: textStyle12(colorBlack.withOpacity(0.3)))
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: deviceHeight(context) * 0.006),
                        child: VideoPlayerScreen(
                          path: newsData![index].picture!,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: deviceHeight(context) * 0.005,
                            horizontal: deviceWidth(context) * 0.015),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Weather Forecast for Today',
                                style: textStyle14Bold()),
                            Text(
                                'a b c d e f g h i j k l m n o p q r s t u v x y z',
                                style: textStyle12Bold(
                                    colorBlack.withOpacity(0.3))),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                height: deviceHeight(context) * 0.002,
                color: colorBlack.withOpacity(0.3),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: deviceHeight(context) * 0.008),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    complimentIcon(icLike, 'Like'),
                    complimentIcon(icDisLike, 'Dislike'),
                    complimentIcon(icComment, 'Comment'),
                    complimentIcon(icWhatsApp, 'Whatsapp'),
                    complimentIcon(icShare, 'Share'),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(height: deviceHeight(context) * 0.015),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (newsData == null) {
      newsData = <NewsData>[];
      setState(() {
        updateNewsView();
      });
    }

    if (kDebugMode) {
      print('==x=====--newsData-----$newsData');
    }
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: deviceWidth(context) * 0.035,
                  right: deviceWidth(context) * 0.035,
                  top: deviceHeight(context) * 0.02),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: deviceWidth(context) * 0.5,
                        child: FittedBox(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              value: _city,
                              hint: Text(_city!,
                                  style: textStyle16Bold(colorBlue2A4)),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _city = newValue!;
                                });
                              },
                              buttonDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: colorBlue2A4.withOpacity(0.6))),
                              dropdownWidth: deviceWidth(context) * 0.5,
                              dropdownMaxHeight: deviceHeight(context) * 0.65,
                              dropdownDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(color: colorBlue2A4)),
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: colorBlue2A4),
                              iconSize: 35,
                              scrollbarThickness: 5,
                              scrollbarRadius: const Radius.circular(5),
                              items: cities.map<DropdownMenuItem<String>>(
                                  (CityName value) {
                                return DropdownMenuItem<String>(
                                  value: value.cityName,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: deviceWidth(context) * 0.02),
                                    child: Text(value.cityName,
                                        style: textStyle14Bold(colorBlue2A4)),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: deviceWidth(context) * 0.3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            titleIcon(icSetting, () {
                              Navigator.of(context)
                                  .pushNamed(SettingScreen.route);
                            }),
                            titleIcon(icNotification, () {}),
                            titleIcon(icProfile, () {
                              Navigator.of(context)
                                  .pushNamed(ProfileScreen.route);
                            })
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: deviceHeight(context) * 0.017),
                  Container(
                    height: deviceHeight(context) * 0.06,
                    width: deviceWidth(context),
                    decoration: BoxDecoration(
                        color: colorGrey.withOpacity(0.11),
                        borderRadius: BorderRadius.circular(7)),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isCity = true;
                                  isState = false;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: isCity
                                        ? colorBlue2A4.withOpacity(0.13)
                                        : null,
                                    borderRadius: BorderRadius.circular(6)),
                                child: Center(
                                  child: Text(
                                    _city!,
                                    style: isCity
                                        ? textStyle16Bold(colorBlue2A4)
                                        : textStyle14Bold(
                                            colorBlack.withOpacity(0.45)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: deviceWidth(context) * 0.012),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isState = true;
                                  isCity = false;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: isState
                                        ? colorBlue2A4.withOpacity(0.13)
                                        : null,
                                    borderRadius: BorderRadius.circular(6)),
                                child: Center(
                                  child: Text(
                                    _state!,
                                    style: isState
                                        ? textStyle18Bold(colorBlue2A4)
                                        : textStyle14Bold(
                                            colorBlack.withOpacity(0.45)),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: deviceHeight(context) * 0.02),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        aspectRatio: 2,
                        enlargeCenterPage: true,
                      ),
                      items: List.generate(
                          dataList.length,
                          (index) => Container(
                                decoration: BoxDecoration(
                                    color: colorGrey.withOpacity(0.11),
                                    borderRadius: BorderRadius.circular(5.0)),
                              )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: deviceWidth(context) * 0.035,
                          right: deviceWidth(context) * 0.035),
                      child: Column(
                        children: List.generate(newsData!.length, (index) {
                          return newsDetails(index);
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        bottomNavigationBar: getBottomSheet(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          height: deviceHeight(context) * 0.08,
          decoration: BoxDecoration(
              color: colorBlue2A4,
              shape: BoxShape.circle,
              border: Border.all(color: colorWhite, width: 1),
              boxShadow: [
                BoxShadow(
                  color: colorBlue2A4.withOpacity(0.22),
                  offset: const Offset(2.0, 3.0),
                  blurRadius: 6.0,
                ),
                BoxShadow(
                  color: colorBlue2A4.withOpacity(0.22),
                  offset: const Offset(-2.0, 4.0),
                  blurRadius: 6.0,
                ),
              ]),
          child: Center(
              child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(AddNewsScreen.route);
                  },
                  child:
                      Image.asset(icADD, width: deviceWidth(context) * 0.06))),
        ),
      ),
    );
  }

  Widget getBottomSheet() {
    return Stack(
      children: [
        Container(
          height: deviceHeight(context) * 0.08,
          width: deviceWidth(context),
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: colorBlue2A4.withOpacity(0.11),
              offset: const Offset(0.0, -5.0),
              blurRadius: 6.0,
            )
          ]),
        ),
        Positioned(
          child: Container(
            height: deviceHeight(context) * 0.08,
            width: deviceWidth(context),
            color: colorWhite,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(width: deviceWidth(context) * 0.14),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isHome = true;
                              isHeadline = false;
                            });
                          },
                          child: Column(
                            children: [
                              Image.asset(
                                icHome,
                                color: isHome
                                    ? colorBlack
                                    : colorBlack.withOpacity(0.45),
                                width: deviceWidth(context) * 0.065,
                              ),
                              SizedBox(height: deviceHeight(context) * 0.004),
                              Text('Home',
                                  style: isHome
                                      ? textStyle12Bold(colorBlack)
                                      : textStyle10Bold(
                                          colorBlack.withOpacity(0.5)))
                            ],
                          ),
                        ),
                        if (isHome)
                          Image.asset(icRectangle,
                              width: deviceWidth(context) * 0.03)
                      ],
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isHeadline = true;
                              isHome = false;
                            });
                          },
                          child: Column(
                            children: [
                              Image.asset(
                                icHeadline,
                                color: isHeadline
                                    ? colorBlack
                                    : colorBlack.withOpacity(0.45),
                                width: deviceWidth(context) * 0.065,
                              ),
                              SizedBox(height: deviceHeight(context) * 0.004),
                              Text('Headline',
                                  style: isHeadline
                                      ? textStyle12Bold(colorBlack)
                                      : textStyle10Bold(
                                          colorBlack.withOpacity(0.5)))
                            ],
                          ),
                        ),
                        if (isHeadline)
                          Image.asset(icRectangle,
                              width: deviceWidth(context) * 0.03)
                      ],
                    ),
                    Container(width: deviceWidth(context) * 0.14),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
