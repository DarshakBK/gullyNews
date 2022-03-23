import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:gully_news/handlers/handler.dart';
import 'package:gully_news/models/newsData.dart';
import 'package:gully_news/resources/resources.dart';
import 'package:gully_news/screens/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:video_player/video_player.dart';

class AddNewsScreen extends StatefulWidget {
  static const route = '/Add-News-Screen';

  const AddNewsScreen({Key? key}) : super(key: key);

  @override
  _AddNewsScreenState createState() => _AddNewsScreenState();
}

class _AddNewsScreenState extends State<AddNewsScreen> {
  final TextEditingController _newsController = TextEditingController();
  final TextEditingController _headLineController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  bool newsListen = false;
  bool headlineListen = false;
  bool stateListen = false;
  bool cityListen = false;
  bool detailsListen = false;

  bool _isSelectDateTime = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final _newsSpeech = SpeechToText();
  final _headlineSpeech = SpeechToText();
  final _stateSpeech = SpeechToText();
  final _citySpeech = SpeechToText();
  final _detailsSpeech = SpeechToText();

  var _onUpdateControllerTime;
  Duration? _duration;
  Duration? _position;
  var _progress = 0.0;
  bool isPlaying = false;
  bool disposed = false;

  File? _pickedFile;
  ImagePicker picker = ImagePicker();
  VideoPlayerController? _videoPlayerController;

  List<AssetEntity> assets = [];

  DatabaseHelper helper = DatabaseHelper();
  NewsData newsModel = NewsData('', '', '');

  Future<bool> toggleRecording({
    required SpeechToText speechToText,
    required Function(String text) onResult,
    required ValueChanged<bool> onListening,
  }) async {
    if (speechToText.isListening) {
      speechToText.stop();
      return true;
    }

    print('---available----${speechToText.isListening}');
    final isAvailable = await speechToText.initialize(
      onStatus: (status) => onListening(speechToText.isListening),
      onError: (e) => print('Error: $e'),
    );

    if (isAvailable) {
      speechToText.listen(onResult: (value) => onResult(value.recognizedWords));
    }
    print('---available----$isAvailable');
    return isAvailable;
  }

  Future<bool?> _toggleRecording(
      TextEditingController controller, SpeechToText speech, bool isListen) async {
    await toggleRecording(
      speechToText: speech,
      onResult: (text) => setState(() => controller.text = text),
      onListening: (isListened) {
        setState(() {
          isListen = isListened;
          // if (controller == _newsController) {
          //   newsListen = isListened;
          // }
          // if (controller == _headLineController) {
          //   headlineListen = isListened;
          // }
          // if (controller == _stateController) {
          //   stateListen = isListened;
          // }
          // if (controller == _cityController) {
          //   cityListen = isListened;
          // }
          // if (controller == _detailsController) {
          //   detailsListen = isListened;
          // }
        });
      },
    );
  }

