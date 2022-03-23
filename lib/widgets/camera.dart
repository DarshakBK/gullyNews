// import 'dart:io';
//
// import 'package:camera/camera.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:video_player/video_player.dart';
//
// import '../main.dart';
//
// class CameraScreen extends StatefulWidget {
//   static const route = '/Camera';
//
//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }
//
// void logError(String code, String? message) {
//   if (message != null) {
//     print('Error: $code\nError Message: $message');
//   } else {
//     print('Error: $code');
//   }
// }
//
// class _CameraScreenState extends State<CameraScreen>
//     with WidgetsBindingObserver {
//   File? _imageFile;
//   File? _videoFile;
//
//   bool is43 = false;
//   bool isFullScreen = true;
//   bool is11 = false;
//
//   CameraController? controller;
//   double zoom = 1.0;
//   double _scaleFactor = 1.0;
//
//   VideoPlayerController? videoController;
//   VoidCallback? videoPlayerListener;
//
//   bool _isCameraInitialized = false;
//   final resolutionPresets = ResolutionPreset.values;
//   ResolutionPreset currentResolutionPreset = ResolutionPreset.high;
//
//   FlashMode? _currentFlashMode;
//
//   bool _isRearCameraSelected = false;
//
//   bool _isRecordingInProgress = false;
//   bool _isVideoCameraSelected = false;
//
//   Future<XFile?> takePicture() async {
//     final CameraController? cameraController = controller;
//     if (cameraController == null || !cameraController.value.isInitialized) {
//       return null;
//     }
//
//     if (cameraController.value.isTakingPicture) {
//       return null;
//     }
//     try {
//       XFile file = await cameraController.takePicture();
//       return file;
//     } on CameraException catch (e) {
//       _showCameraException(e);
//       return null;
//     }
//   }
//
//   Future<void> startVideoRecording() async {
//     final CameraController? cameraController = controller;
//
//     if (cameraController == null || !cameraController.value.isInitialized) {
//       return;
//     }
//
//     if (cameraController.value.isRecordingVideo) {
//       return;
//     }
//     try {
//       await cameraController.startVideoRecording();
//       setState(() {
//         _isRecordingInProgress = true;
//         print(_isRecordingInProgress);
//       });
//     } on CameraException catch (e) {
//       _showCameraException(e);
//       return;
//     }
//   }
//
//   Future<XFile?> stopVideoRecording() async {
//     final CameraController? cameraController = controller;
//     if (cameraController == null || !cameraController.value.isRecordingVideo) {
//       return null;
//     }
//     try {
//       setState(() {
//         _isRecordingInProgress = false;
//         print('==xx==xx==_isRecordingInProgress==xx===$_isRecordingInProgress');
//       });
//       return cameraController.stopVideoRecording();
//     } on CameraException catch (e) {
//       _showCameraException(e);
//       return null;
//     }
//   }
//
//   Future<void> pauseVideoRecording() async {
//     final CameraController? cameraController = controller;
//
//     if (cameraController == null || !cameraController.value.isRecordingVideo) {
//       return;
//     }
//     try {
//       await cameraController.pauseVideoRecording();
//     } on CameraException catch (e) {
//       _showCameraException(e);
//       rethrow;
//     }
//   }
//
//   Future<void> resumeVideoRecording() async {
//     final CameraController? cameraController = controller;
//
//     if (cameraController == null || !cameraController.value.isRecordingVideo) {
//       return;
//     }
//     try {
//       await cameraController.resumeVideoRecording();
//     } on CameraException catch (e) {
//       _showCameraException(e);
//       rethrow;
//     }
//   }
//
//   Future<void> _startVideoPlayer() async {
//     if (_videoFile == null) {
//       return;
//     }
//
//     final VideoPlayerController vController = kIsWeb
//         ? VideoPlayerController.network(_videoFile!.path)
//         : VideoPlayerController.file(_videoFile!);
//
//     videoPlayerListener = () {
//       if (videoController != null && videoController!.value.size != null) {
//         if (mounted) {
//           setState(() {});
//         }
//         videoController!.removeListener(videoPlayerListener!);
//       }
//     };
//
//     vController.addListener(videoPlayerListener!);
//     await vController.setLooping(false);
//     await vController.initialize();
//     await videoController?.dispose();
//     if (mounted) {
//       setState(() {
//         _imageFile = null;
//         videoController = vController;
//       });
//     }
//     await vController.play();
//   }
//
//   Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
//     if (controller != null) {
//       await controller!.dispose();
//     }
//
//     final CameraController cameraController = CameraController(
//       cameraDescription,
//       kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
//       imageFormatGroup: ImageFormatGroup.jpeg,
//     );
//
//     controller = cameraController;
//
//     cameraController.addListener(() {
//       if (mounted) {
//         setState(() {
//           controller = cameraController;
//         });
//       }
//     });
//
//
//     try {
//       await cameraController.initialize();
//     } on CameraException catch (e) {
//       _showCameraException(e);
//     }
//
//     if (mounted) {
//       setState(() {
//         _isCameraInitialized = controller!.value.isInitialized;
//       });
//     }
//
//     _currentFlashMode = controller!.value.flashMode;
//   }
//
//   void _showCameraException(CameraException e) {
//     logError(e.code, e.description);
//   }
//
//   @override
//   void initState() {
//     SystemChrome.setEnabledSystemUIOverlays([]);
//     onNewCameraSelected(cameras[0]);
//     super.initState();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     final CameraController? cameraController = controller;
//     if (cameraController == null || !cameraController.value.isInitialized) {
//       return;
//     }
//
//     if (state == AppLifecycleState.inactive) {
//       cameraController.dispose();
//     } else if (state == AppLifecycleState.resumed) {
//       onNewCameraSelected(cameraController.description);
//     }
//   }
//
//   @override
//   void dispose() {
//     controller?.dispose();
//     videoController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: _isCameraInitialized
//           ? Stack(
//               alignment: Alignment.topCenter,
//               children: [
//                 GestureDetector(
//                   behavior: HitTestBehavior.translucent,
//                   onScaleStart: (details) {
//                     zoom = _scaleFactor;
//                   },
//                   onScaleUpdate: (details) {
//                     _scaleFactor = zoom * details.scale;
//                     controller!.setZoomLevel(_scaleFactor);
//                     debugPrint('Gesture updated');
//                   },
//                   child: AspectRatio(
//                       aspectRatio: MediaQuery.of(context).size.aspectRatio,
//                       child: controller!.buildPreview()),
//                 ),
//                 if (!_isRearCameraSelected && !_isVideoCameraSelected)
//                   Positioned(
//                       top: 10,
//                       child: SizedBox(
//                         width: MediaQuery.of(context).size.width,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             InkWell(
//                               onTap: () async {
//                                 setState(() {
//                                   _currentFlashMode = FlashMode.off;
//                                 });
//                                 await controller!.setFlashMode(
//                                   FlashMode.off,
//                                 );
//                               },
//                               child: Icon(
//                                 Icons.flash_off,
//                                 color: _currentFlashMode == FlashMode.off
//                                     ? Colors.amber
//                                     : Colors.white,
//                               ),
//                             ),
//                             InkWell(
//                               onTap: () async {
//                                 setState(() {
//                                   _currentFlashMode = FlashMode.auto;
//                                 });
//                                 await controller!.setFlashMode(
//                                   FlashMode.auto,
//                                 );
//                               },
//                               child: Icon(
//                                 Icons.flash_auto,
//                                 color: _currentFlashMode == FlashMode.auto
//                                     ? Colors.amber
//                                     : Colors.white,
//                               ),
//                             ),
//                             InkWell(
//                               onTap: () async {
//                                 setState(() {
//                                   _currentFlashMode = FlashMode.always;
//                                 });
//                                 await controller!.setFlashMode(
//                                   FlashMode.always,
//                                 );
//                               },
//                               child: Icon(
//                                 Icons.flash_on,
//                                 color: _currentFlashMode == FlashMode.always
//                                     ? Colors.amber
//                                     : Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       )),
//                 Positioned(
//                   bottom: 0,
//                   child: Container(
//                     height: MediaQuery.of(context).size.height * 0.225,
//                     width: MediaQuery.of(context).size.width,
//                     color: Colors.black12,
//                     child: Column(
//                       children: [
//                         const SizedBox(height: 5),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             TextButton(
//                               onPressed: _isRecordingInProgress
//                                   ? null
//                                   : () {
//                                       if (_isVideoCameraSelected) {
//                                         setState(() {
//                                           _isVideoCameraSelected = false;
//                                         });
//                                       }
//                                     },
//                               style: TextButton.styleFrom(
//                                 primary: _isVideoCameraSelected
//                                     ? Colors.black54
//                                     : Colors.black,
//                                 backgroundColor: _isVideoCameraSelected
//                                     ? Colors.white30
//                                     : Colors.white,
//                               ),
//                               child: const Padding(
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: 45, vertical: 3),
//                                 child: Text('IMAGE'),
//                               ),
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 if (!_isVideoCameraSelected) {
//                                   setState(() {
//                                     _isVideoCameraSelected = true;
//                                   });
//                                 }
//                               },
//                               style: TextButton.styleFrom(
//                                 primary: _isVideoCameraSelected
//                                     ? Colors.black
//                                     : Colors.black54,
//                                 backgroundColor: _isVideoCameraSelected
//                                     ? Colors.white
//                                     : Colors.white30,
//                               ),
//                               child: const Padding(
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: 45, vertical: 3),
//                                 child: Text('VIDEO'),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 5),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   _isCameraInitialized = false;
//                                 });
//                                 onNewCameraSelected(
//                                   cameras[_isRearCameraSelected ? 0 : 1],
//                                 );
//                                 setState(() {
//                                   _isRearCameraSelected =
//                                       !_isRearCameraSelected;
//                                 });
//                               },
//                               child: Container(
//                                 height: 50,
//                                 width: 50,
//                                 decoration: const BoxDecoration(
//                                   color: Colors.black38,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 alignment: Alignment.center,
//                                 child: Icon(
//                                   _isRearCameraSelected
//                                       ? Icons.camera_front
//                                       : Icons.camera_rear,
//                                   color: Colors.white,
//                                   size: 30,
//                                 ),
//                               ),
//                             ),
//                             InkWell(
//                               onTap: _isVideoCameraSelected
//                                   ? () {
//                                       if (_isRecordingInProgress) {
//                                         stopVideoRecording().then((XFile? file) async {
//                                           if (mounted) {
//                                             setState(() {});
//                                           }
//                                           if(file != null){
//                                             File videoFile = File(file.path);
//
//                                             final directory =
//                                                 await getApplicationDocumentsDirectory();
//
//                                             String currentTime = DateTime.now()
//                                                 .millisecondsSinceEpoch.toString();
//
//                                             String fileFormat =
//                                                 videoFile.path.split('.').last;
//
//                                             _videoFile = await videoFile.copy(
//                                               '${directory.path}/$currentTime.$fileFormat',
//                                             );
//                                             Navigator.of(context).pop(_videoFile);
//                                             // _startVideoPlayer();
//                                           }
//                                         });
//                                       } else {
//                                         startVideoRecording().then((_) {
//                                           if (mounted) {
//                                             setState(() {});
//                                           }
//                                         });
//                                       }
//                                     }
//                                   : () {
//                                       takePicture().then((XFile? file) {
//                                         if (mounted) {
//                                           setState(() async {
//                                             File imageFile = File(file!.path);
//
//                                             int currentUnix = DateTime.now()
//                                                 .millisecondsSinceEpoch;
//                                             final directory =
//                                                 await getApplicationDocumentsDirectory();
//                                             String fileFormat =
//                                                 imageFile.path.split('.').last;
//
//                                             _imageFile = await imageFile.copy(
//                                               '${directory.path}/$currentUnix.$fileFormat',
//                                             );
//                                             print(
//                                                 '======----imageFile -----$_imageFile');
//                                             Navigator.of(context)
//                                                 .pop(_imageFile);
//                                           });
//                                         }
//                                       });
//                                     },
//                               child: Stack(
//                                 alignment: Alignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.circle,
//                                     color: _isVideoCameraSelected
//                                         ? Colors.white38
//                                         : Colors.white38,
//                                     size: 80,
//                                   ),
//                                   Icon(
//                                     Icons.circle,
//                                     color: _isVideoCameraSelected
//                                         ? Colors.red
//                                         : Colors.white,
//                                     size: 70,
//                                   ),
//                                   _isVideoCameraSelected &&
//                                           _isRecordingInProgress
//                                       ? const Icon(
//                                           Icons.stop_rounded,
//                                           color: Colors.white,
//                                           size: 32,
//                                         )
//                                       : Container(),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(width: 50)
//                           ],
//                         ),
//                         const SizedBox(height: 5),
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             )
//           : Container(),
//     );
//   }
// }
