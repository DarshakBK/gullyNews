import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gully_news/resources/resources.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String path;

  const VideoPlayerScreen(
      {required this.path});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  Duration? _duration;
  Duration? _position;
  // Future<void>? _initializeVideoPlayerFeature;
  var _progress = 0.0;
  bool isPlaying = false;
  bool disposed = false;
  var _onUpdateControllerTime;

  String convertTwo(int value) {
    return value < 10 ? '0$value' : '$value';
  }

  Widget _controlView() {
    final duration = _duration?.inSeconds ?? 0;
    final position = _position?.inSeconds ?? 0;
    final remained = max(0, duration - position);
    final mins = convertTwo(remained ~/ 60.0);
    final secs = convertTwo(remained % 60);
    return Text(
      '$mins:$secs',
      style: textStyle12(colorWhite).copyWith(shadows: [
        const Shadow(
            offset: Offset(0.0, 1.0),
            blurRadius: 4.0,
            color: Color.fromARGB(150, 0, 0, 0))
      ]),
    );
  }

  void _onControllerUpdate() async {
    _onUpdateControllerTime = 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_onUpdateControllerTime > now) {
      return;
    }
    _onUpdateControllerTime = now + 500;

    final controller = _controller;
    if (controller == null) {
      debugPrint('controller is null');
      return;
    }
    if (!controller.value.isInitialized) {
      debugPrint('controller can not be initialized');
      return;
    }

    _duration ??= _controller!.value.duration;
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
        _progress = _position!.inMilliseconds.ceilToDouble() /
            duration.inMilliseconds.ceilToDouble();
      });
    }
    isPlaying = playing;
  }

  Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    int micros = 0;

    List<String> parts = s.split(':');
    print('-----parts=====$parts');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }

    List<String> part = parts[parts.length - 1].split('.');
    print('----part----$part');
    if (part.length > 1) {
      seconds = int.parse(part[part.length - 2]);
      print('----seconds----$seconds');
    }
    if (parts.length > 0) {
      micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    }
    return Duration(
        hours: hours, minutes: minutes, seconds: seconds, microseconds: micros);
  }

  @override
  void initState() {
    _controller = VideoPlayerController.file(File(path))
      ..initialize().then((_) {
        _controller!.addListener(_onControllerUpdate);
        _controller!.play();
        setState(() {});
      });
    print('------controller-----$_controller');
    // _initializeVideoPlayerFeature = _controller!.initialize().then((value) {
    //   {
    //     _controller!.addListener(_onControllerUpdate);
    //     _controller!.play();
    //     setState(() {});
    //   }
    // });
    _controller!.setLooping(false);
    super.initState();
  }

  @override
  void dispose() {
    disposed = true;
    _controller!.pause();
    _controller!.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: deviceHeight(context) * 0.25,
          width: deviceWidth(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: widget.path.contains('.mp4')
                ? (_controller != null && _controller!.value.isInitialized
                    ? AspectRatio(
                              aspectRatio: _controller!.value.aspectRatio,
                              child: VideoPlayer(_controller!),
                            )
                    : Container())
                : Image.file(File(widget.path), fit: BoxFit.fill),
          ),
        ),
        if (widget.path.contains('.mp4'))
          Positioned(
            top: deviceHeight(context) * 0.1,
            left: deviceWidth(context) * 0.4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isPlaying == false) {
                    _controller!.play();
                    setState(() {
                      isPlaying = true;
                    });
                  } else if (isPlaying == true) {
                    _controller!.pause();
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
                    color: colorWhite.withOpacity(0.5), shape: BoxShape.circle),
                child: Center(
                  child: Icon(
                    isPlaying == false ? Icons.play_arrow : Icons.pause,
                    size: 19,
                    color: colorBlack,
                  ),
                ),
              ),
            ),
          ),
        if (widget.path.contains('.mp4'))
          Positioned(
              top: deviceHeight(context) * 0.012,
              right: deviceWidth(context) * 0.012,
              child: _controlView()),
      ],
    );
  }
}

// FutureBuilder(
// future: _initializeVideoPlayerFeature,
// builder: (context, snapshot) {
// if (snapshot.connectionState == ConnectionState.done) {
// return AspectRatio(
// aspectRatio: _controller!.value.aspectRatio,
// child: VideoPlayer(_controller!),
// );
// }
// return const Center(child: CircularProgressIndicator());
// }
// );