  Widget textField(String hintText, TextEditingController controller,
      SpeechToText speech, bool isListen,
      [int? length]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: (hintText == 'Add State' || hintText == 'Add City')
              ? deviceHeight(context) * 0.06
              : deviceHeight(context) * 0.09,
          width: deviceWidth(context) * 0.7,
          child: TextFormField(
            controller: controller,
            maxLength: length,
            decoration: InputDecoration(
                filled: true,
                fillColor: colorGrey.withOpacity(0.11),
                hintText: hintText,
                hintStyle: textStyle14Bold(colorBlack.withOpacity(0.4)),
                enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: colorBlue2A4),
                    borderRadius: BorderRadius.circular(7)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: colorBlue2A4),
                  borderRadius: BorderRadius.circular(7),
                ),
                border: InputBorder.none),
            keyboardType: TextInputType.text,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _toggleRecording(controller, speech, isListen);
            });
          },
          child: Container(
            height: deviceHeight(context) * 0.06,
            width: deviceWidth(context) * 0.17,
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: colorBlue2A4),
                borderRadius: BorderRadius.circular(7),
                color: Colors.grey.shade200),
            child: AvatarGlow(
              animate: isListen,
              endRadius: 20,
              glowColor: Theme.of(context).primaryColor,
              child: Image.asset(isListen ? icAudio : icAudioNon,
                  width: deviceWidth(context) * 0.03),
            ),
          ),
        ),
      ],
    );
  }

  void _presentDatePicker() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now())
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    }).whenComplete(_presentTimePicker);
  }

  _presentTimePicker() {
    showTimePicker(
            context: context,
            initialTime: TimeOfDay(
                hour: DateTime.now().hour, minute: DateTime.now().minute))
        .then((pickedTime) {
      if (pickedTime == null) {
        return;
      }
      setState(() {
        _selectedTime = pickedTime;
        _isSelectDateTime = true;
      });
    });
  }

  _takePicture() async {
    _pickedFile = null;
    final imageFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (imageFile == null) {
      return;
    }
    setState(() {
      _pickedFile = File(imageFile.path);
    });
    Navigator.of(context).pop();
  }

  _getImageFromGallery() async {
    _pickedFile = null;
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = File(pickedFile.path);
      });
    }
    Navigator.of(context).pop();
  }

  _takeVideo() async {
    _pickedFile = null;
    final pickedFile = await picker.pickVideo(source: ImageSource.camera);
    _pickedFile = File(pickedFile!.path);
    setState(() {});
    _videoPlayerController = VideoPlayerController.file(_pickedFile!)
      ..initialize().then((_) {
        _videoPlayerController!.addListener(_onControllerUpdate);
        _videoPlayerController!.play();
        setState(() {});
      });
    Navigator.of(context).pop();
  }

  _fetchAssets() async {
    final albums = await PhotoManager.getAssetPathList(onlyAll: true);
    final recentAlbum = albums.first;
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0,
      end: 1000000,
    );
    setState(() => assets = recentAssets);
  }

  _getVideoFromGallery() async {
    _pickedFile = null;
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    _pickedFile = File(pickedFile!.path);
    setState(() {});
    _videoPlayerController = VideoPlayerController.file(_pickedFile!)
      ..initialize().then((_) {
        _videoPlayerController!.addListener(_onControllerUpdate);
        _videoPlayerController!.play();
        setState(() {});
      });
    Navigator.of(context).pop();
  }

  void _onControllerUpdate() async {
    _onUpdateControllerTime = 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_onUpdateControllerTime > now) {
      return;
    }
    _onUpdateControllerTime = now + 500;

    final controller = _videoPlayerController;
    if (controller == null) {
      debugPrint('controller is null');
      return;
    }
    if (!controller.value.isInitialized) {
      debugPrint('controller can not be initialized');
      return;
    }

    if (_duration == null) {
      _duration = _videoPlayerController!.value.duration;
    }
    var duration = _duration;
    if (duration == null) {
      return;
    }

    var position = await controller.position;
    _position = position!;
    final playing = controller.value.isPlaying;
    if (playing) {
      if (disposed) {
        return;
      }
      setState(() {
        _progress = position.inMilliseconds.ceilToDouble() /
            duration.inMilliseconds.ceilToDouble();
      });
    }
    isPlaying = playing;
  }

  String convertTwo(int value) {
    return value < 10 ? '0$value' : '$value';
  }

  Widget _controlView() {
    final duration = _duration?.inSeconds ?? 0;
    final position = _position?.inSeconds ?? 0;
    final remained = max(0, duration - position);
    final mins = convertTwo(remained ~/ 60.0);
    final secs = convertTwo(remained % 60);
    return Row(
      children: [
        SizedBox(width: deviceWidth(context) * 0.01),
        SliderTheme(
            data: SliderTheme.of(context).copyWith(
                activeTrackColor: colorBlue2A4,
                inactiveTrackColor: colorWhite,
                trackShape: const RoundedRectSliderTrackShape(),
                trackHeight: 2.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayColor: colorBlue2A4.withAlpha(32),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 2),
                tickMarkShape: const RoundSliderTickMarkShape(),
                activeTickMarkColor: colorBlue2A4,
                inactiveTickMarkColor: colorBlue2A4.withOpacity(0.3),
                valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                valueIndicatorColor: colorBlue2A4.withOpacity(0.1),
                valueIndicatorTextStyle: textStyle14(colorWhite)),
            child: Slider(
              value: max(0, min(_progress * 100, 100)),
              min: 0,
              max: 100,
              divisions: 100,
              label: _position.toString().split('.')[0],
              onChanged: (value) {
                setState(() {
                  _progress = value * 0.01;
                });
              },
              onChangeStart: (value) {
                _videoPlayerController!.pause();
              },
              onChangeEnd: (value) {
                final duration = _videoPlayerController!.value.duration;
                if (duration != null) {
                  var newValue = max(0, min(value, 99)) * 0.01;
                  var millis = (duration.inMilliseconds * newValue).toInt();
                  _videoPlayerController!
                      .seekTo(Duration(milliseconds: millis));
                }
                _videoPlayerController!.play();
              },
            )),
        SizedBox(width: deviceWidth(context) * 0.015),
        Text(
          '$mins:$secs',
          style: textStyle12(colorWhite).copyWith(shadows: [
            const Shadow(
                offset: Offset(0.0, 1.0),
                blurRadius: 4.0,
                color: Color.fromARGB(150, 0, 0, 0))
          ]),
        )
      ],
    );
  }

  // void changeToSecond(int second) {
  //   Duration newDuration = Duration(seconds: second);
  //   _videoPlayerController!.seekTo(newDuration);
  // }

  cameraGalley(String icon, String title, Function() onClick) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
            onTap: onClick,
            child: Image.asset(icon,
                color: colorBlue2A4, width: deviceWidth(context) * 0.08)),
        SizedBox(height: deviceHeight(context) * 0.005),
        Text(title, style: textStyle14())
      ],
    );
  }

  bottomSheet() {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: deviceHeight(context) * 0.1,
            color: colorBlue2A4.withOpacity(0.11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                cameraGalley(icCamera, 'Camera', _takePicture),
                cameraGalley(icVideo, 'Video', _takeVideo),
                cameraGalley(icGallery, 'Gallery', bottomGallerySheet),
                // cameraGalley(icGallery, 'Gallery', _getVideoFromGallery),
              ],
            ),
          );
        });
  }

  bottomGallerySheet() async{
    await _fetchAssets();
    Navigator.of(context).pop();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      isScrollControlled: true,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        ),
        child: Container(
          color: colorWhite,
          height: deviceHeight(context) * 0.7,
          child: Stack(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            children: [
              GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2
                ),
                itemCount: assets.length,
                itemBuilder: (_, index) {
                  return FutureBuilder<Uint8List?>(
                    future: assets[index].thumbnailData,
                    builder: (_, snapshot) {
                      final bytes = snapshot.data;
                      if (bytes == null) {
                        return Container(
                            color: colorGrey.withOpacity(0.3),
                            child: Center(child: SizedBox(
                                height: deviceHeight(context) * 0.02,
                                width: deviceWidth(context) * 0.04,
                                child: const CircularProgressIndicator(strokeWidth: 2))));
                      }
                      return FutureBuilder<File?>(
                              future: assets[index].file,
                              builder: (_, snapshot) {
                                final file = snapshot.data;
                                if (file == null) return Container();
                                return InkWell(
                                    onTap: (){
                                        if (assets[index].type == AssetType.image) {
                                          setState((){
                                            _pickedFile = file;
                                          });
                                        }
                                        else{
                                          setState(() {});
                                          _pickedFile = file;
                                          _videoPlayerController = VideoPlayerController.file(_pickedFile!)
                                            ..initialize().then((_) {
                                              _videoPlayerController!.addListener(_onControllerUpdate);
                                              _videoPlayerController!.play();
                                              setState(() {});
                                            });
                                        }
                                      Navigator.of(context).pop();
                                    },
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child:
                                        Image.memory(bytes, fit: BoxFit.cover),
                                      ),
                                      if (assets[index].type == AssetType.video)
                                        Center(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                                color: Colors.blue,
                                                shape: BoxShape.circle),
                                            child: const Icon(
                                              Icons.play_arrow,
                                              size: 17,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),);
                              },
                            );
                    },
                  );
                },
              ),
              Positioned(
                right: deviceWidth(context) * 0.035,
                top: deviceHeight(context) * 0.01,
                child: GestureDetector(
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: deviceHeight(context) * 0.07,
                    width: deviceWidth(context) * 0.07,
                    decoration: const BoxDecoration(
                        color: colorWhite,
                        shape: BoxShape.circle),
                    child: const Center(
                        child: Icon(Icons.close,
                            color: colorBlack,
                            size: 20)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    disposed = true;
    _videoPlayerController!.pause();
    _videoPlayerController!.dispose();
    _videoPlayerController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
        child: Scaffold(
      body: Column(
        children: [
          SizedBox(height: deviceHeight(context) * 0.03),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: deviceWidth(context) * 0.05),
            child: Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Image.asset(icSqrBack,
                        width: deviceWidth(context) * 0.06)),
                const Spacer(),
                Text('News', style: textStyle18Bold(colorBlue2A4)),
                const Spacer(),
                SizedBox(width: deviceWidth(context) * 0.06)
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: deviceHeight(context) * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: deviceHeight(context) * 0.2,
                        width: deviceWidth(context) * 0.15,
                        decoration: BoxDecoration(
                            color: colorGrey.withOpacity(0.11),
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(5),
                                bottomRight: Radius.circular(5))),
                      ),
                      if (_pickedFile == null)
                        Container(
                          height: deviceHeight(context) * 0.3,
                          width: deviceWidth(context) * 0.6,
                          decoration: BoxDecoration(
                              color: colorGrey.withOpacity(0.11),
                              borderRadius: BorderRadius.circular(5)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: bottomSheet,
                                child: Image.asset(icADD,
                                    color: colorBlue2A4,
                                    width: deviceWidth(context) * 0.1),
                              ),
                              SizedBox(
                                height: deviceHeight(context) * 0.02,
                              ),
                              Text('Add Photos or Videos',
                                  style:
                                      textStyle12(colorBlack.withOpacity(0.4)))
                            ],
                          ),
                        ),
                      if (_pickedFile != null)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: deviceHeight(context) * 0.3,
                                  width: deviceWidth(context) * 0.6,
                                  decoration: BoxDecoration(
                                      color: colorGrey.withOpacity(0.11),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: _pickedFile
                                            .toString()
                                            .contains('.mp4')
                                        ? (_videoPlayerController != null &&
                                                _videoPlayerController!
                                                    .value.isInitialized
                                            ? AspectRatio(
                                                aspectRatio:
                                                    _videoPlayerController!
                                                        .value.aspectRatio,
                                                child: VideoPlayer(
                                                    _videoPlayerController!))
                                            : Container())
                                        : Image.file(_pickedFile!,
                                            fit: BoxFit.fill),
                                  ),
                                ),
                                if (_pickedFile.toString().contains('.mp4'))
                                  Positioned(
                                    top: deviceHeight(context) * 0.1,
                                    left: deviceWidth(context) * 0.265,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isPlaying == false) {
                                            _videoPlayerController!.play();
                                            setState(() {
                                              isPlaying = true;
                                            });
                                          } else if (isPlaying == true) {
                                            _videoPlayerController!.pause();
                                            setState(() {
                                              isPlaying = false;
                                            });
                                          }
                                        });
                                      },
                                      child: Container(
                                        height: deviceHeight(context) * 0.07,
                                        width: deviceWidth(context) * 0.07,
                                        decoration: BoxDecoration(
                                            color: colorWhite.withOpacity(0.5),
                                            shape: BoxShape.circle),
                                        child: Center(
                                          child: Icon(
                                            isPlaying == false
                                                ? Icons.play_arrow
                                                : Icons.pause,
                                            size: 19,
                                            color: colorBlack,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (_pickedFile.toString().contains('.mp4'))
                                  Positioned(
                                    bottom: deviceHeight(context) * 0.012,
                                    child: _controlView()),
                              ],
                            ),
                            Positioned(
                              top: -deviceHeight(context) * 0.04,
                              right: -deviceWidth(context) * 0.031,
                              child: GestureDetector(
                                onTap: bottomSheet,
                                child: Container(
                                  height: deviceHeight(context) * 0.09,
                                  width: deviceWidth(context) * 0.09,
                                  decoration: BoxDecoration(
                                      color: colorWhite,
                                      border: Border.all(
                                          color: colorBlue2A4,
                                          width: deviceWidth(context) * 0.003),
                                      shape: BoxShape.circle),
                                  child: Center(
                                      child: Image.asset(icEdit,
                                          color: colorBlue2A4,
                                          width: deviceWidth(context) * 0.04)),
                                ),
                              ),
                            )
                          ],
                        ),
                      Container(
                        height: deviceHeight(context) * 0.2,
                        width: deviceWidth(context) * 0.15,
                        decoration: BoxDecoration(
                            color: colorGrey.withOpacity(0.11),
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5),
                                bottomLeft: Radius.circular(5))),
                      )
                    ],
                  ),
                  SizedBox(height: deviceHeight(context) * 0.03),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: deviceWidth(context) * 0.05),
                    child: Column(
                      children: [
                        textField('News', _newsController, _newsSpeech,
                            newsListen, 100),
                        SizedBox(
                          height: deviceHeight(context) * 0.025,
                        ),
                        textField('Add Headline', _headLineController,
                            _headlineSpeech, headlineListen, 300),
                        SizedBox(
                          height: deviceHeight(context) * 0.025,
                        ),
                        textField('Add State', _stateController, _stateSpeech,
                            stateListen),
                        SizedBox(
                          height: deviceHeight(context) * 0.04,
                        ),
                        textField('Add City', _cityController, _citySpeech,
                            cityListen),
                        SizedBox(
                          height: deviceHeight(context) * 0.04,
                        ),
                        Container(
                            height: deviceHeight(context) * 0.06,
                            width: deviceWidth(context),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: colorBlue2A4,
                                    width: deviceWidth(context) * 0.0025),
                                borderRadius: BorderRadius.circular(7),
                                color: colorGrey.withOpacity(0.11)),
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: deviceWidth(context) * 0.026),
                              child: GestureDetector(
                                onTap: _presentDatePicker,
                                child: Text(
                                  _isSelectDateTime
                                      ? DateFormat()
                                              .add_yMd()
                                              .format(_selectedDate!) +
                                          ', ${_selectedTime!.hour > 12 ? _selectedTime!.hour - 12 : _selectedTime!.hour}:${_selectedTime!.minute} ${_selectedTime!.period.name}'
                                      : 'Add Date & Time',
                                  style: _isSelectDateTime
                                      ? textStyle14Medium(colorBlack)
                                      : textStyle14Bold(
                                          colorBlack.withOpacity(0.4),
                                        ),
                                ),
                              ),
                            )),
                        SizedBox(
                          height: deviceHeight(context) * 0.04,
                        ),
                        textField('More Details', _detailsController,
                            _detailsSpeech, detailsListen),
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
                            onPressed: () {
                              setState(() {
                                newsModel.picture = _pickedFile!.path;
                                newsModel.date = DateFormat()
                                    .add_yMd()
                                    .format(_selectedDate!);
                                newsModel.time =  '${_selectedTime!.hour > 12 ? _selectedTime!.hour - 12 : _selectedTime!.hour}:${_selectedTime!.minute} ${_selectedTime!.period.name}';
                                print('-===newsModel------$newsModel');
                                helper.insertTodo(newsModel);
                              });
                              print('--=videoController----$_videoPlayerController');
                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: deviceHeight(context) * 0.003),
                              child: Text(
                                'Submit',
                                style: textStyle18Bold(),
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
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

// newsRecord() =>
//     SpeechApi.newsRecording(
//       onResult: (text) => setState(() => _newsController.text = text),
//       onListening: (isListened) {
//         print('----isListened-----$isListened');
//         setState(() {
//           newsListen = isListened;
//         });
//         print('----isListen-----$isListened');
//       },
//     );
//
// headlineRecord() =>
//     SpeechApi.headlineRecording(
//       onResult: (text) => setState(() => _headLineController.text = text),
//       onListening: (isListened) {
//         print('----isListened-----$isListened');
//         setState(() {
//           headlineListen = isListened;
//         });
//         print('----isListen-----$isListened');
//       },
//     );
//
// stateRecord() =>
//     SpeechApi.stateRecording(
//       onResult: (text) => setState(() => _stateController.text = text),
//       onListening: (isListened) {
//         print('----isListened-----$isListened');
//         setState(() {
//           stateListen = isListened;
//         });
//         print('----isListen-----$isListened');
//       },
//     );
//
// cityRecord() =>
//     SpeechApi.cityRecording(
//       onResult: (text) => setState(() => _cityController.text = text),
//       onListening: (isListened) {
//         print('----isListened-----$isListened');
//         setState(() {
//           cityListen = isListened;
//         });
//         print('----isListen-----$isListened');
//       },
//     );
//
// detailsRecord() =>
//     SpeechApi.detailsRecording(
//       onResult: (text) => setState(() => _detailsController.text = text),
//       onListening: (isListened) {
//         print('----isListened-----$isListened');
//         setState(() {
//           detailsListen = isListened;
//         });
//         print('----isListen-----$isListened');
//       },
//     );

//   Row(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   children: [
//     SizedBox(
//       height: deviceHeight(context) * 0.09,
//       width: deviceWidth(context) * 0.7,
//       child: TextFormField(
//         controller: _newsController,
//         maxLength: 100,
//         decoration: InputDecoration(
//             filled: true,
//             fillColor: colorGrey.withOpacity(0.11),
//             hintText: 'News',
//             hintStyle: textStyle14Bold(colorBlack.withOpacity(0.4)),
//             enabledBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: colorBlue2A4),
//                 borderRadius: BorderRadius.circular(7)),
//             focusedBorder: OutlineInputBorder(
//               borderSide: const BorderSide(color: colorBlue2A4),
//               borderRadius: BorderRadius.circular(7),
//             ),
//             border: InputBorder.none),
//         keyboardType: TextInputType.text,
//       ),
//     ),
//     GestureDetector(
//       onTap: ()=>toggleRecording(_newsController,newsListen),
//       child: Container(
//         height: deviceHeight(context) * 0.06,
//         width: deviceWidth(context) * 0.17,
//         decoration: BoxDecoration(
//             border: Border.all(width: 1, color: colorBlue2A4),
//             borderRadius: BorderRadius.circular(7),
//             color: Colors.grey.shade200),
//         child: AvatarGlow(
//           animate: newsListen,
//           endRadius: 20,
//           glowColor: Theme.of(context).primaryColor,
//           child: Image.asset(newsListen ? icAudio : icAudioNon,
//               width: deviceWidth(context) * 0.03),
//         ),
//       ),
//     ),
//   ],
// ),

// Row(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   children: [
//     SizedBox(
//       height: deviceHeight(context) * 0.09,
//       width: deviceWidth(context) * 0.7,
//       child: TextFormField(
//         controller: _headLineController,
//         maxLength: 100,
//         decoration: InputDecoration(
//             filled: true,
//             fillColor: colorGrey.withOpacity(0.11),
//             hintText: 'Add Headline',
//             hintStyle: textStyle14Bold(colorBlack.withOpacity(0.4)),
//             enabledBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: colorBlue2A4),
//                 borderRadius: BorderRadius.circular(7)),
//             focusedBorder: OutlineInputBorder(
//               borderSide: const BorderSide(color: colorBlue2A4),
//               borderRadius: BorderRadius.circular(7),
//             ),
//             border: InputBorder.none),
//         keyboardType: TextInputType.text,
//       ),
//     ),
//     GestureDetector(
//       onTap: ()=>toggleRecording(_headLineController,headlineListen),
//       child: Container(
//         height: deviceHeight(context) * 0.06,
//         width: deviceWidth(context) * 0.17,
//         decoration: BoxDecoration(
//             border: Border.all(width: 1, color: colorBlue2A4),
//             borderRadius: BorderRadius.circular(7),
//             color: Colors.grey.shade200),
//         child: AvatarGlow(
//           animate: headlineListen,
//           endRadius: 20,
//           glowColor: Theme.of(context).primaryColor,
//           child: Image.asset(headlineListen ? icAudio : icAudioNon,
//               width: deviceWidth(context) * 0.03),
//         ),
//       ),
//     ),
//   ],
// ),

// Row(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   children: [
//     SizedBox(
//       height: deviceHeight(context) * 0.06,
//       width: deviceWidth(context) * 0.7,
//       child: TextFormField(
//         controller: _stateController,
//         decoration: InputDecoration(
//             filled: true,
//             fillColor: colorGrey.withOpacity(0.11),
//             hintText: 'Add State',
//             hintStyle: textStyle14Bold(colorBlack.withOpacity(0.4)),
//             enabledBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: colorBlue2A4),
//                 borderRadius: BorderRadius.circular(7)),
//             focusedBorder: OutlineInputBorder(
//               borderSide: const BorderSide(color: colorBlue2A4),
//               borderRadius: BorderRadius.circular(7),
//             ),
//             border: InputBorder.none),
//         keyboardType: TextInputType.text,
//       ),
//     ),
//     GestureDetector(
//       onTap: ()=>toggleRecording(_stateController,stateListen),
//       child: Container(
//         height: deviceHeight(context) * 0.06,
//         width: deviceWidth(context) * 0.17,
//         decoration: BoxDecoration(
//             border: Border.all(width: 1, color: colorBlue2A4),
//             borderRadius: BorderRadius.circular(7),
//             color: Colors.grey.shade200),
//         child: AvatarGlow(
//           animate: stateListen,
//           endRadius: 20,
//           glowColor: Theme.of(context).primaryColor,
//           child: Image.asset(stateListen ? icAudio : icAudioNon,
//               width: deviceWidth(context) * 0.03),
//         ),
//       ),
//     ),
//   ],
// ),

// Row(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   children: [
//     SizedBox(
//       height: deviceHeight(context) * 0.06,
//       width: deviceWidth(context) * 0.7,
//       child: TextFormField(
//         controller: _cityController,
//         decoration: InputDecoration(
//             filled: true,
//             fillColor: colorGrey.withOpacity(0.11),
//             hintText: 'Add City',
//             hintStyle: textStyle14Bold(colorBlack.withOpacity(0.4)),
//             enabledBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: colorBlue2A4),
//                 borderRadius: BorderRadius.circular(7)),
//             focusedBorder: OutlineInputBorder(
//               borderSide: const BorderSide(color: colorBlue2A4),
//               borderRadius: BorderRadius.circular(7),
//             ),
//             border: InputBorder.none),
//         keyboardType: TextInputType.text,
//       ),
//     ),
//     GestureDetector(
//       onTap: ()=>toggleRecording(_cityController,cityListen),
//       child: Container(
//         height: deviceHeight(context) * 0.06,
//         width: deviceWidth(context) * 0.17,
//         decoration: BoxDecoration(
//             border: Border.all(width: 1, color: colorBlue2A4),
//             borderRadius: BorderRadius.circular(7),
//             color: Colors.grey.shade200),
//         child: AvatarGlow(
//           animate: cityListen,
//           endRadius: 20,
//           glowColor: Theme.of(context).primaryColor,
//           child: Image.asset(cityListen ? icAudio : icAudioNon,
//               width: deviceWidth(context) * 0.03),
//         ),
//       ),
//     ),
//   ],
// ),

// Row(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   children: [
//     SizedBox(
//       height: deviceHeight(context) * 0.09,
//       width: deviceWidth(context) * 0.7,
//       child: TextFormField(
//         controller: _detailsController,
//         maxLength: 100,
//         decoration: InputDecoration(
//             filled: true,
//             fillColor: colorGrey.withOpacity(0.11),
//             hintText: 'More Details',
//             hintStyle: textStyle14Bold(colorBlack.withOpacity(0.4)),
//             enabledBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: colorBlue2A4),
//                 borderRadius: BorderRadius.circular(7)),
//             focusedBorder: OutlineInputBorder(
//               borderSide: const BorderSide(color: colorBlue2A4),
//               borderRadius: BorderRadius.circular(7),
//             ),
//             border: InputBorder.none),
//         keyboardType: TextInputType.text,
//       ),
//     ),
//     GestureDetector(
//       onTap: ()=>toggleRecording(_detailsController,detailsListen),
//       child: Container(
//         height: deviceHeight(context) * 0.06,
//         width: deviceWidth(context) * 0.17,
//         decoration: BoxDecoration(
//             border: Border.all(width: 1, color: colorBlue2A4),
//             borderRadius: BorderRadius.circular(7),
//             color: Colors.grey.shade200),
//         child: AvatarGlow(
//           animate: detailsListen,
//           endRadius: 20,
//           glowColor: Theme.of(context).primaryColor,
//           child: Image.asset(detailsListen ? icAudio : icAudioNon,
//               width: deviceWidth(context) * 0.03),
//         ),
//       ),
//     ),
//   ],
// ),
