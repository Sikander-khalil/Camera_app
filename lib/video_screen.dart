import 'dart:io';
import 'dart:typed_data';

import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:path/path.dart' as path;
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class VideoScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  VideoScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late CameraController controller;
  bool isCapturing = false;
  String videoPath = '';

  bool _isRecording = false;

  //for switching cameras

  int _selectedCameraIndex = 0;

  bool _isFrontCamera = false;

  //for Flash

  bool _isFlashOn = false;

  //for focusing

  Offset? _focusPoint;
  //for Zoom

  double _currentZoom = 1.0;
  File? _captureImage;
  //for Making Sound

  AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();

    controller = CameraController(widget.cameras[0], ResolutionPreset.max);

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _toggleFlashLight() {
    if (_isFlashOn) {
      controller.setFlashMode(FlashMode.off);
      setState(() {
        _isFlashOn = false;
      });
    } else {
      controller.setFlashMode(FlashMode.torch);
      setState(() {
        _isFlashOn = true;
      });
    }
  }

  void _switchCamera() async {
    if (controller != null) {
      await controller.dispose();
    }
    //Incrment or reset the selected camera Index
    _selectedCameraIndex = (_selectedCameraIndex + 1) % widget.cameras.length;

    //Initialize the new Camera

    _initCamera(_selectedCameraIndex);
  }

  Future<void> _initCamera(int cameraIndex) async {
    controller =
        CameraController(widget.cameras[cameraIndex], ResolutionPreset.max);
    try {
      await controller.initialize();
      setState(() {
        if (cameraIndex == 0) {
          _isFrontCamera = false;
        } else {
          _isFrontCamera = true;
        }
      });
    } catch (e) {
      print("Error Object : ${e.toString()}");
    }

    if (mounted) {
      setState(() {});
    }
  }

  // void capturePhoto() async {
  //   if (!controller.value.isInitialized) {
  //     return;
  //   }
  //   final Directory appDir =
  //       await pathProvider.getApplicationSupportDirectory();
  //   final String capturePath = path.join(appDir.path, '${DateTime.now()}.jpg');
  //   if (controller.value.isTakingPicture) {
  //     return;
  //   }

  //   try {
  //     setState(() {
  //       isCapturing = true;
  //     });

  //     final XFile captureImage = await controller.takePicture();
  //     String imagePath = captureImage.path;

  //     // Read the image file and convert it to Uint8List
  //     final File imageFile = File(imagePath);
  //     Uint8List imageBytes = await imageFile.readAsBytes();

  //     await ImageGallerySaver.saveImage(imageBytes);

  //     audioPlayer.open(Audio('music/camera_shutter.mp3'));

  //     audioPlayer.play();
  //     // for showing Image

  //     final String filePath =
  //         '$capturePath/${DateTime.now().millisecondsSinceEpoch}.jpg';

  //     _captureImage = File(captureImage.path);

  //     _captureImage!.renameSync(filePath);
  //   } catch (e) {
  //     print(e.toString());
  //   } finally {
  //     setState(() {
  //       isCapturing = false;
  //     });
  //   }
  // }

  void zoomCamera(double value) {
    setState(() {
      _currentZoom = value;
      controller.setZoomLevel(value);
    });
  }

  Future<void> _setFocusPoint(Offset point) async {
    if (controller != null && controller.value.isInitialized) {
      try {
        final double x = point.dx.clamp(0.0, 1.0);
        final double y = point.dy.clamp(0.0, 1.0);
        await controller.setFocusPoint(Offset(x, y));
        await controller.setFocusMode(FocusMode.auto);

        setState(() {
          _focusPoint = Offset(x, y);
        });

        //Reset _focusPoint after a short delay to remove the square

        await Future.delayed(Duration(seconds: 2));

        setState(() {
          _focusPoint = null;
        });
      } catch (e) {
        print(e.toString());
      }
    }
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopVideoRecording();
    } else {
      _startVideoRecording();
    }
  }

  Future<void> _startVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      final directory = await pathProvider.getTemporaryDirectory();

      final path =
          '${directory.path}./video.${DateTime.now().millisecondsSinceEpoch}.mp4';

      try {
        await controller.initialize();

        await controller.startVideoRecording();

        setState(() {
          _isRecording = true;

          videoPath = path;
        });
      } catch (e) {
        print(e.toString());
        return;
      }
    }
  }

  void _stopVideoRecording() async {
    if (controller.value.isRecordingVideo) {
      try {
        final XFile videoFile = await controller.stopVideoRecording();
        setState(() {
          _isRecording = false;
        });
        if (videoPath.isNotEmpty) {
          final File file = File(videoFile.path);

          await file.copy(videoPath);
          await ImageGallerySaver.saveFile(videoPath);
          audioPlayer.open(Audio('music/camera_shutter.mp3'));

          audioPlayer.play();
        }
      } catch (e) {
        print(e.toString());

        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GestureDetector(
                            onTap: () {
                              _toggleFlashLight();
                            },
                            child: _isFlashOn == false
                                ? Icon(
                                    Icons.flash_off,
                                    color: Colors.white,
                                  )
                                : Icon(
                                    Icons.flash_on,
                                    color: Colors.amber,
                                  )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GestureDetector(
                          onTap: () {},
                          child: Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                top: 50,
                bottom: _isFrontCamera == false ? 0 : 150,
                child: controller != null && controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: GestureDetector(
                            onTapDown: (TapDownDetails details) {
                              final Offset tapPosition = details.localPosition;

                              final Offset relativeTopPosition = Offset(
                                tapPosition.dx / constraints.maxWidth,
                                tapPosition.dy / constraints.maxHeight,
                              );

                              _setFocusPoint(relativeTopPosition);
                            },
                            child: CameraPreview(controller)),
                      )
                    : Container(), // You can replace this with a loading indicator or other UI as needed
              ),
              Positioned(
                  top: 50,
                  right: 10,
                  child: SfSlider.vertical(
                      max: 5.0,
                      min: 1.0,
                      activeColor: Colors.white,
                      value: _currentZoom,
                      onChanged: (dynamic value) {
                        setState(() {
                          zoomCamera(value);
                        });
                      })),
              if (_focusPoint != null)
                Positioned.fill(
                  top: 50,
                  child: Align(
                    alignment: Alignment(
                        _focusPoint!.dx * 2 - 1, _focusPoint!.dy * 2 - 1),
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2)),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                      color: _isFrontCamera == false
                          ? Colors.black45
                          : Colors.black),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Video",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Photo",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Pro Mode",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // _captureImage != null
                                    //     ? Container(
                                    //         width: 50,
                                    //         height: 50,
                                    //         child: Image.file(
                                    //           _captureImage!,
                                    //           fit: BoxFit.cover,
                                    //         ),
                                    //       )
                                    //     : Container(),
                                    Container(),
                                  ],
                                )),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _toggleRecording();
                                    },
                                    child: Center(
                                      child: Container(
                                          height: 70,
                                          width: 70,
                                          decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              border: Border.all(
                                                  width: 4,
                                                  color: Colors.white,
                                                  style: BorderStyle.solid)),
                                          child: _isRecording == false
                                              ? Icon(
                                                  Icons.play_arrow,
                                                  color: Colors.white,
                                                  size: 40,
                                                )
                                              : Icon(
                                                  Icons.stop,
                                                  color: Colors.white,
                                                  size: 40,
                                                )),
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: GestureDetector(
                                  onTap: () {
                                    _switchCamera();
                                  },
                                  child: Icon(
                                    Icons.cameraswitch_sharp,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ))
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ));
  }
}
