import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'camera_app.dart';

List<CameraDescription> cameras = [];
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool hasPermission = false;

  // Future getPermission() async {
  //   if (await Permission.location.serviceStatus.isEnabled) {
  //     var status = await Permission.location.status;
  //     if (status.isGranted) {
  //       hasPermission = true;
  //     } else {
  //       Permission.location.request().then((value) {
  //         setState(() {
  //           hasPermission = (value == PermissionStatus.granted);
  //         });
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Develop Something',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: CameraApp(
          cameras: cameras,
        ));
  }
}
